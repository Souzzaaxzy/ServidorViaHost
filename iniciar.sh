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
    echo "Servidor ja extraido! Pulando..."
    echo ""
else
    echo "Extraindo Minecraft Bedrock Server..."
    echo ""
    
    if [ -f "bedrock-server.zip" ]; then
        unzip -o bedrock-server.zip 2>/dev/null || python3 -m zipfile -e bedrock-server.zip . 2>/dev/null || true
        rm -f bedrock-server.zip
        echo "Extracao concluida!"
    else
        echo ""
        echo "ERRO: bedrock-server.zip nao encontrado!"
        echo ""
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
server-name=ServidorViaHost
gamemode=survival
difficulty=easy
max-players=10
view-distance=6
tick-distance=4
allow-cheats=true
server-port=19132
EOF
fi

# Obter IP
INTERNAL_IP=$(hostname -I 2>/dev/null | awk '{print $1}')
if [ -z "$INTERNAL_IP" ]; then
    INTERNAL_IP="localhost"
fi

EXTERNAL_IP=$(curl -s --max-time 5 "https://api.ipify.org" 2>/dev/null || echo "")

echo ""
echo "=========================================="
echo "  SERVIDOR INICIADO!"
echo "=========================================="
echo ""
echo "  NOME: ServidorViaHost"
echo ""
if [ -n "$EXTERNAL_IP" ]; then
    echo "  ENDERECO: $EXTERNAL_IP"
else
    echo "  ENDERECO: $INTERNAL_IP"
fi
echo "  PORTA: 19132 (UDP)"
echo ""
echo "=========================================="
echo "  COMO ENTRAR"
echo "=========================================="
echo ""
echo "1. Abra Minecraft Bedrock Edition"
echo "2. Va em: Jogar > Empresas"
echo "3. Clique: Adicionar Servidor"
echo ""
echo "4. Preencha:"
echo "   Nome: ServidorViaHost"
if [ -n "$EXTERNAL_IP" ]; then
    echo "   Endereco: $EXTERNAL_IP:19132"
else
    echo "   Endereco: $INTERNAL_IP:19132"
fi
echo "   Porta: 19132"
echo ""
echo "=========================================="
echo ""

# Iniciar servidor
cd servidor
exec ./bedrock_server
