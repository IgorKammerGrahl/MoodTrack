const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const crypto = require('crypto');
const dbService = require('../services/dbService');

const SALT_ROUNDS = 12;

const generateAccessToken = (id) => {
    return jwt.sign({ id }, process.env.JWT_SECRET, {
        expiresIn: '1h',
    });
};

const generateRefreshToken = () => {
    return crypto.randomBytes(64).toString('hex');
};

const register = async (req, res) => {
    try {
        const { name, email, password } = req.body;

        // Input validation
        if (!name || !email || !password) {
            return res.status(400).json({ message: 'Name, email, and password are required' });
        }

        if (typeof email !== 'string' || !email.includes('@')) {
            return res.status(400).json({ message: 'Invalid email format' });
        }

        if (typeof password !== 'string' || password.length < 8) {
            return res.status(400).json({ message: 'Password must be at least 8 characters' });
        }

        // Check if user exists by direct query (not full table scan)
        const userExists = await dbService.findUserByEmail(email);
        if (userExists) {
            return res.status(400).json({ message: 'User already exists' });
        }

        // Hash password before storing
        const hashedPassword = await bcrypt.hash(password, SALT_ROUNDS);

        const user = await dbService.add('users', {
            name: name.trim(),
            email: email.toLowerCase().trim(),
            password: hashedPassword,
        });

        // Generate and store refresh token
        const refreshToken = generateRefreshToken();
        await dbService.updateRefreshToken(user.id, refreshToken);

        return res.status(201).json({
            user: {
                id: user.id,
                name: user.name,
                email: user.email,
            },
            token: generateAccessToken(user.id),
            refreshToken,
        });
    } catch (error) {
        // Handle race condition: UNIQUE constraint violation
        if (error.message && error.message.includes('UNIQUE constraint failed')) {
            return res.status(400).json({ message: 'User already exists' });
        }
        console.error('Registration error:', error);
        return res.status(500).json({ message: 'An internal error occurred' });
    }
};

const login = async (req, res) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).json({ message: 'Email and password are required' });
        }

        // Direct query by email instead of full table scan
        const user = await dbService.findUserByEmail(email.toLowerCase().trim());

        if (!user) {
            return res.status(401).json({ message: 'Invalid email or password' });
        }

        // Compare with bcrypt instead of plaintext
        const isMatch = await bcrypt.compare(password, user.password);

        if (!isMatch) {
            return res.status(401).json({ message: 'Invalid email or password' });
        }

        // Generate and store refresh token
        const refreshToken = generateRefreshToken();
        await dbService.updateRefreshToken(user.id, refreshToken);

        return res.json({
            user: {
                id: user.id,
                name: user.name,
                email: user.email,
            },
            token: generateAccessToken(user.id),
            refreshToken,
        });
    } catch (error) {
        console.error('Login error:', error);
        return res.status(500).json({ message: 'An internal error occurred' });
    }
};

const refresh = async (req, res) => {
    try {
        const { refreshToken } = req.body;

        if (!refreshToken) {
            return res.status(400).json({ message: 'Refresh token is required' });
        }

        const user = await dbService.findUserByRefreshToken(refreshToken);

        if (!user) {
            return res.status(401).json({ message: 'Invalid refresh token' });
        }

        // Rotate refresh token for security
        const newRefreshToken = generateRefreshToken();
        await dbService.updateRefreshToken(user.id, newRefreshToken);

        return res.json({
            token: generateAccessToken(user.id),
            refreshToken: newRefreshToken,
        });
    } catch (error) {
        console.error('Token refresh error:', error);
        return res.status(500).json({ message: 'An internal error occurred' });
    }
};

module.exports = { register, login, refresh };

