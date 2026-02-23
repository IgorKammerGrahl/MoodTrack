const crypto = require('node:crypto');
const { getDB } = require('../config/db');

const ALLOWED_TABLES = new Set(['users', 'moods']);

class DBService {
    _validateTable(collection) {
        if (!ALLOWED_TABLES.has(collection)) {
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
        const now = new Date().toISOString();

        if (collection === 'users') {
            const { name, email, password } = entry;
            await db.run(
                `INSERT INTO users (id, name, email, password, created_at, updated_at)
                 VALUES (?, ?, ?, ?, ?, ?)`,
                [id, name, email, password, now, now]
            );
            return { id, name, email, created_at: now, updated_at: now };
        }

        if (collection === 'moods') {
            const {
                date, moodLevel, emoji, color, note,
                aiReflection, reflectionGeneratedAt, userId
            } = entry;

            await db.run(
                `INSERT INTO moods (
                    id, date, moodLevel, emoji, color, note,
                    aiReflection, reflectionGeneratedAt, userId,
                    created_at, updated_at
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
                [
                    id,
                    date || now,
                    moodLevel,
                    emoji,
                    color,
                    note,
                    aiReflection,
                    reflectionGeneratedAt,
                    userId,
                    now,
                    now,
                ]
            );
            return {
                id, date: date || now, moodLevel, emoji, color, note, userId,
                created_at: now, updated_at: now,
            };
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

    // --- Refresh Token ---

    async updateRefreshToken(userId, token) {
        const db = await getDB();
        await db.run(
            'UPDATE users SET refreshToken = ? WHERE id = ?',
            [token, userId]
        );
    }

    async findUserByRefreshToken(token) {
        const db = await getDB();
        return db.get(
            'SELECT id, name, email FROM users WHERE refreshToken = ?',
            token
        );
    }
}

module.exports = new DBService();

