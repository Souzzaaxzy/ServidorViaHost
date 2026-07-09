#!/bin/bash

# ================================================
# Minecraft Bedrock Server + ngrok Tunnel
# ================================================
# Comando: npm start
# ================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# ================================================
# CONFIGURAÇÕES DO NGROK
# ================================================
# Cole seu authtoken do ngrok aqui
# Obtenha em: https://dashboard.ngrok.com/get-started/your-authtoken
NGROK_AUTHTOKEN=""

# Pasta do ngrok
NGROK_DIR="${SCRIPT_DIR}/ngrok"
NGROK_LOG="${NGROK_DIR}/ngrok.log"

# Versão do ngrok
NGROK_VERSION="3.8.0"

# ================================================
# VERIFICAR ARQUITETURA
# ================================================
echo "=========================================="
echo "  Minecraft Bedrock + ngrok Tunnel"
echo "=========================================="
echo ""

ARCH=$(uname -m)
case "$ARCH" in
    x86_64|amd64) 
        NGROK_ARCH="amd64"
        ;;
    aarch64|arm64) 
        NGROK_ARCH="arm64"
        ;;
    armv7l)
        NGROK_ARCH="arm"
        ;;
    *)
        echo "Arquitetura não suportada: $ARCH"
        exit 1
        ;;
esac

NGROK_FILE="ngrok-v${NGROK_VERSION}-linux-${NGROK_ARCH}.zip"
NGROK_URL="https://bin.equinox.io/c/bNyj1mQVY4c/${NGROK_FILE}"
NGROK_PATH="${NGROK_DIR}/ngrok"

echo "Sistema: $(uname) - $ARCH"
echo "ngrok: ${NGROK_ARCH}"
echo ""

# ================================================
# PREPARAR DIRETÓRIOS
# ================================================
mkdir -p "$NGROK_DIR"
mkdir -p servidor

# ================================================
# BAIXAR NGROK
# ================================================
if [ -f "$NGROK_PATH" ]; then
    echo "[NGROK] ngrok já existe"
else
    echo "[NGROK] Baixando ngrok..."
    echo "        URL: ${NGROK_URL}"
    
    # Baixar zip
    curl -fsSL -o "${NGROK_DIR}/ngrok.zip" "$NGROK_URL"
    
    # Extrair usando python
    python3 -m zipfile -e "${NGROK_DIR}/ngrok.zip" "$NGROK_DIR"
    rm "${NGROK_DIR}/ngrok.zip"
    
    chmod +x "$NGROK_PATH"
    echo "[NGROK] Download concluído!"
fi

# ================================================
# CONFIGURAR AUTOTOKEN
# ================================================
if [ -n "$NGROK_AUTHTOKEN" ] && [ "$NGROK_AUTHTOKEN" != "" ]; then
    echo "[NGROK] Configurando authtoken..."
    "$NGROK_PATH" config add-authtoken "$NGROK_AUTHTOKEN" 2>/dev/null || true
fi

# ================================================
# INICIAR NGROK TUNNEL
# ================================================
echo ""
echo "[NGROK] Iniciando túnel UDP..."
echo "[NGROK] Logs disponíveis em: ${NGROK_LOG}"
echo ""

# Limpar log
> "$NGROK_LOG"

cd "$NGROK_DIR"

# Iniciar ngrok com túnel TCP para Bedrock (Minecraft Bedrock funciona com TCP também)
"$NGROK_PATH" tcp 19132 2>&1 | tee "$NGROK_LOG" &
NGROK_PID=$!

cd "$SCRIPT_DIR"

# Aguardar ngrok iniciar e obter a URL
sleep 8

# Verificar se ainda está rodando
if ps -p $NGROK_PID > /dev/null 2>&1; then
    echo "[NGROK] Túnel iniciado!"
    echo "[NGROK] PID: $NGROK_PID"
    
    # Mostrar URL do túnel
    echo ""
    echo "=========================================="
    echo "  ENDEREÇO DO SERVIDOR"
    echo "=========================================="
    echo "Verifique o endereço do túnel em:"
    echo "https://dashboard.ngrok.com/tunnels/agents"
    echo ""
    grep -o "tcp://[0-9.]*:[0-9]*" "$NGROK_LOG" 2>/dev/null || echo "Aguarde..."
else
    echo "[NGROK] AVISO: O ngrok pode ter fechado."
    echo "[NGROK] Verifique os logs em: ${NGROK_LOG}"
fi

echo ""

# ================================================
# PREPARAR SERVIDOR BEDROCK
# ================================================
echo "[BEDROCK] Preparando servidor..."
echo ""

cd servidor

if [ -f "bedrock_server" ]; then
    echo "[BEDROCK] Servidor já extraído!"
else
    echo "[BEDROCK] Extraindo Minecraft Bedrock Server..."
    
    if [ -f "bedrock-server.zip" ]; then
        unzip -o bedrock-server.zip 2>/dev/null || python3 -m zipfile -e bedrock-server.zip . 2>/dev/null || true
        rm -f bedrock-server.zip
        echo "[BEDROCK] Extração concluída!"
    else
        echo "[BEDROCK] ERRO: bedrock-server.zip não encontrado!"
        exit 1
    fi
fi

chmod +x bedrock_server 2>/dev/null || true

cd "$SCRIPT_DIR"

# ================================================
# CRIAR SERVER.PROPERTIES
# ================================================
if [ ! -f "servidor/server.properties" ]; then
    cat > servidor/server.properties << 'EOF'
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
fi

# ================================================
# INICIAR SERVIDOR BEDROCK
# ================================================
echo "[BEDROCK] Iniciando servidor..."
echo ""

cd servidor
exec ./bedrock_server
