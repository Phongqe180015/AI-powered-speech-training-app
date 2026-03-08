const mongoose = require('mongoose');

const feedbackSchema = new mongoose.Schema({
  overall: { type: Number, min: 0, max: 10, default: 0 },
  fluency: { type: Number, min: 0, max: 10, default: 0 },
  pronunciation: { type: Number, min: 0, max: 10, default: 0 },
  grammar: { type: Number, min: 0, max: 10, default: 0 },
  vocabulary: { type: Number, min: 0, max: 10, default: 0 },
  coherence: { type: Number, min: 0, max: 10, default: 0 },
  strengths: [String],
  issues: [String],
  suggestions: [String],
}, { _id: false });

const recordingSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  topicId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Topic',
    required: true,
  },
  audioUrl: {
    type: String,
    required: true,
  },
  duration: {
    type: Number,
    default: 0,
  },
  transcript: {
    type: String,
    default: '',
  },
  feedback: {
    type: feedbackSchema,
    default: () => ({}),
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

recordingSchema.index({ userId: 1, createdAt: -1 });

module.exports = mongoose.model('Recording', recordingSchema);
