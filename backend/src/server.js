const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');

dotenv.config();

// ─── Fail fast if JWT_SECRET is missing or weak ───
if (!process.env.JWT_SECRET || process.env.JWT_SECRET.length < 32) {
    console.error('FATAL: JWT_SECRET must be set in .env and be at least 32 characters long.');
    console.error('Generate one with: node -e "console.log(require(\'crypto\').randomBytes(64).toString(\'hex\'))"');
    process.exit(1);
}

// ─── Warn if AI_API_KEY is missing (AI features will fail gracefully) ───
if (!process.env.AI_API_KEY) {
    console.warn('WARNING: AI_API_KEY is not set. AI reflection and chat features will not work.');
}

const moodRoutes = require('./routes/moodRoutes');
const aiRoutes = require('./routes/aiRoutes');
const authRoutes = require('./routes/authRoutes');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use('/auth', authRoutes);
app.use('/api/mood', moodRoutes);
app.use('/api/ai', aiRoutes);

// Health Check
app.get('/', (req, res) => {
    res.send('MoodTrack API is running');
});

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
