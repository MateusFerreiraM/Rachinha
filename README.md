# Rachinha 🍻

[![Acesse a Versão Web](https://img.shields.io/badge/Acessar-Vers%C3%A3o_Web-blue?style=for-the-badge&logo=googlechrome)](https://rachinha-dos-amigos.netlify.app)

Rachinha é um aplicativo multiplataforma (Mobile e Web), desenvolvido com Flutter, criado para facilitar a divisão de contas de bar e restaurante entre amigos. Intuitivo, rápido e salvo na nuvem, ele é a ferramenta definitiva para acabar com as contas em guardanapos ou na calculadora do celular!

👉 **Acesse o aplicativo diretamente pelo navegador:** [rachinha-dos-amigos.netlify.app](https://rachinha-dos-amigos.netlify.app)

## 🎯 Objetivo

O projeto nasceu da necessidade de ter uma ferramenta fácil de usar para gerenciar despesas em grupo. Com o Rachinha, o usuário pode criar um evento (uma "comanda"), adicionar os participantes, lançar os itens consumidos e vincular quem consumiu o quê. Ao final, o app calcula a parte de cada um, incluindo a taxa de serviço, e gera um resumo pronto para ser compartilhado.

## ✨ Funcionalidades Principais

-   ☁️ **Sincronização em Nuvem:** Todos os dados agora são salvos no Supabase, permitindo que você acesse seu histórico de contas de qualquer dispositivo (Android, iOS ou pelo Navegador).
-   🔒 **Sistema de Login Simples:** Suas contas de bar são privadas e atreladas à sua conta de usuário.
-   🏢 **Histórico Organizado por Bares:** Crie e organize suas comandas por estabelecimento.
-   ✍️ **Edição Completa e Intuitiva:** Edite ou exclua bares, comandas, participantes e itens a qualquer momento com facilidade.
-   🔗 **Divisão Flexível de Itens:** Adicione itens e divida-os entre uma ou várias pessoas.
-   💵 **Cálculo de Taxa de Serviço:** Inclua a taxa de serviço ou a remova do cálculo final.
-   📲 **Resumo para Compartilhamento:** Com um toque, gere um resumo claro e detalhado para enviar no WhatsApp.

## 🛠️ Tecnologias e Dependências

-   **Flutter:** Framework principal para o desenvolvimento da interface Web e Mobile.
-   **Supabase:** Backend as a Service (BaaS) utilizado para Banco de Dados (PostgreSQL) e Autenticação (Row Level Security).

#### Principais Dependências:
-   `supabase_flutter`: Para integração com banco de dados em nuvem e login.
-   `intl`: Para formatação de datas, moedas e horas.
-   `share_plus`: Para a funcionalidade de compartilhamento.

## 🚀 Como Executar o Projeto Localmente

Se você é um desenvolvedor e quer testar o projeto, siga os passos:

1.  **Clone o repositório:**
    ```bash
    git clone https://github.com/MateusFerreiraM/Rachinha.git
    ```

2.  **Entre na pasta do projeto:**
    ```bash
    cd Rachinha
    ```

3.  **Instale as dependências:**
    ```bash
    flutter pub get
    ```

4.  **Execute o aplicativo:**
    ```bash
    # Para testar no emulador web
    flutter run -d chrome
    ```

## 🎨 Personalização

O aplicativo foi construído com um sistema de tema centralizado. Para alterar a paleta de cores, basta editar o arquivo `lib/theme/app_colors.dart`.

## 📄 Licença

Este projeto está sob a licença MIT.