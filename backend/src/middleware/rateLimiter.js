const rateLimit = require('express-rate-limit');

// AI endpoints: 20 requests per 15 minutes per user
const aiLimiter = rateLimit({
    windowMs: 15 * 60 * 1000,
    max: 20,
    keyGenerator: (req) => req.user?.id || req.ip,
    message: { message: 'Too many AI requests. Please try again later.' },
    standardHeaders: true,
    legacyHeaders: false,
});

// Auth endpoints: 5 attempts per 15 minutes per IP (brute force protection)
const authLimiter = rateLimit({
    windowMs: 15 * 60 * 1000,
    max: 5,
    message: { message: 'Too many login attempts. Please try again later.' },
    standardHeaders: true,
    legacyHeaders: false,
});

// General API: 100 requests per 15 minutes per user
const generalLimiter = rateLimit({
    windowMs: 15 * 60 * 1000,
    max: 100,
    keyGenerator: (req) => req.user?.id || req.ip,
    message: { message: 'Too many requests. Please try again later.' },
    standardHeaders: true,
    legacyHeaders: false,
});

module.exports = { aiLimiter, authLimiter, generalLimiter };
