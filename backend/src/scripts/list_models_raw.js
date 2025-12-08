const dotenv = require('dotenv');
const path = require('path');

dotenv.config({ path: path.join(__dirname, '../../.env') });

const API_KEY = process.env.GEMINI_API_KEY;
const URL = `https://generativelanguage.googleapis.com/v1beta/models?key=${API_KEY}`;

async function listModels() {
    try {
        const response = await fetch(URL);
        const data = await response.json();

        if (data.error) {
            console.error("API Error:", data.error);
            return;
        }

        if (data.models) {
            console.log("Available Models:");
            data.models.forEach(model => {
                console.log(`- ${model.name}`);
                console.log(`  Supported methods: ${model.supportedGenerationMethods}`);
            });
        } else {
            console.log("No models found or unexpected format:", data);
        }
    } catch (error) {
        console.error("Network Error:", error);
    }
}

listModels();
