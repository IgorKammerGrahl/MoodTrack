const express = require('express');
const router = express.Router();
const aiService = require('../services/aiService');

router.post('/reflection', async (req, res) => {
    try {
        const reflection = await aiService.generateCBTReflection(req.body);
        res.json({ reflection });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

module.exports = router;
