const express = require('express');
const router = express.Router();
const moodController = require('../controllers/moodController');

router.get('/', moodController.getAllMoods);
router.post('/', moodController.createMood);

module.exports = router;
