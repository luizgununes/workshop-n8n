# Workshop: n8n + EvolutionAPI

Ambiente pronto para o workshop de automação: um bot de WhatsApp que responde cotações de moedas sob demanda.

## Conteúdo

| Serviço | Versão | Porta | Papel |
|---|---|---|---|
| n8n | 2.37.7 | 5678 | Editor e execução dos fluxos |
| EvolutionAPI | v2.3.7 | 8080 | API não-oficial do WhatsApp |
| PostgreSQL | 15 | 5432 | Banco do n8n e da EvolutionAPI |
| Redis | 7 | — | Cache da EvolutionAPI |

## Configuração Inicial

1. Clique no botão "Code" na página do GitHub do repositório;
2. Em seguida, clique no botão "Create codespace on main";
3. Assim que a máquina terminar de carregar, abra o terminal;
4. Insira o comando `./setup.sh` e aperte Enter;
5. Deixe a porta **8080** pública na aba Ports.
6. Abra o Manager da EvolutionAPI insira a API key `workshop-evolution-key`;
7. Crie uma instância chamada `workshop` e pareie o celular pelo QR Code;
8. Abra o n8n, crie uma conta e instale o community node `n8n-nodes-evolution-api`.