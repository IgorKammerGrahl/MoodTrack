const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const moodRoutes = require('./routes/moodRoutes');
const aiRoutes = require('./routes/aiRoutes');
const authRoutes = require('./routes/authRoutes');

dotenv.config();

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
