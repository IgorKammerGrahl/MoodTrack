const { GoogleGenerativeAI } = require("@google/generative-ai");
const dotenv = require('dotenv');
const path = require('path');

dotenv.config({ path: path.join(__dirname, '../../.env') });

async function testModel(modelName) {
    const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
    try {
        console.log(`Testing model: ${modelName}`);
        const model = genAI.getGenerativeModel({ model: modelName });
        const result = await model.generateContent("Say hello");
        console.log(`Success with ${modelName}:`, result.response.text());
        return true;
    } catch (error) {
        console.error(`Error with ${modelName}:`, error.message);
        return false;
    }
}

async function runTests() {
    const models = [
        "gemini-2.0-flash-lite-preview-02-05",
        "gemini-flash-latest",
        "gemini-pro-latest"
    ];
    for (const m of models) {
        await testModel(m);
    }
}

runTests();
