#!/bin/bash

# ================================================
# Script de Instalação do Playit Agent
# Execute este script uma vez no HOST (fora do Docker)
# ================================================

set -e

echo "=========================================="
echo "  Instalando Playit Agent"
echo "=========================================="
echo ""

# Verificar se é root
if [ "$EUID" -ne 0 ]; then 
    echo "Por favor, execute como root (sudo)"
    exit 1
fi

# Código do Playit (obtido em https://playit.gg/account)
PLAYIT_CODE="2c3c92e1946cfb3f23d4c78153d263a1"

# Pasta do Playit
PLAYIT_DIR="/opt/playit"
PLAYIT_LOG="${PLAYIT_DIR}/playit.log"

# ================================================
# Criar diretório
# ================================================
mkdir -p "$PLAYIT_DIR"

# ================================================
# Baixar Playit Agent
# ================================================
echo "[PLAYIT] Baixando agente..."

ARCH=$(uname -m)
case "$ARCH" in
    x86_64|amd64) 
        FILE="playit-linux-amd64"
        ;;
    aarch64|arm64) 
        FILE="playit-linux-aarch64"
        ;;
    armv7l)
        FILE="playit-linux-armv7"
        ;;
    *)
        echo "Arquitetura não suportada: $ARCH"
        exit 1
        ;;
esac

URL="https://github.com/playit-cloud/playit-agent/releases/download/v1.0.10/${FILE}"

curl -fsSL -o "${PLAYIT_DIR}/playit" "$URL"

echo "[PLAYIT] Download concluído!"

# ================================================
# Dar permissões
# ================================================
chmod +x "${PLAYIT_DIR}/playit"

echo "[PLAYIT] Permissões configuradas!"

# ================================================
# Testar Playit com o código
# ================================================
echo ""
echo "[PLAYIT] Configurando com código..."
echo "        Código: ${PLAYIT_CODE}"
echo ""

# Rodar o Playit com o código de setup
cd "$PLAYIT_DIR"
./playit --setup-code "$PLAYIT_CODE"

echo ""
echo "=========================================="
echo "  Playit Agent Instalado!"
echo "=========================================="
echo ""
echo "Local: ${PLAYIT_DIR}/playit"
echo "Log: ${PLAYIT_LOG}"
echo ""
echo "Para iniciar em segundo plano, rode:"
echo "  cd ${PLAYIT_DIR} && ./playit > playit.log 2>&1 &"
echo ""
