const sqlite3 = require('sqlite3').verbose();
const { open } = require('sqlite');
const path = require('path');

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
            password TEXT NOT NULL
        );

        CREATE TABLE IF NOT EXISTS moods (
            id TEXT PRIMARY KEY,
            date TEXT NOT NULL,
            moodLevel INTEGER NOT NULL,
            emoji TEXT NOT NULL,
            color INTEGER NOT NULL,
            note TEXT,
            aiReflection TEXT,
            reflectionStatus TEXT DEFAULT NULL,
            reflectionGeneratedAt TEXT,
            userId TEXT NOT NULL,
            FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
        );

        CREATE INDEX IF NOT EXISTS idx_moods_userId ON moods(userId);
        CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
    `);

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
