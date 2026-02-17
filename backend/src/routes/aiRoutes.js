const express = require('express');
const router = express.Router();
const aiService = require('../services/aiService');
const { protect } = require('../middleware/authMiddleware');

router.post('/chat', protect, async (req, res) => {
    try {
        const { message, context } = req.body;

        if (!message || typeof message !== 'string') {
            return res.status(400).json({ message: 'Message is required' });
        }

        const response = await aiService.generateChatResponse(message, context);
        res.json({ response });
    } catch (error) {
        console.error('AI chat error:', error);
        res.status(500).json({ message: 'Failed to generate response' });
    }
});

router.post('/reflection', protect, async (req, res) => {
    try {
        const reflection = await aiService.generateCBTReflection(req.body);
        res.json({ reflection });
    } catch (error) {
        console.error('AI reflection error:', error);
        res.status(500).json({ message: 'Failed to generate reflection' });
    }
});

module.exports = router;
