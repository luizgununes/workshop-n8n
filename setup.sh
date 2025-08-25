#!/bin/bash

echo "🛠️ Script de Configuração: Workshop n8n + EvolutionAPI"
echo "========================================================"
echo ""

if [ -n "$CODESPACE_NAME" ]; then
    echo "🔧 GitHub Codespace detectado: $CODESPACE_NAME"
    echo "📝 Configurando variáveis de ambiente..."
    
    if [ -f "docker-compose.yml" ] && grep -q "\${CODESPACE_NAME}" docker-compose.yml; then
        sed -i "s/\${CODESPACE_NAME}/$CODESPACE_NAME/g" docker-compose.yml
        echo "✅ docker-compose.yml configurado com CODESPACE_NAME!"
    elif [ -f "docker-compose.yml" ] && grep -q "$CODESPACE_NAME" docker-compose.yml; then
        echo "✅ docker-compose.yml já estava configurado!"
    fi
    
    if [ -f ".env" ] && grep -q "\${CODESPACE_NAME}" .env; then
        sed -i "s/\${CODESPACE_NAME}/$CODESPACE_NAME/g" .env
        echo "✅ .env configurado com CODESPACE_NAME!"
    elif [ -f ".env" ] && grep -q "$CODESPACE_NAME" .env; then
        echo "✅ .env já estava configurado!"
    fi
    
    echo ""
fi

echo "🐳 Verificando Docker..."
if ! command -v docker &> /dev/null; then
    echo "❌ Docker não encontrado. Aguardando instalação..."
    
    for i in {1..30}; do
        if command -v docker &> /dev/null; then
            echo "✅ Docker encontrado!"
            break
        fi
        echo "⏳ Aguardando o Docker ser instalado... ($i/30)"
        sleep 2
    done
    
    if ! command -v docker &> /dev/null; then
        echo "❌ ERRO: O Docker não pôde ser instalado."
        exit 1
    fi
fi

echo "🔍 Verificando Docker Engine..."
for i in {1..15}; do
    if docker info >/dev/null 2>&1; then
        echo "✅ Docker Engine está rodando!"
        break
    else
        echo "⏳ Aguardando Docker Engine... ($i/15)"
        sleep 3
    fi
done

if ! docker info >/dev/null 2>&1; then
    echo "❌ ERRO: O Docker Engine não está rodando."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "🔍 docker-compose não encontrado, usando docker compose."
    alias docker-compose='docker compose'
fi

check_image() {
    echo "🔍 Verificando imagem: $1"
    if docker pull $1 >/dev/null 2>&1; then
        echo "✅ Imagem $1 encontrada e baixada!"
        return 0
    else
        echo "❌ ERRO: Não foi possível baixar a imagem $1."
        return 1
    fi
}

test_connectivity() {
    echo "🌐 Testando conectividade..."
    if curl -s --max-time 5 https://hub.docker.com >/dev/null; then
        echo "✅ Conectividade com o Docker Hub OK!"
        return 0
    else
        echo "❌ ERRO: Problemas de conectividade com o Docker Hub."
        return 1
    fi
}

echo "🛑 Parando serviços existentes..."
docker-compose down 2>/dev/null || docker compose down 2>/dev/null || true

if ! test_connectivity; then
    echo ""
    echo "❌ ERRO: Sem conectividade com o Docker Hub."
    exit 1
fi

echo ""
echo "📦 Verificando se as imagens estão disponíveis..."

IMAGES_OK=true

if ! check_image "n8nio/n8n:latest"; then
    IMAGES_OK=false
fi

if ! check_image "evolutionapi/evolution-api:latest"; then
    IMAGES_OK=false
fi

if ! check_image "postgres:15"; then
    IMAGES_OK=false
fi

if ! check_image "redis:7-alpine"; then
    IMAGES_OK=false
fi

if [ "$IMAGES_OK" != true ]; then
    echo ""
    echo "❌ ERRO: Uma ou mais imagens não estão disponíveis."
    echo ""
    exit 1
fi

echo ""
echo "✅ Todas as imagens estão disponíveis!"

echo ""
echo "🚀 Iniciando todos os serviços..."
if command -v docker-compose &> /dev/null; then
    docker-compose up -d
else
    docker compose up -d
fi

echo "⏳ Aguardando os serviços ficarem prontos..."
sleep 45

echo ""
echo "📊 Status dos serviços:"
if command -v docker-compose &> /dev/null; then
    docker-compose ps
else
    docker compose ps
fi

echo ""
echo "🔍 Testando endpoints obrigatórios..."

echo "🧪 Testando n8n..."
N8N_OK=false
for i in {1..10}; do
    if curl -s --max-time 10 http://localhost:5678 >/dev/null; then
        echo "✅ O n8n está funcionando em http://localhost:5678"
        N8N_OK=true
        break
    else
        echo "⏳ Tentativa $i/10 - n8n ainda não disponível..."
        sleep 5
    fi
done

echo "🧪 Testando EvolutionAPI..."
EVOLUTION_OK=false
for i in {1..10}; do
    if curl -s --max-time 10 http://localhost:8080 >/dev/null; then
        echo "✅ A EvolutionAPI está funcionando em http://localhost:8080"
        EVOLUTION_OK=true
        break
    else
        echo "⏳ Tentativa $i/10 - EvolutionAPI ainda não disponível..."
        sleep 5
    fi
done

if [ "$N8N_OK" != true ] || [ "$EVOLUTION_OK" != true ]; then
    echo ""
    echo "❌ ERRO: Um ou mais serviços não estão funcionando."
    echo ""
    echo "🔍 Logs para diagnóstico:"
    echo "--- n8n ---"
    if command -v docker-compose &> /dev/null; then
        docker-compose logs --tail=10 n8n
    else
        docker compose logs --tail=10 n8n
    fi
    echo "--- EvolutionAPI ---"
    if command -v docker-compose &> /dev/null; then
        docker-compose logs --tail=10 evolution-api
    else
        docker compose logs --tail=10 evolution-api
    fi
    echo ""
    exit 1
fi

echo ""
echo "🎉 Configuração completa!"
echo ""