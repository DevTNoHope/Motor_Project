-- =========================================================
--  Motorbike Service Booking - Single Shop (MySQL 8+)
--  Schema: Roles/Accs/Users/Employees + Booking + Parts/Inventory
--  Charset: utf8mb4, Engine: InnoDB
--  Author: Nhóm của bạn
--  Date: 2025-11-02
-- =========================================================

-- --------
-- DATABASE
-- --------
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE DATABASE IF NOT EXISTS motorbike_service_app
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

USE motorbike_service_app;

-- Optional: drop all tables (comment out in production)
-- SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS;
-- SET FOREIGN_KEY_CHECKS = 0;
-- DROP TABLE IF EXISTS Payments, PurchaseOrderItems, PurchaseOrders, Inventory,
--   Parts, Suppliers, PartTypes, PhieuDanhGiaXe, Booking_Service, Bookings,
--   Vehicles, Services, LichLamViec, Employees, Users, Accs, Roles;
-- SET FOREIGN_KEY_CHECKS = @OLD_FOREIGN_KEY_CHECKS;

-- -------------
-- BASE TABLES
-- -------------

-- Roles: USER, MECHANIC, ADMIN
CREATE TABLE Roles (
  id          BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  code        VARCHAR(32) NOT NULL UNIQUE, -- USER, MECHANIC, ADMIN
  name        VARCHAR(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Accounts (Accs): xác thực + thông tin cơ bản
CREATE TABLE Accs (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  role_id       BIGINT UNSIGNED NOT NULL,
  email         VARCHAR(191) UNIQUE,
  phone         VARCHAR(24) UNIQUE,
  password_hash VARCHAR(191) NOT NULL,
  name          VARCHAR(191) NOT NULL,
  gender        ENUM('M','F','O') NULL,
  birth_year    INT NULL,
  avatar_url    TEXT NULL,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_accs_role FOREIGN KEY (role_id) REFERENCES Roles(id)
    ON UPDATE RESTRICT ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Users: hồ sơ khách hàng
CREATE TABLE Users (
  id        BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  acc_id    BIGINT UNSIGNED NOT NULL UNIQUE,
  address   TEXT NULL,
  note      TEXT NULL,
  CONSTRAINT fk_users_acc FOREIGN KEY (acc_id) REFERENCES Accs(id)
    ON UPDATE RESTRICT ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Employees: hồ sơ thợ
CREATE TABLE Employees (
  id         BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  acc_id     BIGINT UNSIGNED NOT NULL UNIQUE,
  skill_tags TEXT NULL,
  hired_at   DATE NULL,
  CONSTRAINT fk_employees_acc FOREIGN KEY (acc_id) REFERENCES Accs(id)
    ON UPDATE RESTRICT ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Optional: Lịch làm việc theo ngày (tối giản)
CREATE TABLE LichLamViec (
  id          BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  mechanic_id BIGINT UNSIGNED NOT NULL,
  work_date   DATE NOT NULL,
  start_min   INT NOT NULL,  -- phút từ 00:00 (vd 540 = 09:00)
  end_min     INT NOT NULL,
  step_min    INT NOT NULL DEFAULT 15,
  CONSTRAINT fk_llv_mechanic FOREIGN KEY (mechanic_id) REFERENCES Employees(id)
    ON UPDATE RESTRICT ON DELETE CASCADE,
  INDEX idx_llv_mechanic_date (mechanic_id, work_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -------------
-- CATALOG TABLES
-- -------------

-- Services: QUICK (cố định), REPAIR (chẩn đoán)
CREATE TABLE Services (
  id                    BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  name                  VARCHAR(191) NOT NULL,
  type                  ENUM('QUICK','REPAIR') NOT NULL,
  description           TEXT NULL,
  default_duration_min  INT NULL,        -- QUICK cần, REPAIR có thể NULL
  base_price            DECIMAL(10,2) NULL,
  is_active             TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Vehicles: một khách nhiều xe
CREATE TABLE Vehicles (
  id        BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  user_id   BIGINT UNSIGNED NOT NULL,
  plate_no  VARCHAR(32) NOT NULL,
  brand     VARCHAR(100) NULL,
  model     VARCHAR(100) NULL,
  year      INT NULL,
  color     VARCHAR(50) NULL,
  CONSTRAINT fk_vehicles_user FOREIGN KEY (user_id) REFERENCES Users(id)
    ON UPDATE RESTRICT ON DELETE CASCADE,
  UNIQUE KEY uq_vehicle_user_plate (user_id, plate_no),
  INDEX idx_vehicles_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -------------
-- BOOKING TABLES
-- -------------

-- Bookings: single shop, có thể chọn thợ hoặc để null (bất kỳ)
CREATE TABLE Bookings (
  id             BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  user_id        BIGINT UNSIGNED NOT NULL,
  mechanic_id    BIGINT UNSIGNED NULL,
  vehicle_id     BIGINT UNSIGNED NULL,
  start_dt       DATETIME NOT NULL,
  end_dt         DATETIME NULL,  -- REPAIR chốt sau chẩn đoán
  status         ENUM('PENDING','APPROVED','IN_DIAGNOSIS','IN_PROGRESS','DONE','CANCELED') NOT NULL DEFAULT 'PENDING',
  notes_user     TEXT NULL,
  notes_mechanic TEXT NULL,
  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_bookings_user FOREIGN KEY (user_id) REFERENCES Users(id)
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT fk_bookings_mech FOREIGN KEY (mechanic_id) REFERENCES Employees(id)
    ON UPDATE RESTRICT ON DELETE SET NULL,
  CONSTRAINT fk_bookings_vehicle FOREIGN KEY (vehicle_id) REFERENCES Vehicles(id)
    ON UPDATE RESTRICT ON DELETE SET NULL,
  -- Index quan trọng để kiểm tra trùng lịch theo thợ
  INDEX idx_booking_overlap (mechanic_id, start_dt, end_dt),
  INDEX idx_booking_user (user_id),
  INDEX idx_booking_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Booking_Service: dịch vụ kèm theo mỗi đơn
CREATE TABLE Booking_Service (
  id                      BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  booking_id              BIGINT UNSIGNED NOT NULL,
  service_id              BIGINT UNSIGNED NOT NULL,
  qty                     INT NOT NULL DEFAULT 1,
  price_snapshot          DECIMAL(10,2) NULL,
  duration_snapshot_min   INT NULL,
  CONSTRAINT fk_bs_booking FOREIGN KEY (booking_id) REFERENCES Bookings(id)
    ON UPDATE RESTRICT ON DELETE CASCADE,
  CONSTRAINT fk_bs_service FOREIGN KEY (service_id) REFERENCES Services(id)
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  INDEX idx_bs_booking (booking_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Phiếu đánh giá xe (chẩn đoán cho REPAIR)
CREATE TABLE PhieuDanhGiaXe (
  id              BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  booking_id      BIGINT UNSIGNED NOT NULL,
  diagnosis_note  TEXT NOT NULL,
  eta_min         INT NULL,             -- thời gian dự kiến trả xe (tổng)
  labor_est_min   INT NULL,             -- thời lượng công lao động ước tính
  required_parts  JSON NULL,            -- danh sách phụ tùng dự kiến [{partId, qty}]
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_pdgx_booking FOREIGN KEY (booking_id) REFERENCES Bookings(id)
    ON UPDATE RESTRICT ON DELETE CASCADE,
  UNIQUE KEY uq_pdgx_booking (booking_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -------------
-- PARTS & INVENTORY TABLES
-- -------------

CREATE TABLE PartTypes (
  id          BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  name        VARCHAR(191) NOT NULL,
  description TEXT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE Suppliers (
  id            BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  name          VARCHAR(191) NOT NULL,
  contact_phone VARCHAR(32) NULL,
  address       TEXT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE Parts (
  id        BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  type_id   BIGINT UNSIGNED NOT NULL,
  name      VARCHAR(191) NOT NULL,
  sku       VARCHAR(64) NOT NULL UNIQUE,
  unit      VARCHAR(20) NOT NULL,         -- cái, bộ, lít...
  price     DECIMAL(10,2) NOT NULL,       -- giá bán lẻ đề xuất
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  CONSTRAINT fk_parts_type FOREIGN KEY (type_id) REFERENCES PartTypes(id)
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  INDEX idx_parts_type (type_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE Inventory (
  id       BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  part_id  BIGINT UNSIGNED NOT NULL,
  qty      INT NOT NULL DEFAULT 0,
  min_qty  INT NOT NULL DEFAULT 0,
  CONSTRAINT fk_inventory_part FOREIGN KEY (part_id) REFERENCES Parts(id)
    ON UPDATE RESTRICT ON DELETE CASCADE,
  UNIQUE KEY uq_inventory_part (part_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE PurchaseOrders (
  id           BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  supplier_id  BIGINT UNSIGNED NOT NULL,
  created_by   BIGINT UNSIGNED NOT NULL, -- Accs.id của người lập phiếu
  status       ENUM('DRAFT','RECEIVED','CANCELED') NOT NULL DEFAULT 'DRAFT',
  note         TEXT NULL,
  created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_po_supplier FOREIGN KEY (supplier_id) REFERENCES Suppliers(id)
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT fk_po_creator FOREIGN KEY (created_by) REFERENCES Accs(id)
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  INDEX idx_po_supplier (supplier_id),
  INDEX idx_po_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE PurchaseOrderItems (
  id         BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  po_id      BIGINT UNSIGNED NOT NULL,
  part_id    BIGINT UNSIGNED NOT NULL,
  qty        INT NOT NULL,
  cost_price DECIMAL(10,2) NOT NULL,
  CONSTRAINT fk_poi_po FOREIGN KEY (po_id) REFERENCES PurchaseOrders(id)
    ON UPDATE RESTRICT ON DELETE CASCADE,
  CONSTRAINT fk_poi_part FOREIGN KEY (part_id) REFERENCES Parts(id)
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  INDEX idx_poi_po (po_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -------------
-- PAYMENTS (giả lập)
-- -------------

CREATE TABLE Payments (
  id              BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  booking_id      BIGINT UNSIGNED NOT NULL,
  method          ENUM('CASH','WALLET') NOT NULL,
  amount          DECIMAL(10,2) NOT NULL,
  status          ENUM('PENDING','PAID','FAILED') NOT NULL DEFAULT 'PENDING',
  transaction_code VARCHAR(128) NULL,
  paid_at         DATETIME NULL,
  CONSTRAINT fk_payments_booking FOREIGN KEY (booking_id) REFERENCES Bookings(id)
    ON UPDATE RESTRICT ON DELETE CASCADE,
  INDEX idx_pay_booking (booking_id),
  INDEX idx_pay_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS = 1;

-- -------------
-- SEED DỮ LIỆU MẪU
-- -------------

START TRANSACTION;

-- Roles
INSERT INTO Roles(code, name) VALUES
  ('ADMIN','Quản trị'),
  ('MECHANIC','Thợ sửa'),
  ('USER','Khách hàng')
ON DUPLICATE KEY UPDATE name = VALUES(name);

-- Accounts (1 admin, 2 thợ, 2 user) - password_hash: placeholder
INSERT INTO Accs(role_id, email, phone, password_hash, name)
VALUES
  ((SELECT id FROM Roles WHERE code='ADMIN'),   'admin@demo.local',   '0900000001', '$2y$10$demo_hash', 'Admin Demo'),
  ((SELECT id FROM Roles WHERE code='MECHANIC'),'mech1@demo.local',   '0900000002', '$2y$10$demo_hash', 'Thợ A'),
  ((SELECT id FROM Roles WHERE code='MECHANIC'),'mech2@demo.local',   '0900000003', '$2y$10$demo_hash', 'Thợ B'),
  ((SELECT id FROM Roles WHERE code='USER'),    'user1@demo.local',   '0900000004', '$2y$10$demo_hash', 'Khách 1'),
  ((SELECT id FROM Roles WHERE code='USER'),    'user2@demo.local',   '0900000005', '$2y$10$demo_hash', 'Khách 2')
ON DUPLICATE KEY UPDATE name = VALUES(name);

-- Profiles
INSERT INTO Employees(acc_id, skill_tags, hired_at)
SELECT a.id, 'máy, điện', CURDATE()
FROM Accs a JOIN Roles r ON a.role_id=r.id
WHERE r.code='MECHANIC' AND a.id NOT IN (SELECT acc_id FROM Employees);

INSERT INTO Users(acc_id, address)
SELECT a.id, 'HCM'
FROM Accs a JOIN Roles r ON a.role_id=r.id
WHERE r.code='USER' AND a.id NOT IN (SELECT acc_id FROM Users);

-- Services (3 QUICK + 2 REPAIR)
INSERT INTO Services(name, type, description, default_duration_min, base_price, is_active) VALUES
  ('Thay nhớt xe', 'QUICK', 'Thay dầu nhớt tiêu chuẩn', 20, 80000, 1),
  ('Rửa xe',       'QUICK', 'Rửa xe cơ bản',            25, 50000, 1),
  ('Thay lốp',     'QUICK', 'Thay lốp trước/sau',       40, 250000,1),
  ('Sửa phanh',    'REPAIR','Kiểm tra & sửa hệ thống phanh', NULL, NULL, 1),
  ('Sửa máy',      'REPAIR','Kiểm tra & sửa máy',         NULL, NULL, 1)
ON DUPLICATE KEY UPDATE description=VALUES(description);

-- Parts seed
INSERT INTO PartTypes(name) VALUES ('Dầu nhớt'), ('Lốp xe'), ('Phanh') 
ON DUPLICATE KEY UPDATE name=VALUES(name);

INSERT INTO Suppliers(name, contact_phone) VALUES ('NCC A','0901111111'),('NCC B','0902222222')
ON DUPLICATE KEY UPDATE name=VALUES(name);

INSERT INTO Parts(type_id, name, sku, unit, price, is_active) VALUES
  ((SELECT id FROM PartTypes WHERE name='Dầu nhớt'),'Nhớt 10W-40', 'OIL-10W40', 'Lít', 120000, 1),
  ((SELECT id FROM PartTypes WHERE name='Lốp xe'), 'Lốp 90/90-14', 'TIRE-909014', 'Cái', 350000, 1),
  ((SELECT id FROM PartTypes WHERE name='Phanh'),  'Má phanh trước', 'BRAKE-FR-PAD', 'Bộ', 180000, 1)
ON DUPLICATE KEY UPDATE price=VALUES(price);

INSERT INTO Inventory(part_id, qty, min_qty)
SELECT p.id, 10, 2 FROM Parts p
ON DUPLICATE KEY UPDATE qty=VALUES(qty);

COMMIT;

-- -------------
-- GỢI Ý INDEX/VIEW BỔ SUNG (tùy chọn)
-- -------------
-- Ví dụ view đơn theo ngày
-- CREATE VIEW vw_bookings_today AS
-- SELECT * FROM Bookings WHERE DATE(start_dt) = CURDATE();

-- -------------
-- DONE
-- -------------
