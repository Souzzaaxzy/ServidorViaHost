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

# Criar pasta servidor
mkdir -p servidor
cd servidor

# Verificar se bedrock_server ja existe
if [ ! -f "bedrock_server" ]; then
    echo "Baixando Minecraft Bedrock Server..."
    echo ""
    
    # URLS alternativas
    URLS=(
        "https://minecraft.azureedge.net/bin-linux/bedrock-server-1.21.40.zip"
        "https://minecraft.net/content/minecraft.net/uploads/bedrock-server-1.21.40.zip"
        "https://pocketserver.net/bedrock/bedrock-server-1.21.40.zip"
    )
    
    DOWNLOADED=0
    for URL in "${URLS[@]}"; do
        echo "Tentando: $URL"
        if curl -L --connect-timeout 10 --max-time 120 -o bedrock-server.zip "$URL" 2>/dev/null; then
            if [ -s "bedrock-server.zip" ]; then
                DOWNLOADED=1
                break
            fi
        fi
        if command -v wget &>/dev/null; then
            if wget -q -O bedrock-server.zip "$URL" 2>/dev/null; then
                if [ -s "bedrock-server.zip" ]; then
                    DOWNLOADED=1
                    break
                fi
            fi
        fi
    done
    
    if [ "$DOWNLOADED" = "1" ]; then
        echo ""
        echo "Extraindo arquivos..."
        unzip -o bedrock-server.zip 2>/dev/null || python3 -m zipfile -e bedrock-server.zip . 2>/dev/null || true
        rm -f bedrock-server.zip
        echo "Download concluído!"
    else
        echo ""
        echo "=========================================="
        echo "  ERRO: Falha no download"
        echo "=========================================="
        echo ""
        echo "O Bedrock Server precisa ser enviado manualmente."
        echo ""
        echo "1. Baixe em:"
        echo "   https://www.minecraft.net/bedrockdedicatedserver"
        echo ""
        echo "2. Extraia o conteudo para a pasta 'servidor/'"
        echo ""
        echo "3. Obedecedca a estrutura:"
        echo "   servidor/"
        echo "   ├── bedrock_server"
        echo "   ├── server.properties"
        echo "   └── ..."
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
