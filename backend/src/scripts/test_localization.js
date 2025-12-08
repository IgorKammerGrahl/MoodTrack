const aiService = require('../services/aiService');

async function testLocalization() {
    console.log("Testing AI Localization...");
    const mockData = {
        moodLevel: 2,
        contextualAnswers: {
            energy: "low",
            interest: false
        },
        note: "Estou me sentindo muito cansado e sem vontade de fazer nada."
    };

    try {
        const response = await aiService.generateCBTReflection(mockData);
        console.log("\n--- AI Response ---");
        console.log(response);
        console.log("-------------------\n");
    } catch (error) {
        console.error("Error:", error);
    }
}

testLocalization();
