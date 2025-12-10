const sqlite3 = require('sqlite3').verbose();
const { open } = require('sqlite');
const path = require('path');

const DB_PATH = path.join(__dirname, '../../database.sqlite');

let dbInstance = null;

async function getDB() {
    if (dbInstance) return dbInstance;

    dbInstance = await open({
        filename: DB_PATH,
        driver: sqlite3.Database
    });

    await dbInstance.exec(`
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
            reflectionGeneratedAt TEXT,
            userId TEXT
        );
    `);

    return dbInstance;
}

module.exports = { getDB };
