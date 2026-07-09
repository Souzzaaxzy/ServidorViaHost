#!/bin/bash

# ================================================
# Minecraft Bedrock Server + Playit.gg
# ================================================
# Comando: npm start
# ================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# ================================================
# CONFIGURAÇÕES DO PLAYIT
# ================================================
# Cole seu código de configuração do Playit.gg aqui
# Você pode obter este código em: https://playit.gg/account
PLAYIT_SETUP_CODE="COLOQUE_O_SETUP_CODE_AQUI"

# Versão do Playit Agent
PLAYIT_VERSION="v1.0.10"
PLAYIT_BASE_URL="https://github.com/playit-cloud/playit-agent/releases/download/${PLAYIT_VERSION}"

# Pasta do Playit
PLAYIT_DIR="${SCRIPT_DIR}/playit"
PLAYIT_LOG="${PLAYIT_DIR}/playit.log"
PLAYIT_SOCKET="${PLAYIT_DIR}/playit.sock"
PLAYIT_CONFIG="${PLAYIT_DIR}/playit.toml"

# ================================================
# VERIFICAR ARQUITETURA
# ================================================
echo "=========================================="
echo "  Minecraft Bedrock + Playit.gg"
echo "=========================================="
echo ""

ARCH=$(uname -m)
case "$ARCH" in
    x86_64|amd64) 
        PLAYIT_ARCH="amd64"
        ;;
    aarch64|arm64) 
        PLAYIT_ARCH="aarch64"
        ;;
    armv7l)
        PLAYIT_ARCH="armv7"
        ;;
    *)
        echo "Arquitetura não suportada: $ARCH"
        exit 1
        ;;
esac

PLAYIT_FILE="playit-linux-${PLAYIT_ARCH}"
PLAYIT_CLI_FILE="playit-cli-linux-${PLAYIT_ARCH}"
PLAYIT_URL="${PLAYIT_BASE_URL}/${PLAYIT_FILE}"
PLAYIT_CLI_URL="${PLAYIT_BASE_URL}/${PLAYIT_CLI_FILE}"
PLAYIT_PATH="${PLAYIT_DIR}/${PLAYIT_FILE}"
PLAYIT_CLI_PATH="${PLAYIT_DIR}/${PLAYIT_CLI_FILE}"

echo "Sistema: $(uname) - $ARCH"
echo "Playit: ${PLAYIT_FILE}"
echo ""

# ================================================
# PREPARAR DIRETÓRIOS
# ================================================
mkdir -p "$PLAYIT_DIR"
mkdir -p servidor

# ================================================
# BAIXAR PLAYIT AGENT
# ================================================
# Baixar versão standalone
if [ -f "$PLAYIT_PATH" ]; then
    echo "[PLAYIT] Agente já existe: ${PLAYIT_FILE}"
else
    echo "[PLAYIT] Baixando agente..."
    echo "        URL: ${PLAYIT_URL}"
    curl -fsSL -o "$PLAYIT_PATH" "$PLAYIT_URL"
    echo "[PLAYIT] Download concluído!"
fi

# Baixar versão CLI
if [ -f "$PLAYIT_CLI_PATH" ]; then
    echo "[PLAYIT] CLI já existe: ${PLAYIT_CLI_FILE}"
else
    echo "[PLAYIT] Baixando CLI..."
    echo "        URL: ${PLAYIT_CLI_URL}"
    curl -fsSL -o "$PLAYIT_CLI_PATH" "$PLAYIT_CLI_URL"
    echo "[PLAYIT] Download da CLI concluído!"
fi

# ================================================
# DAR PERMISSÃO DE EXECUÇÃO
# ================================================
echo "[PLAYIT] Configurando permissões..."
chmod +x "$PLAYIT_PATH"
chmod +x "$PLAYIT_CLI_PATH"

# Links simbólicos
ln -sf "$PLAYIT_PATH" "${PLAYIT_DIR}/playit" 2>/dev/null || true
ln -sf "$PLAYIT_CLI_PATH" "${PLAYIT_DIR}/playit-cli" 2>/dev/null || true
echo "[PLAYIT] Permissões configuradas!"

# ================================================
# VERIFICAR SE JÁ ESTÁ AUTENTICADO
# ================================================
NEEDS_AUTH=true

if [ -f "$PLAYIT_CONFIG" ] || [ -f "$HOME/.config/playit_gg/playit.toml" ]; then
    NEEDS_AUTH=false
    echo "[PLAYIT] Agente já autenticado!"
fi

# ================================================
# INICIAR PLAYIT
# ================================================
echo ""
echo "[PLAYIT] Iniciando túnel..."
echo "[PLAYIT] Logs disponíveis em: ${PLAYIT_LOG}"
echo ""

# Limpar log
> "$PLAYIT_LOG"

cd "$PLAYIT_DIR"

if [ "$NEEDS_AUTH" = true ]; then
    echo "[PLAYIT] Configurando..."
    echo "        Código: ${PLAYIT_SETUP_CODE}"
    
    if [ "$PLAYIT_SETUP_CODE" = "COLOQUE_O_SETUP_CODE_AQUI" ] || [ -z "$PLAYIT_SETUP_CODE" ]; then
        echo ""
        echo "=========================================="
        echo "  ATENÇÃO: CÓDIGO NÃO CONFIGURADO!"
        echo "=========================================="
        echo "Edite start.sh e defina PLAYIT_SETUP_CODE"
        echo "Obtenha seu código em: https://playit.gg/account"
        echo ""
        echo "Iniciando daemon em segundo plano..."
        echo ""
        # Iniciar daemon com socket local
        "./${PLAYIT_FILE}" --socket-path "$PLAYIT_SOCKET" --secret-path "$PLAYIT_CONFIG" 2>&1 | tee "$PLAYIT_LOG" &
    else
        # Iniciar com setup code
        "./${PLAYIT_CLI_PATH}" --setup-code "$PLAYIT_SETUP_CODE" --socket-path "$PLAYIT_SOCKET" --secret-path "$PLAYIT_CONFIG" 2>&1 | tee "$PLAYIT_LOG" &
    fi
else
    # Já autenticado, iniciar daemon
    "./${PLAYIT_FILE}" --socket-path "$PLAYIT_SOCKET" --secret-path "$PLAYIT_CONFIG" 2>&1 | tee "$PLAYIT_LOG" &
fi

# Guardar PID
PLAYIT_PID=$!

cd "$SCRIPT_DIR"

# Aguardar
sleep 3

# Verificar
if ps -p $PLAYIT_PID > /dev/null 2>&1; then
    echo "[PLAYIT] Túnel iniciado!"
    echo "[PLAYIT] PID: $PLAYIT_PID"
else
    echo "[PLAYIT] AVISO: O agente pode ter fechado."
    echo "[PLAYIT] Verifique os logs em: ${PLAYIT_LOG}"
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
