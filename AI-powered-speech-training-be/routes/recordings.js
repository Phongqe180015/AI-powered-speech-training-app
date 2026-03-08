const express = require('express');
const fs = require('fs');
const Recording = require('../models/Recording');
const Topic = require('../models/Topic');
const { auth } = require('../middleware/auth');
const upload = require('../middleware/upload');
const { transcribeAudio, analyzeSpeech } = require('../services/openaiService');

const router = express.Router();

// POST /api/recordings/upload - Upload audio, transcribe & analyze
router.post('/upload', auth, upload.single('audio'), async (req, res) => {
  let audioFilePath = null;
  try {
    if (!req.file) {
      return res.status(400).json({ message: 'Không có file audio' });
    }

    audioFilePath = req.file.path;
    const { topicId, duration } = req.body;

    if (!topicId) {
      return res.status(400).json({ message: 'topicId là bắt buộc' });
    }

    const topic = await Topic.findById(topicId);
    if (!topic) {
      return res.status(404).json({ message: 'Không tìm thấy topic' });
    }

    // Step 1: Transcribe audio with OpenAI Whisper
    const transcript = await transcribeAudio(audioFilePath);

    if (!transcript || transcript.trim().length === 0) {
      return res.status(400).json({ message: 'Không thể nhận diện giọng nói. Vui lòng thử lại.' });
    }

    // Step 2: Analyze speech with GPT-4
    const feedback = await analyzeSpeech(
      transcript,
      topic.title,
      topic.prompt,
      topic.questions
    );

    // Step 3: Save recording
    const audioUrl = `/uploads/${req.file.filename}`;
    const recording = await Recording.create({
      userId: req.user._id,
      topicId: topic._id,
      audioUrl,
      duration: parseInt(duration) || 0,
      transcript,
      feedback,
    });

    // Populate topic info for response
    await recording.populate('topicId', 'title prompt level');

    res.status(201).json({
      id: recording._id,
      topicId: recording.topicId._id,
      topicTitle: recording.topicId.title,
      audioUrl: recording.audioUrl,
      duration: recording.duration,
      transcript: recording.transcript,
      feedback: recording.feedback,
      createdAt: recording.createdAt,
    });
  } catch (error) {
    // Clean up uploaded file on error
    if (audioFilePath && fs.existsSync(audioFilePath)) {
      fs.unlinkSync(audioFilePath);
    }
    res.status(500).json({ message: 'Lỗi khi xử lý recording', error: error.message });
  }
});

// GET /api/recordings - List user's recordings
router.get('/', auth, async (req, res) => {
  try {
    const { page = 1, limit = 20 } = req.query;
    const skip = (parseInt(page) - 1) * parseInt(limit);

    const [recordings, total] = await Promise.all([
      Recording.find({ userId: req.user._id })
        .populate('topicId', 'title prompt level')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(parseInt(limit)),
      Recording.countDocuments({ userId: req.user._id }),
    ]);

    const formatted = recordings.map((r) => ({
      id: r._id,
      topicId: r.topicId?._id,
      topicTitle: r.topicId?.title || 'Deleted Topic',
      audioUrl: r.audioUrl,
      duration: r.duration,
      transcript: r.transcript,
      feedback: r.feedback,
      createdAt: r.createdAt,
    }));

    res.json({
      recordings: formatted,
      total,
      page: parseInt(page),
      totalPages: Math.ceil(total / parseInt(limit)),
    });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server', error: error.message });
  }
});

// GET /api/recordings/:id - Get single recording
router.get('/:id', auth, async (req, res) => {
  try {
    const recording = await Recording.findOne({
      _id: req.params.id,
      userId: req.user._id,
    }).populate('topicId', 'title prompt level questions');

    if (!recording) {
      return res.status(404).json({ message: 'Không tìm thấy recording' });
    }

    res.json({
      id: recording._id,
      topicId: recording.topicId?._id,
      topicTitle: recording.topicId?.title || 'Deleted Topic',
      audioUrl: recording.audioUrl,
      duration: recording.duration,
      transcript: recording.transcript,
      feedback: recording.feedback,
      createdAt: recording.createdAt,
    });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server', error: error.message });
  }
});

// DELETE /api/recordings/:id
router.delete('/:id', auth, async (req, res) => {
  try {
    const recording = await Recording.findOneAndDelete({
      _id: req.params.id,
      userId: req.user._id,
    });

    if (!recording) {
      return res.status(404).json({ message: 'Không tìm thấy recording' });
    }

    // Clean up audio file
    const filePath = require('path').join(__dirname, '..', recording.audioUrl);
    if (fs.existsSync(filePath)) {
      fs.unlinkSync(filePath);
    }

    res.json({ message: 'Đã xóa recording thành công' });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server', error: error.message });
  }
});

module.exports = router;
