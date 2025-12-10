const { getDB } = require('../config/db');

class DBService {
    async getAll(collection, userId = null) {
        const db = await getDB();

        if (userId && collection === 'moods') {
            return await db.all(`SELECT * FROM ${collection} WHERE userId = ?`, userId);
        }

        return await db.all(`SELECT * FROM ${collection}`);
    }

    async add(collection, entry) {
        // Handle legacy call signature
        if (typeof collection === 'object') {
            entry = collection;
            collection = 'moods';
        }

        const db = await getDB();

        // Add default fields
        const id = entry.id || Date.now().toString();

        if (collection === 'users') {
            const { name, email, password } = entry;
            await db.run(
                'INSERT INTO users (id, name, email, password) VALUES (?, ?, ?, ?)',
                [id, name, email, password]
            );
            return { id, name, email };
        }

        if (collection === 'moods') {
            const {
                date, moodLevel, emoji, color, note,
                aiReflection, reflectionGeneratedAt, userId
            } = entry;

            await db.run(
                `INSERT INTO moods (
                    id, date, moodLevel, emoji, color, note, 
                    aiReflection, reflectionGeneratedAt, userId
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
                [
                    id,
                    date || new Date().toISOString(),
                    moodLevel,
                    emoji,
                    color,
                    note,
                    aiReflection,
                    reflectionGeneratedAt,
                    userId
                ]
            );
            return entry;
        }

        throw new Error(`Collection ${collection} not supported in SQL Service`);
    }
}

module.exports = new DBService();
