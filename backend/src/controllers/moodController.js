const dbService = require('../services/dbService');
const aiService = require('../services/aiService');

exports.getAllMoods = async (req, res) => {
    try {
        // req.user is populated by authMiddleware
        const moods = await dbService.getAll('moods', req.user.id);
        res.json(moods);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Failed to fetch moods' });
    }
};

exports.createMood = async (req, res) => {
    try {
        const { moodLevel, emoji, color, note } = req.body;
        // userId comes from the token, ignore body userId for security
        const userId = req.user.id;

        // 1. Save Mood
        const newMood = await dbService.add({
            moodLevel,
            emoji,
            color,
            note,
            userId
        });

        // 2. AI Processing (Async)
        // We don't await this so the UI is snappy, but we update the record later.
        aiService.getReflection(emoji, note).then(async (reflection) => {
            // Update the record with reflection
            const db = await require('../config/db').getDB();
            await db.run(
                'UPDATE moods SET aiReflection = ?, reflectionGeneratedAt = ? WHERE id = ?',
                [reflection, new Date().toISOString(), newMood.id]
            );
        }).catch(console.error);

        res.status(201).json(newMood);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Failed to save mood' });
    }
};
