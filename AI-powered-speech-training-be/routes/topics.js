const express = require('express');
const { body, validationResult, query } = require('express-validator');
const Topic = require('../models/Topic');
const { auth, adminOnly } = require('../middleware/auth');
const { generateTopicSuggestions } = require('../services/openaiService');

const router = express.Router();

// GET /api/topics - List topics (public, with search & filter)
router.get('/', async (req, res) => {
  try {
    const { search, level, page = 1, limit = 20 } = req.query;
    const filter = {};

    if (level && ['beginner', 'intermediate', 'advanced'].includes(level)) {
      filter.level = level;
    }

    if (search) {
      filter.$or = [
        { title: { $regex: search, $options: 'i' } },
        { tags: { $regex: search, $options: 'i' } },
      ];
    }

    const skip = (parseInt(page) - 1) * parseInt(limit);
    const [topics, total] = await Promise.all([
      Topic.find(filter).sort({ createdAt: -1 }).skip(skip).limit(parseInt(limit)),
      Topic.countDocuments(filter),
    ]);

    res.json({
      topics,
      total,
      page: parseInt(page),
      totalPages: Math.ceil(total / parseInt(limit)),
    });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server', error: error.message });
  }
});

// GET /api/topics/:id
router.get('/:id', async (req, res) => {
  try {
    const topic = await Topic.findById(req.params.id);
    if (!topic) {
      return res.status(404).json({ message: 'Không tìm thấy topic' });
    }
    res.json(topic);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server', error: error.message });
  }
});

// POST /api/topics - Create topic (admin only)
router.post(
  '/',
  auth,
  adminOnly,
  [
    body('title').trim().notEmpty().withMessage('Title không được để trống'),
    body('prompt').trim().notEmpty().withMessage('Prompt không được để trống'),
    body('level').optional().isIn(['beginner', 'intermediate', 'advanced']),
    body('duration').optional().isString(),
    body('questions').optional().isArray(),
    body('tags').optional().isArray(),
  ],
  async (req, res) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ message: errors.array()[0].msg });
      }

      const { title, prompt, level, duration, questions, tags } = req.body;
      const topic = await Topic.create({
        title,
        prompt,
        level: level || 'beginner',
        duration: duration || '3-5 phút',
        questions: questions || [],
        tags: tags || [],
        createdBy: req.user._id,
      });

      res.status(201).json(topic);
    } catch (error) {
      res.status(500).json({ message: 'Lỗi server', error: error.message });
    }
  }
);

// PUT /api/topics/:id - Update topic (admin only)
router.put(
  '/:id',
  auth,
  adminOnly,
  [
    body('title').optional().trim().notEmpty(),
    body('prompt').optional().trim().notEmpty(),
    body('level').optional().isIn(['beginner', 'intermediate', 'advanced']),
  ],
  async (req, res) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ message: errors.array()[0].msg });
      }

      const topic = await Topic.findByIdAndUpdate(
        req.params.id,
        { $set: req.body },
        { new: true, runValidators: true }
      );

      if (!topic) {
        return res.status(404).json({ message: 'Không tìm thấy topic' });
      }

      res.json(topic);
    } catch (error) {
      res.status(500).json({ message: 'Lỗi server', error: error.message });
    }
  }
);

// DELETE /api/topics/:id - Delete topic (admin only)
router.delete('/:id', auth, adminOnly, async (req, res) => {
  try {
    const topic = await Topic.findByIdAndDelete(req.params.id);
    if (!topic) {
      return res.status(404).json({ message: 'Không tìm thấy topic' });
    }
    res.json({ message: 'Đã xóa topic thành công' });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server', error: error.message });
  }
});

// POST /api/topics/generate - Generate topics with AI (admin only)
router.post('/generate', auth, adminOnly, async (req, res) => {
  try {
    const { level = 'intermediate', count = 3 } = req.body;
    const suggestions = await generateTopicSuggestions(level, Math.min(count, 5));
    res.json({ suggestions });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi khi tạo topic bằng AI', error: error.message });
  }
});

module.exports = router;
