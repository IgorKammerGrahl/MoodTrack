const express = require('express');
const router = express.Router();
const aiService = require('../services/aiService');

router.post('/chat', async (req, res) => {
    try {
        const { message, context } = req.body;
        const response = await aiService.generateChatResponse(message, context);
        res.json({ response });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

router.post('/reflection', async (req, res) => {
    try {
        const reflection = await aiService.generateCBTReflection(req.body);
        res.json({ reflection });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

module.exports = router;
