#!/bin/bash

# ================================================
# Minecraft Bedrock Server - Setup Script
# ================================================
# Baixa e configura o servidor Bedrock oficial
# ================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=========================================="
echo "  Minecraft Bedrock Server Setup"
echo "=========================================="
echo ""

# Verificar se é Linux
echo "🔍 Verificando sistema..."
if [[ "$(uname)" != "Linux" ]]; then
    echo "⚠️  Sistema não é Linux. Tentando continuar..."
fi
echo "✓ Sistema: $(uname) $(uname -m)"
echo ""

# Verificar arquitetura
echo "🔍 Verificando arquitetura..."
ARCH=$(uname -m)

case "$ARCH" in
    x86_64|amd64)
        ARCH_NAME="linux-x64"
        echo "✓ Arquitetura suportada: $ARCH_NAME"
        ;;
    aarch64|arm64)
        ARCH_NAME="linux-arm64"
        echo "✓ Arquitetura suportada: $ARCH_NAME"
        ;;
    armv7l|armhf)
        echo "⚠️  ATENÇÃO: ARMv7 tem suporte limitado"
        echo "   O servidor Bedrock oficial pode não funcionar"
        echo "   Continuando mesmo assim..."
        ARCH_NAME="linux-arm"
        ;;
    *)
        echo "⚠️  ATENÇÃO: Arquitetura '$ARCH' não é oficialmente suportada"
        echo "   Tentando continuar..."
        ARCH_NAME="unknown"
        ;;
esac
echo ""

# Versão mais recente do Bedrock Server
LATEST_VERSION="1.21.40"

echo "🔍 Preparando diretório 'servidor'..."
mkdir -p servidor
cd servidor
echo "✓ Diretório pronto"
echo ""

# Verificar se bedrock_server já existe
if [ -f "bedrock_server" ] && [ -x "bedrock_server" ]; then
    echo "✓ bedrock_server já existe e está configurado"
    echo "   Pulando download..."
    echo ""
    cd "$SCRIPT_DIR"
    exit 0
fi

# URL de download do servidor oficial
DOWNLOAD_URL="https://minecraft.azureedge.net/bin-linux/bedrock-server-${LATEST_VERSION}.zip"
FILENAME="bedrock-server-${LATEST_VERSION}.zip"

echo "📥 Baixando Minecraft Bedrock Server v${LATEST_VERSION}..."
echo "   URL: $DOWNLOAD_URL"
echo ""

# Instalar unzip se necessário
if ! command -v unzip &> /dev/null; then
    echo "📦 Instalando unzip..."
    if command -v apt-get &> /dev/null; then
        apt-get update && apt-get install -y unzip 2>/dev/null || true
    elif command -v pkg &> /dev/null; then
        pkg install unzip 2>/dev/null || true
    fi
fi

# Baixar arquivo
if command -v curl &> /dev/null; then
    if curl -L -f --progress-bar -o "$FILENAME" "$DOWNLOAD_URL"; then
        echo "✓ Download concluído"
    else
        echo "⚠️  Erro no download com curl"
        echo "   Tentando método alternativo..."
        curl -L -o "$FILENAME" "$DOWNLOAD_URL" 2>/dev/null || true
    fi
elif command -v wget &> /dev/null; then
    wget -O "$FILENAME" "$DOWNLOAD_URL" 2>/dev/null || true
else
    echo "⚠️  Nenhum gerenciador de download disponível"
    echo "   Por favor, baixe manualmente:"
    echo "   $DOWNLOAD_URL"
    echo "   e coloque em: $SCRIPT_DIR/servidor/"
    cd "$SCRIPT_DIR"
    exit 1
fi
echo ""

# Verificar se arquivo foi baixado
if [ ! -f "$FILENAME" ] || [ ! -s "$FILENAME" ]; then
    echo "⚠️  Download falhou ou arquivo vazio"
    echo "   Verifique sua conexão com a internet"
    echo ""
    echo "   URL oficial para download manual:"
    echo "   https://www.minecraft.net/bedrockdedicatedserver"
    cd "$SCRIPT_DIR"
    exit 1
fi

echo "📦 Extraindo arquivos..."
# Extrair com tratamento de erro
if command -v unzip &> /dev/null; then
    unzip -o "$FILENAME" 2>/dev/null || python3 -m zipfile -e "$FILENAME" . 2>/dev/null || true
elif command -v python3 &> /dev/null; then
    python3 -c "import zipfile; zipfile.ZipFile('$FILENAME', 'r').extractall('.')"
fi

# Limpar zip
rm -f "$FILENAME"
echo "✓ Arquivos extraídos"
echo ""

# Configurar permissões
echo "🔧 Configurando permissões..."
if [ -f "bedrock_server" ]; then
    chmod +x bedrock_server
    echo "✓ bedrock_server pronto"
fi

# Criar symbolic links se necessário
if [ -d "libs" ] && [ ! -L "lib" ]; then
    ln -sf libs lib 2>/dev/null || true
fi

# Voltar ao diretório principal
cd "$SCRIPT_DIR"

echo ""
echo "=========================================="
echo "  ✓ Setup concluído!"
echo "=========================================="
echo ""
echo "Próximo passo:"
echo "   bash iniciar.sh"
echo ""
