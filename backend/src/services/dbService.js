const fs = require('fs');
const path = require('path');

const DB_PATH = path.join(__dirname, '../data/moods.json');

// Ensure DB file exists
if (!fs.existsSync(DB_PATH)) {
    fs.writeFileSync(DB_PATH, JSON.stringify([]));
}

class DBService {
    getAll() {
        const data = fs.readFileSync(DB_PATH);
        return JSON.parse(data);
    }

    add(entry) {
        const data = this.getAll();
        const newEntry = { id: Date.now().toString(), date: new Date().toISOString(), ...entry };
        data.push(newEntry);
        fs.writeFileSync(DB_PATH, JSON.stringify(data, null, 2));
        return newEntry;
    }
}

module.exports = new DBService();
