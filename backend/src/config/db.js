const sqlite3 = require('sqlite3').verbose();
const { open } = require('sqlite');
const path = require('node:path');

const DB_PATH = path.join(__dirname, '../../database.sqlite');

let dbInstance = null;
let dbPromise = null;

async function initDB() {
    const db = await open({
        filename: DB_PATH,
        driver: sqlite3.Database
    });

    // Enable foreign key enforcement
    await db.exec('PRAGMA foreign_keys = ON;');

    await db.exec(`
        CREATE TABLE IF NOT EXISTS users (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            email TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL,
            refreshToken TEXT,
            created_at TEXT NOT NULL DEFAULT (datetime('now')),
            updated_at TEXT NOT NULL DEFAULT (datetime('now'))
        );

        CREATE TABLE IF NOT EXISTS moods (
            id TEXT PRIMARY KEY,
            date TEXT NOT NULL,
            moodLevel INTEGER NOT NULL,
            emoji TEXT NOT NULL,
            color TEXT NOT NULL,
            note TEXT,
            aiReflection TEXT,
            reflectionStatus TEXT DEFAULT NULL,
            reflectionGeneratedAt TEXT,
            userId TEXT NOT NULL,
            created_at TEXT NOT NULL DEFAULT (datetime('now')),
            updated_at TEXT NOT NULL DEFAULT (datetime('now')),
            FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
        );

        CREATE INDEX IF NOT EXISTS idx_moods_userId ON moods(userId);
        CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

        -- Auto-update updated_at on moods modification
        CREATE TRIGGER IF NOT EXISTS update_moods_timestamp
        AFTER UPDATE ON moods
        BEGIN
            UPDATE moods SET updated_at = datetime('now') WHERE id = NEW.id;
        END;
    `);

    // Migration: add refreshToken column if it doesn't exist
    try {
        await db.exec('ALTER TABLE users ADD COLUMN refreshToken TEXT;');
    } catch (error) {
        if (!error.message?.includes('duplicate column name')) {
            console.warn('Migration note:', error.message);
        }
    }

    dbInstance = db;
    return db;
}

async function getDB() {
    if (dbInstance) return dbInstance;
    if (!dbPromise) {
        dbPromise = initDB();
    }
    return dbPromise;
}

module.exports = { getDB };

