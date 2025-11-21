const bcrypt = require('bcrypt');
const crypto = require('crypto');
const jwt = require('jsonwebtoken');
const { OAuth2Client } = require('google-auth-library');
const { Acc, Role, User } = require('../models');

const ROUNDS = Number(process.env.BCRYPT_ROUNDS || 10);
const googleClient = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

async function hashPassword(plain) {
  return bcrypt.hash(plain, ROUNDS);
}

async function comparePassword(plain, hash) {
  return bcrypt.compare(plain, hash);
}

function signToken(acc) {
  // Lấy code role để FE hiển thị UI theo role
  const payload = {
    sub: String(acc.id),
    roleCode: acc.Role.code,
    accId: acc.id,
    name: acc.name
  };
  return jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: process.env.JWT_EXPIRES_IN || '1d' });
}

/**
 * Đăng ký khách hàng (USER)
 * - email hoặc phone là unique (có thể dùng 1 trong 2, demo dùng email)
 * - tạo Acc (ROLE=USER) + User profile
 */
async function registerUser({ email, phone, password, name, gender, birth_year }) {
  // Kiểm tra role USER phải tồn tại
  const roleUser = await Role.findOne({ where: { code: 'USER' } });
  if (!roleUser) throw Object.assign(new Error('Role USER not found'), { status: 500, code: 'ROLE_MISSING' });

  // Không cho trùng email/phone
  if (email) {
    const exist = await Acc.findOne({ where: { email } });
    if (exist) throw Object.assign(new Error('Email already used'), { status: 409, code: 'EMAIL_TAKEN' });
  }
  if (phone) {
    const exist = await Acc.findOne({ where: { phone } });
    if (exist) throw Object.assign(new Error('Phone already used'), { status: 409, code: 'PHONE_TAKEN' });
  }

  const password_hash = await hashPassword(password);

  // Tạo account
  const acc = await Acc.create({
    role_id: roleUser.id,
    email: email || null,
    phone: phone || null,
    password_hash,
    name,
    gender: gender || null,
    birth_year: birth_year || null,
    created_at: new Date()
  });

  // Tạo hồ sơ user
  await User.create({ acc_id: acc.id });

  // Nạp role vào acc để sign token
  acc.Role = roleUser;
  const accessToken = signToken(acc);

  return {
    accessToken,
    role: roleUser.code,
    account: { id: acc.id, name: acc.name, email: acc.email, phone: acc.phone }
  };
}

/**
 * Đăng nhập bằng email hoặc phone
 */
async function login({ email, phone, password }) {
  const where = email ? { email } : { phone };
  const acc = await Acc.findOne({
    where,
    include: [{ model: Role, attributes: ['code', 'name'] }]
  });
  if (!acc) throw Object.assign(new Error('Account not found'), { status: 401, code: 'INVALID_CREDENTIALS' });

  const ok = await comparePassword(password, acc.password_hash);
  if (!ok) throw Object.assign(new Error('Wrong password'), { status: 401, code: 'INVALID_CREDENTIALS' });

  const accessToken = signToken(acc);
  return {
    accessToken,
    role: acc.Role.code,
    account: { id: acc.id, name: acc.name, email: acc.email, phone: acc.phone }
  };
}
/**
 * Đăng nhập bằng google
 */
async function loginWithGoogle({ idToken }) {
  // 1. Verify idToken với Google
  const ticket = await googleClient.verifyIdToken({
    idToken,
    audience: process.env.GOOGLE_CLIENT_ID
  });
  const payload = ticket.getPayload();
  // payload thường có: sub, email, name, picture, given_name, family_name, ...

  const googleId = payload.sub;
  const email = payload.email;
  const name = payload.name || email;

  // 2. Lấy role USER
  const roleUser = await Role.findOne({ where: { code: 'USER' } });
  if (!roleUser) {
    throw Object.assign(new Error('Role USER not found'), { status: 500, code: 'ROLE_MISSING' });
  }

  // 3. Tìm account đã tồn tại
  let acc = await Acc.findOne({
    where: { email }, // có thể thêm cột google_id nếu bạn migrate DB
    include: [{ model: Role, attributes: ['code', 'name'] }]
  });

  // 4. Nếu chưa có thì tạo mới
  if (!acc) {
    const randomPassword = crypto.randomBytes(16).toString('hex');
    const passwordHash = await hashPassword(randomPassword);
    acc = await Acc.create({
      role_id: roleUser.id,
      email: email,
      phone: null,
      // Với account login bằng Google, có thể để password_hash null hoặc random
      password_hash: passwordHash,
      name,
      gender: null,
      birth_year: null,
      created_at: new Date()
    });

    await User.create({ acc_id: acc.id }); // tạo profile user

    // để signToken dùng được role
    acc.Role = roleUser;
  }

  // Nếu acc lấy từ DB mà không include Role, thì nhớ nạp lại Role
  if (!acc.Role) {
    acc = await Acc.findOne({
      where: { id: acc.id },
      include: [{ model: Role, attributes: ['code', 'name'] }]
    });
  }

  const accessToken = signToken(acc);
  return {
    accessToken,
    role: acc.Role.code,
    account: { id: acc.id, name: acc.name, email: acc.email, phone: acc.phone }
  };
}

module.exports = { registerUser, login, loginWithGoogle };