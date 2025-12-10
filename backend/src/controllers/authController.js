const jwt = require('jsonwebtoken');
const dbService = require('../services/dbService');

const generateToken = (id) => {
    return jwt.sign({ id }, process.env.JWT_SECRET || 'secret', {
        expiresIn: '30d',
    });
};

const register = async (req, res) => {
    try {
        const { name, email, password } = req.body;

        // In SQL migration, getAll returns an array of rows
        const users = await dbService.getAll('users');

        // Check if user exists
        const userExists = users.find((user) => user.email === email);
        if (userExists) {
            return res.status(400).json({ message: 'User already exists' });
        }

        // Create and Save user
        // Note: In a real app, hash the password!
        const user = await dbService.add('users', {
            name,
            email,
            password
        });

        res.status(201).json({
            user: {
                id: user.id,
                name: user.name,
                email: user.email,
            },
            token: generateToken(user.id),
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error: ' + error.message });
    }
};

const login = async (req, res) => {
    try {
        const { email, password } = req.body;

        const users = await dbService.getAll('users');

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
        console.error(error);
        res.status(500).json({ message: 'Server error: ' + error.message });
    }
};

module.exports = { register, login };
