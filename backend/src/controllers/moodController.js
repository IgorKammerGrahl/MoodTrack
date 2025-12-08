const dbService = require('../services/dbService');

exports.getAllMoods = (req, res) => {
    try {
        const moods = dbService.getAll();
        res.json(moods);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

exports.createMood = (req, res) => {
    try {
        const newMood = dbService.add(req.body);
        res.status(201).json(newMood);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};
