# MoodTrack 🧠✨

**MoodTrack** é uma aplicação mobile desenvolvida em **Flutter** para rastreamento de bem-estar emocional, integrada a um Backend **Node.js** local com Inteligência Artificial (**Google Gemini**) para feedbacks personalizados.

Este projeto foi desenvolvido como parte de um trabalho acadêmico, demonstrando conceitos de arquitetura Cliente-Servidor, Persistência de Dados e Integração de API Externa.

## 🚀 Tecnologias Utilizadas

### Mobile (Frontend)
*   **Flutter**: Framework UI multiplataforma.
*   **GetX**: Gerenciamento de estado, injeção de dependência e rotas.
*   **Http**: Comunicação com o backend.
*   **Intl**: Formatação de datas.
*   **Flutter Test**: Testes Unitários e de Widget.
*   **Integration Test**: Testes de Integração.

### Backend (Servidor Local)
*   **Node.js**: Runtime Javascript.
*   **Express**: Framework para API Rest.
*   **SQLite**: Banco de dados relacional (SQL) local, leve e robusto. (Substituiu arquivos JSON na versão final).
*   **JWT (JSON Web Token)**: Autenticação segura e controle de sessão.
*   **Google Gemini AI**: API de Inteligência Artificial Generativa para insights psicológicos.

---

## ✨ Funcionalidades

1.  **Autenticação Segura**
    *   Login e Registro de usuários.
    *   Dados salvos no **SQLite** (tabela `users`).
    *   Isolamento de dados: Cada usuário vê apenas seus próprios registros.

2.  **Diário Emocional**
    *   Registro de humor diário com Emojis animados.
    *   Adição de notas de texto.
    *   Persistência no Backend (tabela `moods`).

3.  **Reflexões com IA**
    *   Ao salvar um humor, o Backend consulta o **Google Gemini**.
    *   A IA analisa o sentimento e gera um feedback curto e acolhedor.
    *   A reflexão é salva no banco e exibida no App.

4.  **Interface Premium**
    *   Design moderno com gradientes e animações suaves.
    *   Adaptação responsiva com `flutter_screenutil`.
    *   Timeline horizontal para histórico.

---

## 🛠️ Como Rodar o Projeto

Este projeto é composto por duas partes que precisam rodar simultaneamente: o **Backend** e o **App**.

### Pré-requisitos
*   [Node.js](https://nodejs.org/) instalado.
*   [Flutter SDK](https://flutter.dev/) instalado.
*   Emulador Android ou dispositivo físico.

### Passo 1: Iniciar o Backend
O Backend é responsável por salvar os dados e falar com a IA.

1.  Abra o terminal na pasta `backend`:
    ```bash
    cd backend
    ```
2.  Instale as dependências (apenas na primeira vez):
    ```bash
    npm install
    ```
3.  Inicie o servidor:
    ```bash
    npm start
    ```
    *Você verá: `Server running on port 3000`*

### Passo 2: Iniciar o App Flutter
1.  Abra um novo terminal na pasta raiz do projeto (`MoodTrack/`).
2.  Instale as dependências:
    ```bash
    flutter pub get
    ```
3.  Rode o aplicativo:
    ```bash
    flutter run
    ```

---

## 🧪 Testes

O projeto conta com cobertura de testes automatizados:

*   **Testes Unitários**: `flutter test test/models/mood_entry_test.dart`
*   **Testes de Widget**: `flutter test test/widgets/mood_button_test.dart`
*   **Teste de Integração**: `flutter test integration_test/app_test.dart`

---

## 🗂️ Estrutura do Banco de Dados (SQLite)

O sistema cria automaticamente um arquivo `database.sqlite` na pasta `backend/`.

*   **Tabela `users`**: `id`, `name`, `email`, `password`.
*   **Tabela `moods`**: `id`, `userId`, `moodLevel`, `emoji`, `note`, `aiReflection`, `date`.

---

Desenvolvido para fins acadêmicos.
