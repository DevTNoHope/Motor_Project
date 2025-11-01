BE/
├─ src/
│ ├─ server.js # tạo app, listen
│ ├─ app.js # cấu hình express, view engine, routes, middlewares
│ ├─ config/
│ │ ├─ env.js # đọc .env
│ │ └─ db.js # init Sequelize
│ ├─ models/ # Sequelize models (Roles, Accs, Users, Employees,...)
│ │ ├─ index.js # liên kết models & export
│ │ ├─ role.model.js
│ │ ├─ acc.model.js
│ │ ├─ user.model.js
│ │ ├─ employee.model.js
│ │ ├─ service.model.js
│ │ ├─ vehicle.model.js
│ │ ├─ booking.model.js
│ │ ├─ bookingService.model.js
│ │ ├─ diagnosis.model.js
│ │ ├─ partType.model.js
│ │ ├─ supplier.model.js
│ │ ├─ part.model.js
│ │ ├─ inventory.model.js
│ │ ├─ purchaseOrder.model.js
│ │ ├─ purchaseOrderItem.model.js
│ │ └─ payment.model.js
│ ├─ controllers/ # xử lý request -> gọi services
│ │ ├─ auth.controller.js
│ │ ├─ me.controller.js
│ │ ├─ service.controller.js
│ │ ├─ booking.controller.js
│ │ ├─ mechanic.controller.js
│ │ ├─ admin.controller.js
│ │ ├─ part.controller.js
│ │ ├─ purchase.controller.js
│ │ └─ inventory.controller.js
│ ├─ services/ # nghiệp vụ (anti-overlap, state machine, ...)
│ │ ├─ auth.service.js
│ │ ├─ booking.service.js
│ │ ├─ slot.service.js
│ │ ├─ mechanic.service.js
│ │ ├─ admin.service.js
│ │ ├─ part.service.js
│ │ └─ purchase.service.js
│ ├─ routes/ # khai báo route
│ │ ├─ api/
│ │ │ ├─ auth.api.js
│ │ │ ├─ me.api.js
│ │ │ ├─ services.api.js
│ │ │ ├─ bookings.api.js
│ │ │ ├─ mechanic.api.js
│ │ │ ├─ admin.api.js
│ │ │ ├─ parts.api.js
│ │ │ ├─ inventory.api.js
│ │ │ └─ purchase.api.js
│ │ └─ web/
│ │ ├─ admin.web.js # SSR EJS cho trang admin
│ │ └─ index.web.js
│ ├─ middlewares/
│ │ ├─ auth.js # verifyJWT, requireRole
│ │ ├─ error.js # error handler
│ │ └─ upload.js # multer upload avatar
│ ├─ views/ # EJS views (Admin MVC)
│ │ ├─ layouts/
│ │ │ └─ admin.ejs
│ │ ├─ admin/
│ │ │ ├─ dashboard.ejs
│ │ │ ├─ bookings.ejs
│ │ │ ├─ services.ejs
│ │ │ ├─ users.ejs
│ │ │ ├─ employees.ejs
│ │ │ ├─ parts.ejs
│ │ │ └─ purchase_orders.ejs
│ │ └─ partials/
│ ├─ public/ # css/js/images admin tĩnh
│ └─ utils/
│ ├─ date.js
│ └─ overlap.js # hàm kiểm tra trùng lịch
├─ .env.example
├─ package.json
└─ README.md
