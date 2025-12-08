const jwt = require('jsonwebtoken');

// Mock database
const users = [];

const generateToken = (id) => {
    return jwt.sign({ id }, process.env.JWT_SECRET || 'secret', {
        expiresIn: '30d',
    });
};

const register = async (req, res) => {
    try {
        const { name, email, password } = req.body;

        // Check if user exists
        const userExists = users.find((user) => user.email === email);
        if (userExists) {
            return res.status(400).json({ message: 'User already exists' });
        }

        // Create user
        const user = {
            id: Date.now().toString(),
            name,
            email,
            password, // In production, hash this!
        };

        users.push(user);

        res.status(201).json({
            user: {
                id: user.id,
                name: user.name,
                email: user.email,
            },
            token: generateToken(user.id),
        });
    } catch (error) {
        res.status(500).json({ message: 'Server error' });
    }
};

const login = async (req, res) => {
    try {
        const { email, password } = req.body;

        // Check user
        const user = users.find((user) => user.email === email);

        if (user && user.password === password) {
            res.json({
                user: {
                    id: user.id,
                    name: user.name,
                    email: user.email,
                },
                token: generateToken(user.id),
            });
        } else {
            res.status(401).json({ message: 'Invalid email or password' });
        }
    } catch (error) {
        res.status(500).json({ message: 'Server error' });
    }
};

module.exports = { register, login };
