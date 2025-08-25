# Workshop: n8n + EvolutionAPI

## Conteúdo
- n8n
- Redis
- PostgreSQL
- EvolutionAPI

## Requisitos
- Docker
- Um celular com WhatsApp

## Instalação

Este repositório pode ser utilizado de duas maneiras: localmente ou na nuvem através do GitHub Codespaces.

## Configuração do GitHub Codespaces

1. Clique no botão "Code" na página do GitHub do repositório;
2. Em seguida, clique no botão "Create codespace on main";
3. Assim que a máquina terminar de carregar, abra o terminal;
4. Insira o comando ``./setup.sh`` e aperte Enter.

## Instalação Local

Para instalar em sua própria máquina, clone o repositório e rode o comando abaixo no terminal dentro da pasta do projeto:

```bash
  docker compose -f docker-compose.local.yml up -d
```