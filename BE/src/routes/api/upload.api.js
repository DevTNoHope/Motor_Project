const path = require('path');
const fs = require('fs');
const express = require('express');
const multer = require('multer');
const { verifyJWT } = require('../../middlewares/auth'); // middleware JWT của bạn

const router = express.Router();

router.use(verifyJWT);
// thư mục lưu file: src/public/uploads/avatars
const uploadDir = path.join(__dirname, '../../public/uploads/avatars');
fs.mkdirSync(uploadDir, { recursive: true });

const storage = multer.diskStorage({
  destination: (_, __, cb) => cb(null, uploadDir),
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname || '');
    const name = `${Date.now()}_${req.user.sub}${ext}`;
    cb(null, name);
  },
});
const fileFilter = (_, file, cb) => {
  const ok = /image\/(png|jpe?g|gif|webp)/.test(file.mimetype);
  cb(ok ? null : new Error('INVALID_FILE'), ok);
};

const upload = multer({ storage, fileFilter, limits: { fileSize: 5 * 1024 * 1024 } });

// POST /api/v1/upload/avatar  (multipart, field "file")
router.post('/avatar', upload.single('file'), async (req, res, next) => {
  try {
    const fname = req.file.filename;
    // URL public: /uploads/avatars/<file>
    const url = `/uploads/avatars/${fname}`;
    res.json({ url });
  } catch (e) { next(e); }
});

module.exports = router;
