#!/bin/bash

# ================================================
# Minecraft Bedrock Server - Start Script
# ================================================
# Este script verifica e inicia o servidor Bedrock
# ================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=========================================="
echo "  Minecraft Bedrock Server"
echo "=========================================="
echo ""

# Verificar se é Linux
if [[ "$(uname)" != "Linux" ]]; then
    echo "⚠️  Aviso: Sistema não é Linux"
    echo "   Continuando mesmo assim..."
    echo ""
fi

# Verificar se a pasta servidor existe
if [ ! -d "servidor" ]; then
    echo "📁 Pasta 'servidor' não encontrada."
    echo "   Executando setup.sh..."
    echo ""
    bash setup.sh
fi

# Entrar na pasta do servidor
cd "$SCRIPT_DIR/servidor"

# Verificar se o executável bedrock_server existe
if [ ! -f "bedrock_server" ]; then
    echo "⚠️  bedrock_server não encontrado."
    echo "   Executando setup.sh para baixar..."
    echo ""
    cd "$SCRIPT_DIR"
    bash setup.sh
    cd "$SCRIPT_DIR/servidor"
fi

# Dar permissão de execução ao bedrock_server
if [ ! -x "bedrock_server" ]; then
    echo "🔧 Configurando permissões do servidor..."
    chmod +x bedrock_server
    echo "✓ Permissões configuradas"
    echo ""
fi

# Verificar server.properties
if [ ! -f "server.properties" ]; then
    echo "⚠️  server.properties não encontrado."
    echo "   Criando configuração padrão..."
    cat > server.properties << 'EOF'
server-name=ServidorViaHost Teste
gamemode=survival
difficulty=easy
max-players=5
view-distance=6
tick-distance=4
allow-cheats=true
server-port=19132
level-name=Bedrock Level
EOF
    echo "✓ Configuração criada"
    echo ""
fi

echo "=========================================="
echo "  Iniciando Minecraft Bedrock Server"
echo "=========================================="
echo ""
echo "📡 Porta: UDP 19132"
echo "🎮 Conexão: Minecraft Bedrock Edition"
echo ""
echo "Para parar: digite 'stop' no console"
echo "Pressione Ctrl+C para forçar parada"
echo ""
echo "=========================================="
echo ""

# Iniciar o servidor
exec ./bedrock_server
