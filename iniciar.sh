#!/bin/bash

# ================================================
# Minecraft Bedrock Server - INICIAR
# ================================================
# Unico comando: npm start
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

# Criar pasta servidor
mkdir -p servidor
cd servidor

# Verificar se bedrock_server ja existe
if [ -f "bedrock_server" ]; then
    echo "Servidor ja existe! Pulando extracao..."
    echo ""
else
    echo "Servidor nao encontrado. Extraindo..."
    echo ""
    
    if [ -f "bedrock-server.zip" ]; then
        echo "Extraindo arquivos..."
        unzip -o bedrock-server.zip 2>/dev/null || python3 -m zipfile -e bedrock-server.zip . 2>/dev/null || true
        rm -f bedrock-server.zip
        echo "Extracao concluida!"
    else
        echo ""
        echo "=========================================="
        echo "  ERRO: Arquivo bedrock-server.zip nao encontrado"
        echo "=========================================="
        echo ""
        exit 1
    fi
fi

# Dar permissao
chmod +x bedrock_server 2>/dev/null || true

# Voltar ao diretorio principal
cd "$SCRIPT_DIR"

# Criar server.properties
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
