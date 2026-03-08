const jwt = require('jsonwebtoken');
const User = require('../models/User');

const auth = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ message: 'Không có token xác thực' });
    }

    const token = authHeader.split(' ')[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const user = await User.findById(decoded.id);

    if (!user) {
      return res.status(401).json({ message: 'Token không hợp lệ' });
    }

    req.user = user;
    next();
  } catch (error) {
    res.status(401).json({ message: 'Token không hợp lệ hoặc đã hết hạn' });
  }
};

const adminOnly = (req, res, next) => {
  if (req.user.role !== 'admin') {
    return res.status(403).json({ message: 'Chỉ admin mới có quyền truy cập' });
  }
  next();
};

module.exports = { auth, adminOnly };
