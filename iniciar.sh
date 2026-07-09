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
echo "=========================================="
echo "  INFORMACOES DE CONEXAO"
echo "=========================================="
echo ""

# Tentar obter IP interno
INTERNAL_IP=$(hostname -I 2>/dev/null | awk '{print $1}')
if [ -z "$INTERNAL_IP" ]; then
    INTERNAL_IP="127.0.0.1"
fi

# Tentar obter IP externo
EXTERNAL_IP=$(curl -s --max-time 5 "https://api.ipify.org" 2>/dev/null || echo "")

echo "IP INTERNO: $INTERNAL_IP"
if [ -n "$EXTERNAL_IP" ]; then
    echo "IP EXTERNO: $EXTERNAL_IP"
fi
echo ""
echo "PORTA: 19132 (UDP)"
echo ""
echo "=========================================="
echo "  COMO ENTRAR NO MINECRAFT"
echo "=========================================="
echo ""
echo "1. Abra Minecraft Bedrock Edition"
echo "2. Va em Jogar > Empresas"
echo "3. Adicione servidor:"
echo "   - Nome: ServidorViaHost"
echo "   - Endereco: $INTERNAL_IP:19132"
if [ -n "$EXTERNAL_IP" ]; then
    echo ""
    echo "   (Para conexao externa use: $EXTERNAL_IP:19132)"
fi
echo ""
echo "=========================================="
echo ""

# Iniciar servidor
cd servidor
exec ./bedrock_server
