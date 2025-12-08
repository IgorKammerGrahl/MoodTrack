const { GoogleGenerativeAI } = require("@google/generative-ai");
const dotenv = require('dotenv');
const ethicsConfig = require('../config/ethics');

dotenv.config();

// Initialize Gemini
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

class EvidenceBasedAI {

    async generateCBTReflection(userMoodData) {
        const { moodLevel, contextualAnswers, note } = userMoodData;

        // 1. Crisis Detection
        if (this._detectCrisis(note)) {
            return ethicsConfig.crisisResponse.message;
        }

        const domain = this._identifyPsychologicalDomain(contextualAnswers || {});
        const cbtTechnique = this._selectCBTTechnique(domain);

        const prompt = `
Você é um assistente de bem-estar emocional treinado em Terapia Cognitivo-Comportamental (TCC). Você DEVE responder em Português (pt-BR).

**Contexto do Usuário:**
- Nível de Humor: ${moodLevel}/5
- Domínio Afetado: ${domain}
- Nota do Usuário: "${note || 'Nenhuma nota fornecida'}"

**Técnica TCC Recomendada:** ${cbtTechnique.name}

**Sua Tarefa:**
1. Valide os sentimentos do usuário (empatia).
2. Ofereça UMA reflexão baseada em ${cbtTechnique.name}.
3. Sugira UMA ação concreta e pequena (micro-passo).
4. Use linguagem acolhedora e não-julgadora.
5. NUNCA diagnostique ou use termos clínicos.

**Restrições:**
- Máximo 150 palavras.
- Evite: "você tem depressão", "transtorno", "diagnóstico".
- Foque em: ações práticas, validação emocional, esperança realista.

**Formato da Resposta:**
💙 [Validação Empática]

💡 [Reflexão TCC Específica]

🌱 [Micro-ação Sugerida]
`;

        try {
            const model = genAI.getGenerativeModel({ model: "gemini-flash-latest" });
            const result = await model.generateContent(prompt);
            const response = await result.response;
            return response.text();
        } catch (error) {
            console.error("Error generating AI content:", error);
            return "Estou com dificuldades para conectar agora, mas lembre-se que seus sentimentos são válidos. Tente respirar fundo.";
        }
    }

    _detectCrisis(note) {
        if (!note) return false;
        const lowerNote = note.toLowerCase();
        return ethicsConfig.crisisKeywords.some(keyword => lowerNote.includes(keyword));
    }

    _identifyPsychologicalDomain(answers) {
        if (answers.interest === false) return "anhedonia";
        if (answers.worry === true) return "excessive_worry";
        if (answers.energy === "low" || answers.energy === "baixa") return "fatigue";
        if (answers.concentration === false) return "cognitive_dysfunction";
        return "general_low_mood";
    }

    _selectCBTTechnique(domain) {
        const techniques = {
            anhedonia: {
                name: "Ativação Comportamental",
                description: "Aumentar atividades prazerosas"
            },
            excessive_worry: {
                name: "Reestruturação Cognitiva",
                description: "Desafiar pensamentos catastróficos"
            },
            fatigue: {
                name: "Ativação Comportamental + Higiene do Sono",
                description: "Pequenas atividades + rotina de sono"
            },
            cognitive_dysfunction: {
                name: "Resolução de Problemas",
                description: "Dividir tarefas em micro-passos"
            },
            general_low_mood: {
                name: "Autocompaixão (Mindful Self-Compassion)",
                description: "Autocompaixão e validação emocional"
            }
        };

        return techniques[domain] || techniques.general_low_mood;
    }
}

module.exports = new EvidenceBasedAI();
