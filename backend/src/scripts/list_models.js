const { GoogleGenerativeAI } = require("@google/generative-ai");
const dotenv = require('dotenv');
const path = require('path');

dotenv.config({ path: path.join(__dirname, '../../.env') });

async function listModels() {
    const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
    try {
        console.log("Listing models...");
        const model = genAI.getGenerativeModel({ model: "gemini-pro" }); // Dummy init to get access to client if needed, or just use correct API manually if SDK doesn't support list.
        // Actually SDK doesn't expose listModels directly on the main class easily in all versions, 
        // but let's try a direct fetch if SDK fails or assume standard models.
        // Wait, the SDK definitely has listModels on the *client* or manager? 
        // Let's checking documentation or source is hard...
        // I will try to use the raw API via fetch if I can't find it, but let's check package.json first.
    } catch (error) {
        // ...
    }
}
// Actually, it's safer to just check package.json first to know what version we are dealing with.
