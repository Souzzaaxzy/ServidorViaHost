#!/bin/bash

# ================================================
# Script de Instalação do Minecraft Bedrock Server
# Execute este script uma vez no HOST (fora do Docker)
# ================================================

set -e

echo "=========================================="
echo "  Instalando Minecraft Bedrock Server"
echo "=========================================="
echo ""

# Verificar se é root
if [ "$EUID" -ne 0 ]; then 
    echo "Por favor, execute como root (sudo)"
    exit 1
fi

# Pasta de instalação
BEDROCK_DIR="/opt/minecraft-bedrock"

# Criar diretório
mkdir -p "$BEDROCK_DIR"
cd "$BEDROCK_DIR"

# ================================================
# Baixar Minecraft Bedrock Server
# ================================================
echo "[BEDROCK] Baixando Minecraft Bedrock Server..."

# URL oficial (pode precisar de Accept-Language header)
curl -L -o bedrock-server.zip \
    -H "Accept-Language: en-US" \
    "https://www.minecraft.net/bedrockdedicatedserver/bin/linux/bedrock-server-1.21.50.02.zip" \
    2>/dev/null || \
curl -L -o bedrock-server.zip \
    "https://minecraft.net/bedrockdedicatedserver/bin/linux/bedrock-server-1.21.50.02.zip" \
    2>/dev/null || true

# Se falhou, tentar versão mais recente
if [ ! -f "bedrock-server.zip" ] || [ ! -s "bedrock-server.zip" ]; then
    echo "[BEDROCK] Tentando versão alternativa..."
    curl -L -o bedrock-server.zip \
        "https://www.minecraft.net/bedrockdedicatedserver/bin/linux/bedrock-server-latest.zip" \
        2>/dev/null || true
fi

# ================================================
# Verificar se baixou
# ================================================
if [ ! -f "bedrock-server.zip" ] || [ ! -s "bedrock-server.zip" ]; then
    echo ""
    echo "[BEDROCK] ERRO: Não foi possível baixar o servidor!"
    echo "[BEDROCK] Por favor, baixe manualmente em:"
    echo "  https://www.minecraft.net/bedrockdedicatedserver"
    echo ""
    echo "E extraia em: ${BEDROCK_DIR}"
    exit 1
fi

# ================================================
# Extrair
# ================================================
echo "[BEDROCK] Extraindo..."

unzip -o bedrock-server.zip
rm -f bedrock-server.zip

# ================================================
# Dar permissões
# ================================================
chmod +x bedrock_server
chmod +x bedrock_server_how_to_setup.txt 2>/dev/null || true

echo "[BEDROCK] Servidor instalado!"

# ================================================
# Criar server.properties
# ================================================
if [ ! -f "server.properties" ]; then
    echo "[BEDROCK] Criando configuração..."
    cat > server.properties << 'EOF'
server-name=ServidorViaHost
gamemode=survival
difficulty=easy
max-players=10
view-distance=6
tick-distance=4
allow-cheats=true
server-port=19132
server-portv6=19133
enable-query=true
query.port=19132
rcon.port=19133
EOF
    echo "[BEDROCK] Configuração criada!"
fi

echo ""
echo "=========================================="
echo "  Minecraft Bedrock Instalado!"
echo "=========================================="
echo ""
echo "Local: ${BEDROCK_DIR}"
echo ""
echo "Para iniciar, rode:"
echo "  cd ${BEDROCK_DIR} && ./bedrock_server"
echo ""
