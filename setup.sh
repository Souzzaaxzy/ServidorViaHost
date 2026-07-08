#!/bin/bash

# ================================================
# Minecraft Bedrock Dedicated Server - Setup
# ================================================

set -e

echo "=========================================="
echo "  Minecraft Bedrock Server Setup"
echo "=========================================="

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Verificar se é Linux
echo -e "\n${YELLOW}[1/5] Verificando sistema...${NC}"
if [[ "$(uname)" != "Linux" ]]; then
    echo -e "${RED}Erro: Este script é apenas para Linux!${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Sistema Linux detectado${NC}"

# Verificar arquitetura
echo -e "\n${YELLOW}[2/5] Verificando arquitetura...${NC}"
ARCH=$(uname -m)
echo "Arquitetura detectada: $ARCH"

# Mapear arquitetura para URL de download
case "$ARCH" in
    x86_64|amd64)
        ARCH_NAME="linux-x64"
        ;;
    aarch64|arm64)
        ARCH_NAME="linux-arm64"
        ;;
    armv7l|armhf)
        echo -e "${RED}Erro: ARMv7 não é suportado pelo servidor oficial Minecraft Bedrock${NC}"
        echo "Considere usar NukkitX ou PocketMine-MP para ARMv7"
        exit 1
        ;;
    *)
        echo -e "${RED}Erro: Arquitetura não suportada: $ARCH${NC}"
        exit 1
        ;;
esac
echo -e "${GREEN}✓ Arquitetura compatível: $ARCH_NAME${NC}"

# Criar diretório server se não existir
echo -e "\n${YELLOW}[3/5] Preparando diretório server...${NC}"
mkdir -p server
cd server
echo -e "${GREEN}✓ Diretório 'server' criado${NC}"

# URL oficial do Minecraft Bedrock Dedicated Server
# Versão mais recente (verifique no site oficial)
LATEST_VERSION="1.21.40"
BASE_URL="https://minecraft.net/bedrockdedicatedserver"
FILENAME="bedrock-server-${LATEST_VERSION}.zip"

echo -e "\n${YELLOW}[4/5] Baixando Minecraft Bedrock Server...${NC}"
echo "Versão: ${LATEST_VERSION}"
echo "Arquivo: ${FILENAME}"

# URL direta para download (versão mais recente conhecida)
DOWNLOAD_URL="https://minecraft.azureedge.net/bin-linux/bedrock-server-${LATEST_VERSION}.zip"

# Tentar download
if command -v curl &> /dev/null; then
    echo "Baixando com curl..."
    if curl -L -o "bedrock-server.zip" "$DOWNLOAD_URL"; then
        echo -e "${GREEN}✓ Download concluído${NC}"
    else
        echo -e "${RED}Erro no download. Tentando método alternativo...${NC}"
        echo "Por favor, baixe manualmente em:"
        echo "https://www.minecraft.net/bedrockdedicatedserver"
        echo "e coloque o arquivo na pasta 'server'"
        exit 1
    fi
elif command -v wget &> /dev/null; then
    echo "Baixando com wget..."
    if wget -O "bedrock-server.zip" "$DOWNLOAD_URL"; then
        echo -e "${GREEN}✓ Download concluído${NC}"
    else
        echo -e "${RED}Erro no download.${NC}"
        exit 1
    fi
else
    echo -e "${RED}Erro: curl ou wget é necessário para baixar o servidor${NC}"
    exit 1
fi

# Verificar se o download foi bem sucedido
if [ ! -f "bedrock-server.zip" ] || [ ! -s "bedrock-server.zip" ]; then
    echo -e "${RED}Erro: Arquivo de download inválido ou vazio${NC}"
    exit 1
fi

# Extrair arquivos
echo -e "\n${YELLOW}[5/5] Extraindo arquivos...${NC}"
if command -v unzip &> /dev/null; then
    unzip -o "bedrock-server.zip"
elif command -v unzip &> /dev/null; then
    # Alternative for systems with different unzip package names
    busybox unzip -o "bedrock-server.zip" 2>/dev/null || apt-get install -y unzip 2>/dev/null || true
else
    # Try using python
    if command -v python3 &> /dev/null; then
        python3 -c "import zipfile; zipfile.ZipFile('bedrock-server.zip', 'r').extractall('.')"
    else
        echo -e "${RED}Erro: unzip não está disponível${NC}"
        echo "Por favor, instale unzip: apt-get install unzip"
        exit 1
    fi
fi

# Limpar arquivo zip
rm -f "bedrock-server.zip"

# Dar permissão de execução ao servidor
echo -e "\n${YELLOW}Configurando permissões...${NC}"
if [ -f "bedrock_server" ]; then
    chmod +x bedrock_server
    echo -e "${GREEN}✓ Permissão de execução concedida ao bedrock_server${NC}"
fi

# Voltar ao diretório principal
cd ..

echo -e "\n=========================================="
echo -e "${GREEN}  Setup concluído com sucesso!${NC}"
echo "=========================================="
echo ""
echo "Próximos passos:"
echo "1. Execute: chmod +x start.sh"
echo "2. Execute: ./start.sh"
echo ""
echo "Nota: Edite server.properties para configurar o servidor"
echo ""
