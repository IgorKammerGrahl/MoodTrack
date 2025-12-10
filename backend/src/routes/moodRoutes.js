const express = require('express');
const router = express.Router();
const moodController = require('../controllers/moodController');
const { protect } = require('../middleware/authMiddleware');

router.get('/', protect, moodController.getAllMoods);
router.post('/', protect, moodController.createMood);

module.exports = router;
