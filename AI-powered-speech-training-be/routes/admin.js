const express = require('express');
const User = require('../models/User');
const Topic = require('../models/Topic');
const Recording = require('../models/Recording');
const { auth, adminOnly } = require('../middleware/auth');

const router = express.Router();

// GET /api/admin/stats - Dashboard statistics
router.get('/stats', auth, adminOnly, async (req, res) => {
  try {
    const now = new Date();
    const startOfWeek = new Date(now);
    startOfWeek.setDate(now.getDate() - now.getDay() + 1); // Monday
    startOfWeek.setHours(0, 0, 0, 0);

    const lastWeekStart = new Date(startOfWeek);
    lastWeekStart.setDate(lastWeekStart.getDate() - 7);

    const [
      totalUsers,
      totalTopics,
      totalRecordings,
      weekRecordings,
      lastWeekRecordings,
      avgScoreResult,
      lastWeekAvgResult,
    ] = await Promise.all([
      User.countDocuments({ role: 'user' }),
      Topic.countDocuments(),
      Recording.countDocuments(),
      Recording.countDocuments({ createdAt: { $gte: startOfWeek } }),
      Recording.countDocuments({ createdAt: { $gte: lastWeekStart, $lt: startOfWeek } }),
      Recording.aggregate([
        { $group: { _id: null, avg: { $avg: '$feedback.overall' } } },
      ]),
      Recording.aggregate([
        { $match: { createdAt: { $gte: lastWeekStart, $lt: startOfWeek } } },
        { $group: { _id: null, avg: { $avg: '$feedback.overall' } } },
      ]),
    ]);

    const avgScore = avgScoreResult[0]?.avg || 0;
    const lastWeekAvg = lastWeekAvgResult[0]?.avg || 0;

    // Weekly activity (recordings per day for last 7 days)
    const weeklyActivity = await Recording.aggregate([
      { $match: { createdAt: { $gte: startOfWeek } } },
      {
        $group: {
          _id: { $dayOfWeek: '$createdAt' },
          count: { $sum: 1 },
        },
      },
      { $sort: { _id: 1 } },
    ]);

    // Map day numbers to labels (1=Sunday, 2=Monday..7=Saturday)
    const dayLabels = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    const activityMap = {};
    weeklyActivity.forEach((d) => {
      activityMap[d._id] = d.count;
    });
    const weeklyData = dayLabels.map((label, i) => ({
      day: label,
      count: activityMap[i + 1] || 0,
    }));

    // Calculate changes
    const weekChange = lastWeekRecordings > 0
      ? Math.round(((weekRecordings - lastWeekRecordings) / lastWeekRecordings) * 100)
      : weekRecordings > 0 ? 100 : 0;

    res.json({
      totalUsers,
      totalTopics,
      totalRecordings,
      weekRecordings,
      weekChange,
      avgScore: Math.round(avgScore * 10) / 10,
      avgScoreChange: Math.round((avgScore - lastWeekAvg) * 10) / 10,
      weeklyActivity: weeklyData,
    });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server', error: error.message });
  }
});

module.exports = router;
