# Workshop: n8n + EvolutionAPI

## Requisitos

- Docker

## Instalação

Para instalar, basta rodar o seguinte comando no terminal dentro da pasta do projeto:

```bash
  docker compose -f docker-compose.local.yml up -d
```
    
## Como Usar

### n8n

O n8n poderá ser acessado em ``http://localhost:5678`` e solicitará a criação de uma conta no primeiro acesso.

### EvolutionAPI

A EvolutionAPI ficará disponível em ``http://localhost:8080`` e possui uma interface em ``http://localhost:8080/manager`` para gerenciar as instâncias e realizar algumas configurações e integrações.