const mongoose = require('mongoose');

const topicSchema = new mongoose.Schema({
  title: {
    type: String,
    required: [true, 'Title is required'],
    trim: true,
  },
  prompt: {
    type: String,
    required: [true, 'Prompt is required'],
  },
  level: {
    type: String,
    enum: ['beginner', 'intermediate', 'advanced'],
    default: 'beginner',
  },
  duration: {
    type: String,
    default: '3-5 phút',
  },
  questions: [{
    type: String,
  }],
  tags: [{
    type: String,
  }],
  createdBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

topicSchema.index({ title: 'text', tags: 'text' });

module.exports = mongoose.model('Topic', topicSchema);
