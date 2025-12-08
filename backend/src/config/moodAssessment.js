// src/config/moodAssessment.js

const dailyMoodQuestions = {
    // Questão principal (WHO-5 adaptado)
    primary: {
        question: "Como você se sentiu hoje?",
        scale: [
            { value: 1, emoji: "😢", label: "Muito mal", color: "#FF5459" },
            { value: 2, emoji: "😔", label: "Mal", color: "#E68161" },
            { value: 3, emoji: "😐", label: "Neutro", color: "#77797C" },
            { value: 4, emoji: "😊", label: "Bem", color: "#32B8C6" }, // Fixed label key typo from user prompt
            { value: 5, emoji: "😄", label: "Muito bem", color: "#218D8D" }
        ]
    },

    // Questões contextuais (aparecem baseadas no humor)
    contextual: {
        // Se humor <= 2, pergunta sobre sintomas depressivos (PHQ-9)
        depression: [
            {
                id: "interest",
                question: "Você teve interesse ou prazer em fazer as coisas hoje?",
                type: "boolean", // Sim/Não
                psychologicalDomain: "anhedonia" // Falta de prazer
            },
            {
                id: "energy",
                question: "Como estava sua energia hoje?",
                type: "scale_3", // Baixa/Média/Alta
                psychologicalDomain: "fatigue"
            },
            {
                id: "concentration",
                question: "Conseguiu se concentrar nas tarefas?",
                type: "boolean",
                psychologicalDomain: "cognitive_function"
            }
        ],

        // Se humor <= 2 OU usuário reportar "ansiedade", perguntas GAD-7
        anxiety: [
            {
                id: "worry",
                question: "Você se preocupou excessivamente hoje?",
                type: "boolean",
                psychologicalDomain: "excessive_worry"
            },
            {
                id: "restlessness",
                question: "Se sentiu inquieto(a) ou com dificuldade para relaxar?",
                type: "boolean",
                psychologicalDomain: "restlessness"
            }
        ]
    },

    // Pergunta aberta opcional (análise de sentimento pela IA)
    openEnded: {
        question: "Quer contar mais sobre seu dia? (opcional)",
        maxLength: 500,
        aiAnalysis: true // Usa Gemini para análise de sentimento
    }
};

module.exports = dailyMoodQuestions;
