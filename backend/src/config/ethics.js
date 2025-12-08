// src/config/ethics.js

const ethicsConfig = {
    // 1. Avisos obrigatórios na primeira abertura
    disclaimers: [
        "✅ Este app NÃO substitui psicólogo ou psiquiatra",
        "✅ Não fazemos diagnósticos clínicos",
        "✅ Em crise, ligue CVV 188 (gratuito, 24h)",
        "✅ Seus dados são privados e criptografados"
    ],

    // 2. Detecção de crise (palavras-chave + IA)
    crisisKeywords: [
        "suicídio", "me matar", "acabar com tudo",
        "não aguento mais", "quero morrer", "desesperado",
        "sem saída", "tirar minha vida"
    ],

    // 3. Resposta automática em caso de crise
    crisisResponse: {
        message: `
🆘 **Você não está sozinho**

Se você está pensando em se machucar, busque ajuda AGORA:

📞 **CVV - 188** (24h, gratuito, sigiloso)
🏥 **SAMU - 192** (emergências)
💙 Sua vida importa. Profissionais podem ajudar.
    `,
        disableChat: true, // Força usuário a ver recursos
        showEmergencyContacts: true
    },

    // 4. Limites da IA
    aiLimits: {
        noDiagnosis: true, // Nunca dizer "você tem X"
        noMedication: true, // Nunca sugerir remédios
        noProfessionalAdvice: true, // Sempre recomendar profissional se grave
        maxMessagesPerDay: 20 // Evitar dependência
    }
};

module.exports = ethicsConfig;
