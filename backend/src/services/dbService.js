const crypto = require('crypto');
const { getDB } = require('../config/db');

const ALLOWED_TABLES = ['users', 'moods'];

class DBService {
    _validateTable(collection) {
        if (!ALLOWED_TABLES.includes(collection)) {
            throw new Error(`Invalid table: ${collection}`);
        }
    }

    async getAll(collection, userId = null) {
        this._validateTable(collection);
        const db = await getDB();

        if (userId && collection === 'moods') {
            return db.all('SELECT * FROM moods WHERE userId = ?', userId);
        }

        return db.all(`SELECT * FROM ${collection}`);
    }

    async findUserByEmail(email) {
        const db = await getDB();
        return db.get('SELECT * FROM users WHERE email = ?', email);
    }

    async findUserById(id) {
        const db = await getDB();
        return db.get('SELECT id, name, email FROM users WHERE id = ?', id);
    }

    async add(collection, entry) {
        // Handle legacy call signature
        if (typeof collection === 'object') {
            entry = collection;
            collection = 'moods';
        }

        this._validateTable(collection);
        const db = await getDB();

        const id = entry.id || crypto.randomUUID();

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
            return { id, date: date || new Date().toISOString(), moodLevel, emoji, color, note, userId };
        }

        throw new Error(`Collection ${collection} not supported`);
    }

    async updateMoodReflection(moodId, reflection, status) {
        const db = await getDB();
        await db.run(
            'UPDATE moods SET aiReflection = ?, reflectionStatus = ?, reflectionGeneratedAt = ? WHERE id = ?',
            [reflection, status, new Date().toISOString(), moodId]
        );
    }

    async updateMoodReflectionStatus(moodId, status) {
        const db = await getDB();
        await db.run(
            'UPDATE moods SET reflectionStatus = ? WHERE id = ?',
            [status, moodId]
        );
    }
}

module.exports = new DBService();
