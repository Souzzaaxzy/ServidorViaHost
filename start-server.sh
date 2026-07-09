#!/bin/bash

# ================================================
# Script para iniciar Playit + Minecraft Bedrock
# Execute este script no HOST (fora do Docker)
# ================================================

set -e

PLAYIT_DIR="/opt/playit"
BEDROCK_DIR="/opt/minecraft-bedrock"
PLAYIT_LOG="${PLAYIT_DIR}/playit.log"

echo "=========================================="
echo "  Minecraft Bedrock + Playit"
echo "=========================================="
echo ""

# ================================================
# Iniciar Playit (se não estiver rodando)
# ================================================
echo "[PLAYIT] Verificando agente..."

# Verificar se já está rodando
if pgrep -f "playit" > /dev/null; then
    echo "[PLAYIT] Já está rodando!"
else
    echo "[PLAYIT] Iniciando..."
    cd "$PLAYIT_DIR"
    
    # Iniciar em segundo plano
    nohup ./playit > "$PLAYIT_LOG" 2>&1 &
    
    # Aguardar
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
# Mostrar informações
# ================================================
echo "=========================================="
echo "  Informações do Túnel"
echo "=========================================="
echo ""
echo "Verifique o endereço do túnel em:"
echo "  https://playit.gg/account"
echo ""
echo "Logs do Playit: ${PLAYIT_LOG}"
echo ""

# ================================================
# Iniciar Minecraft Bedrock
# ================================================
echo "[BEDROCK] Iniciando servidor..."
echo ""

cd "$BEDROCK_DIR"
./bedrock_server
