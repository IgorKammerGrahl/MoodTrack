// src/services/suggestionEngine.js

class IntelligentSuggestionEngine {

    /**
     * Gera sugestões baseadas em contexto + hora + padrão
     * (Simulação simplificada para o MVP)
     */
    generateContextualSuggestions(userContext) {
        const now = new Date();
        const hour = now.getHours();
        const { moodLevel, answers } = userContext;

        // 1. Sugestões baseadas em hora do dia + humor
        if (hour >= 6 && hour < 12 && moodLevel <= 2) {
            return {
                type: "behavioral_activation",
                suggestion: "☀️ Bom dia! Que tal 5 minutos de sol pela janela? A luz matinal ajuda o humor.",
                action: "set_reminder",
                evidence: "Exposição à luz solar matinal reduz sintomas depressivos"
            };
        }

        if (hour >= 12 && hour < 14 && answers?.energy === "low") {
            return {
                type: "energy_boost",
                suggestion: "🚶 Uma caminhada de 10 minutos pode dar energia sem café.",
                action: "start_timer",
                evidence: "Exercício leve aumenta energia mais que cafeína"
            };
        }

        if (hour >= 20 && answers?.worry === true) {
            return {
                type: "sleep_hygiene",
                suggestion: "🌙 Preocupações à noite? Tente anotar tudo num papel para tirar da cabeça.",
                action: "wind_down_mode",
                evidence: "Técnica de 'worry time' melhora latência do sono"
            };
        }

        // 2. Sugestões baseadas em padrões emocionais (Simulado)
        if (moodLevel <= 2) {
            return {
                type: "problem_solving",
                suggestion: "💭 Dia difícil? Vamos dividir um problema em passos menores?",
                action: "open_problem_solver",
                evidence: "Problem-Solving Therapy eficaz para depressão"
            };
        }

        return this._getGeneralWellnessTip();
    }

    _getGeneralWellnessTip() {
        const tips = [
            {
                suggestion: "💧 Já bebeu água hoje? A hidratação afeta diretamente o humor.",
                evidence: "Desidratação leve pode causar fadiga e ansiedade"
            },
            {
                suggestion: "🫁 Tente a respiração 4-7-8: inspire 4s, segure 7s, expire 8s.",
                evidence: "Ativa o sistema parassimpático e reduz estresse"
            },
            {
                suggestion: "📝 Escrever 3 coisas boas do dia pode mudar seu foco.",
                evidence: "Diário de gratidão aumenta bem-estar subjetivo"
            }
        ];
        return tips[Math.floor(Math.random() * tips.length)];
    }
}

module.exports = new IntelligentSuggestionEngine();
