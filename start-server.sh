#!/bin/bash

# ================================================
# Script para iniciar Playit + Minecraft Bedrock
# Execute: npm start
# ================================================

set -e

# Verificar se é root
if [ "$EUID" -ne 0 ]; then 
    echo "Por favor, execute como root (sudo)"
    exit 1
fi

PLAYIT_DIR="/opt/playit"
BEDROCK_DIR="/opt/minecraft-bedrock"
PLAYIT_CODE="2c3c92e1946cfb3f23d4c78153d263a1"

echo "=========================================="
echo "  Minecraft Bedrock + Playit"
echo "=========================================="
echo ""

# ================================================
# INSTALAR PLAYIT SE NÃO EXISTIR
# ================================================
if [ ! -f "$PLAYIT_DIR/playit" ]; then
    echo "[PLAYIT] Baixando agente..."
    mkdir -p "$PLAYIT_DIR"
    
    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64|amd64) FILE="playit-linux-amd64";;
        aarch64|arm64) FILE="playit-linux-aarch64";;
        armv7l) FILE="playit-linux-armv7";;
        *) echo "Arquitetura não suportada: $ARCH"; exit 1;;
    esac
    
    curl -fsSL -o "${PLAYIT_DIR}/playit" "https://github.com/playit-cloud/playit-agent/releases/download/v1.0.10/${FILE}"
    chmod +x "${PLAYIT_DIR}/playit"
    echo "[PLAYIT] Download concluído!"
else
    echo "[PLAYIT] Já está instalado!"
fi

# ================================================
# INSTALAR BEDROCK SE NÃO EXISTIR
# ================================================
if [ ! -f "$BEDROCK_DIR/bedrock_server" ]; then
    echo "[BEDROCK] Baixando servidor..."
    mkdir -p "$BEDROCK_DIR"
    cd "$BEDROCK_DIR"
    
    curl -L -o bedrock-server.zip "https://www.minecraft.net/bedrockdedicatedserver/bin/linux/bedrock-server-latest.zip"
    unzip -o bedrock-server.zip
    rm -f bedrock-server.zip
    chmod +x bedrock_server
    
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
    
    echo "[BEDROCK] Instalação concluída!"
else
    echo "[BEDROCK] Já está instalado!"
fi

cd "$BEDROCK_DIR"

# ================================================
# INICIAR PLAYIT (se não estiver rodando)
# ================================================
echo ""
echo "[PLAYIT] Verificando agente..."

if pgrep -f "playit" > /dev/null; then
    echo "[PLAYIT] Já está rodando!"
else
    echo "[PLAYIT] Iniciando..."
    cd "$PLAYIT_DIR"
    nohup ./playit --setup-code "$PLAYIT_CODE" > playit.log 2>&1 &
    sleep 3
    
    if pgrep -f "playit" > /dev/null; then
        echo "[PLAYIT] Iniciado com sucesso!"
    else
        echo "[PLAYIT] ERRO ao iniciar!"
        exit 1
    fi
fi

echo ""

# ================================================
# MOSTRAR INFORMAÇÕES
# ================================================
echo "=========================================="
echo "  Informações do Túnel"
echo "=========================================="
echo ""
echo "Verifique o endereço do túnel em:"
echo "  https://playit.gg/account"
echo ""
echo "Logs do Playit: ${PLAYIT_DIR}/playit.log"
echo ""

# ================================================
# INICIAR MINECRAFT BEDROCK
# ================================================
echo "[BEDROCK] Iniciando servidor..."
echo ""

cd "$BEDROCK_DIR"
./bedrock_server
