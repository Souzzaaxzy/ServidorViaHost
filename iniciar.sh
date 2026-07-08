#!/bin/bash

# ================================================
# Minecraft Bedrock Server - INICIAR
# ================================================
# Unico comando: bash iniciar.sh
# ================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=========================================="
echo "  Minecraft Bedrock Server"
echo "=========================================="
echo ""

# Verificar arquitetura
ARCH=$(uname -m)
case "$ARCH" in
    x86_64|amd64) ARCH_NAME="linux-x64" ;;
    aarch64|arm64) ARCH_NAME="linux-arm64" ;;
    *) echo "Arquitetura: $ARCH";;
esac
echo "Sistema: $(uname) $ARCH_NAME"
echo ""

# Criar pasta servidor se nao existir
mkdir -p servidor

# Entrar na pasta
cd servidor

# Verificar se bedrock_server ja existe
if [ ! -f "bedrock_server" ]; then
    echo "Baixando Minecraft Bedrock Server..."
    echo ""
    
    # Baixar servidor oficial
    curl -L -o bedrock-server.zip "https://minecraft.azureedge.net/bin-linux/bedrock-server-1.21.40.zip" 2>/dev/null || \
    wget -O bedrock-server.zip "https://minecraft.azureedge.net/bin-linux/bedrock-server-1.21.40.zip" 2>/dev/null || true
    
    if [ -f "bedrock-server.zip" ] && [ -s "bedrock-server.zip" ]; then
        unzip -o bedrock-server.zip 2>/dev/null || python3 -m zipfile -e bedrock-server.zip . 2>/dev/null || true
        rm -f bedrock-server.zip
        echo "Download concluído!"
    else
        echo "Erro no download. Verifique sua conexao."
        exit 1
    fi
fi

# Dar permissao
chmod +x bedrock_server 2>/dev/null || true

# Voltar ao diretorio principal
cd "$SCRIPT_DIR"

# Criar server.properties se nao existir
if [ ! -f "servidor/server.properties" ]; then
    cat > servidor/server.properties << 'EOF'
server-name=ServidorViaHost Teste
gamemode=survival
difficulty=easy
max-players=5
view-distance=6
tick-distance=4
allow-cheats=true
server-port=19132
EOF
fi

echo ""
echo "=========================================="
echo "  Iniciando servidor..."
echo "=========================================="
echo ""
echo "Porta: UDP 19132"
echo "Para parar: digite 'stop'"
echo ""
echo "=========================================="
echo ""

# Iniciar servidor
cd servidor
exec ./bedrock_server
