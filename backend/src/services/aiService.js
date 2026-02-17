const ethicsConfig = require('../config/ethics');

const GROQ_URL = 'https://api.groq.com/openai/v1/chat/completions';
const GROQ_MODEL = 'llama3-8b-8192';

class EvidenceBasedAI {

    /**
     * Send a chat completion request to Groq.
     * Returns the plain-text assistant response, or a fallback on any error.
     */
    async _callGroq(systemPrompt, userMessage, fallback) {
        const apiKey = process.env.AI_API_KEY;
        if (!apiKey) {
            console.warn('AI_API_KEY is not set — skipping AI call.');
            return fallback;
        }

        try {
            const res = await fetch(GROQ_URL, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${apiKey}`,
                },
                body: JSON.stringify({
                    model: GROQ_MODEL,
                    messages: [
                        { role: 'system', content: systemPrompt },
                        { role: 'user', content: userMessage },
                    ],
                    temperature: 0.7,
                    max_tokens: 512,
                }),
            });

            if (!res.ok) {
                const errBody = await res.text();
                console.error(`Groq API error ${res.status}:`, errBody);
                return fallback;
            }

            const data = await res.json();
            const text = data?.choices?.[0]?.message?.content;
            return text ? text.trim() : fallback;
        } catch (error) {
            console.error('Groq API request failed:', error.message);
            return fallback;
        }
    }

    // ─── Public API (signatures unchanged) ───────────────────────────

    /**
     * Adapter method called by moodController.createMood.
     * Wraps generateCBTReflection with a simpler signature.
     */
    async getReflection(moodLevel, note) {
        return this.generateCBTReflection({
            moodLevel,
            contextualAnswers: {},
            note: note || '',
        });
    }

    async generateChatResponse(message, context = {}) {
        // Crisis Detection in chat
        if (this._detectCrisis(message)) {
            return ethicsConfig.crisisResponse.message;
        }

        const contextInfo = context.recentMood
            ? `Humor recente do usuário: ${context.recentMood}/5`
            : '';

        const systemPrompt = `Você é um assistente de bem-estar emocional treinado em Terapia Cognitivo-Comportamental (TCC). Você DEVE responder em Português (pt-BR).

Regras:
1. Responda de forma empática e acolhedora.
2. Use princípios da TCC quando relevante (validação emocional, reestruturação cognitiva, ações práticas).
3. Faça perguntas reflexivas quando apropriado.
4. Sugira micro-ações práticas quando o usuário demonstrar necessidade.
5. NUNCA diagnostique ou use termos clínicos.

Restrições:
- Máximo 100 palavras.
- Evite: "você tem depressão", "transtorno", "diagnóstico".
- Foque em: validação, esperança realista, ações práticas.
- Tom: conversacional, gentil, não-julgador.

Responda de forma natural, como um amigo compassivo e bem informado sobre saúde mental.`;

        const userContent = contextInfo
            ? `${contextInfo}\n\n${message}`
            : message;

        return this._callGroq(
            systemPrompt,
            userContent,
            'Estou tendo dificuldades para conectar agora, mas estou aqui para ouvir. Como você está se sentindo?'
        );
    }

    async generateCBTReflection(userMoodData) {
        const { moodLevel, contextualAnswers, note } = userMoodData;

        // Crisis Detection
        if (this._detectCrisis(note)) {
            return ethicsConfig.crisisResponse.message;
        }

        const domain = this._identifyPsychologicalDomain(contextualAnswers || {});
        const cbtTechnique = this._selectCBTTechnique(domain);

        const systemPrompt = `Você é um assistente de bem-estar emocional treinado em Terapia Cognitivo-Comportamental (TCC). Você DEVE responder em Português (pt-BR).

Regras:
1. Valide os sentimentos do usuário (empatia).
2. Ofereça UMA reflexão baseada em ${cbtTechnique.name}.
3. Sugira UMA ação concreta e pequena (micro-passo).
4. Use linguagem acolhedora e não-julgadora.
5. NUNCA diagnostique ou use termos clínicos.

Restrições:
- Máximo 150 palavras.
- Evite: "você tem depressão", "transtorno", "diagnóstico".
- Foque em: ações práticas, validação emocional, esperança realista.

Formato da Resposta:
💙 [Validação Empática]

💡 [Reflexão TCC Específica]

🌱 [Micro-ação Sugerida]`;

        const userContent = `Nível de Humor: ${moodLevel}/5
Domínio Afetado: ${domain}
Técnica TCC Recomendada: ${cbtTechnique.name}
Nota do Usuário: "${note || 'Nenhuma nota fornecida'}"`;

        return this._callGroq(
            systemPrompt,
            userContent,
            'Estou com dificuldades para conectar agora, mas lembre-se que seus sentimentos são válidos. Tente respirar fundo.'
        );
    }

    // ─── Internal helpers (unchanged) ────────────────────────────────

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
