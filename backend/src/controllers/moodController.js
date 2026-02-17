const dbService = require('../services/dbService');
const aiService = require('../services/aiService');

exports.getAllMoods = async (req, res) => {
    try {
        const moods = await dbService.getAll('moods', req.user.id);
        res.json(moods);
    } catch (error) {
        console.error('Failed to fetch moods:', error);
        res.status(500).json({ error: 'Failed to fetch moods' });
    }
};

exports.createMood = async (req, res) => {
    try {
        const { moodLevel, emoji, color, note } = req.body;
        const userId = req.user.id;

        // Input validation
        if (moodLevel === undefined || !emoji || color === undefined) {
            return res.status(400).json({ error: 'moodLevel, emoji, and color are required' });
        }

        if (typeof moodLevel !== 'number' || moodLevel < 1 || moodLevel > 5) {
            return res.status(400).json({ error: 'moodLevel must be between 1 and 5' });
        }

        // 1. Save Mood
        const newMood = await dbService.add('moods', {
            moodLevel,
            emoji,
            color,
            note,
            userId,
        });

        // 2. Mark as pending and process AI reflection
        await dbService.updateMoodReflectionStatus(newMood.id, 'pending');

        // Fire-and-forget with proper error recovery
        processReflection(newMood.id, moodLevel, note).catch((err) => {
            console.error('AI reflection processing error:', err);
        });

        res.status(201).json(newMood);
    } catch (error) {
        console.error('Failed to save mood:', error);
        res.status(500).json({ error: 'Failed to save mood' });
    }
};

/**
 * Process AI reflection with retry-safe status tracking.
 * If it fails, status is set to 'failed' so it can be retried later.
 */
async function processReflection(moodId, moodLevel, note) {
    try {
        const reflection = await aiService.getReflection(moodLevel, note);
        await dbService.updateMoodReflection(moodId, reflection, 'completed');
    } catch (err) {
        console.error(`AI reflection failed for mood ${moodId}:`, err.message);
        try {
            await dbService.updateMoodReflectionStatus(moodId, 'failed');
        } catch (dbErr) {
            console.error(`Failed to update reflection status for mood ${moodId}:`, dbErr.message);
        }
    }
}
