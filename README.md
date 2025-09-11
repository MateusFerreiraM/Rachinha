# Rachinha 🍻

Rachinha é um aplicativo móvel, desenvolvido com Flutter, criado para facilitar a divisão de contas de bar e restaurante entre amigos. Intuitivo, rápido e totalmente offline, ele é a ferramenta definitiva para acabar com as contas em guardanapos ou na calculadora do celular!

## 🎯 Objetivo

O projeto nasceu da necessidade de ter uma ferramenta privada, offline e fácil de usar para gerenciar despesas em grupo. Com o Rachinha, o usuário pode criar um evento (uma "comanda"), adicionar os participantes, lançar os itens consumidos e vincular quem consumiu o quê. Ao final, o app calcula a parte de cada um, incluindo a taxa de serviço, e gera um resumo pronto para ser compartilhado.

## ✨ Funcionalidades Principais

-   🏢 **Histórico Organizado por Bares:** Crie e organize suas comandas por estabelecimento, mantendo um histórico claro e acessível.
-   ✍️ **Edição Completa e Intuitiva:** Edite ou exclua bares, comandas, participantes e itens a qualquer momento com facilidade.
-   🔗 **Divisão Flexível de Itens:** Adicione itens e divida-os entre uma ou várias pessoas, especificando a quantidade exata que cada um consumiu (ótimo para itens compartilhados como porções e baldes de bebida).
-   💵 **Cálculo de Taxa de Serviço:** Inclua a taxa de serviço (10% ou outra porcentagem customizável) ou a remova completamente do cálculo final.
-   📅 **Ajuste Preciso de Data e Hora:** Registre a comanda com a data e hora exatas do evento, mesmo que esteja lançando a conta dias depois, com correção automática de fuso horário.
-   📲 **Resumo para Compartilhamento:** Com um toque, gere um resumo de texto claro e detalhado para enviar no WhatsApp ou outro mensageiro.
-   ✈️ **100% Offline e Privado:** Todos os dados são salvos localmente no seu dispositivo. Use o aplicativo onde estiver, sem precisar de internet e com total privacidade.

## 🛠️ Tecnologias e Dependências

-   **Flutter:** Framework principal para o desenvolvimento da interface e lógica do app.
-   **Dart:** Linguagem de programação utilizada pelo Flutter.
-   **SQLite:** Banco de dados local para armazenamento persistente dos dados.

#### Principais Dependências:
-   `sqflite`: Para interação com o banco de dados SQLite.
-   `intl`: Para formatação de datas e horas.
-   `share_plus`: Para a funcionalidade de compartilhamento.
-   `path`: Para encontrar o caminho correto do banco de dados no dispositivo.


## 🚀 Como Executar o Projeto

Se você é um desenvolvedor e quer testar o projeto, siga os passos:

1.  **Clone o repositório:**
    ```bash
    git clone https://github.com/MateusFerreiraM/Rachinha.git
    ```

2.  **Entre na pasta do projeto:**
    ```bash
    cd rachinha
    ```

3.  **Instale as dependências:**
    ```bash
    flutter pub get
    ```

4.  **Execute o aplicativo:**
    ```bash
    flutter run
    ```

## 🎨 Personalização

O aplicativo foi construído com um sistema de tema centralizado. Para alterar a paleta de cores, basta editar o arquivo `lib/theme/app_colors.dart`.

## 📄 Licença

Este projeto está sob a licença MIT.