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
PLAYIT_URL="${PLAYIT_BASE_URL}/${PLAYIT_FILE}"
PLAYIT_PATH="${PLAYIT_DIR}/${PLAYIT_FILE}"

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
if [ -f "$PLAYIT_PATH" ]; then
    echo "[PLAYIT] Agente já existe: ${PLAYIT_FILE}"
else
    echo "[PLAYIT] Baixando agente..."
    echo "        URL: ${PLAYIT_URL}"
    
    if command -v wget &>/dev/null; then
        wget -q --show-progress -O "$PLAYIT_PATH" "$PLAYIT_URL" 2>&1 || {
            echo "[PLAYIT] Erro no download com wget, tentando curl..."
            curl -fsSL -o "$PLAYIT_PATH" "$PLAYIT_URL"
        }
    else
        curl -fsSL -o "$PLAYIT_PATH" "$PLAYIT_URL"
    fi
    
    if [ $? -eq 0 ] && [ -f "$PLAYIT_PATH" ]; then
        echo "[PLAYIT] Download concluído!"
    else
        echo "[PLAYIT] ERRO: Falha ao baixar o agente!"
        exit 1
    fi
fi

# ================================================
# DAR PERMISSÃO DE EXECUÇÃO
# ================================================
echo "[PLAYIT] Configurando permissões..."
chmod +x "$PLAYIT_PATH"

# Criar link simbólico para facilitar
ln -sf "$PLAYIT_PATH" "${PLAYIT_DIR}/playit" 2>/dev/null || true
echo "[PLAYIT] Permissões configuradas!"

# ================================================
# VERIFICAR SE JÁ ESTÁ AUTENTICADO
# ================================================
# O Playit armazena credenciais em ~/.config/playit_gg/
# Também cria arquivos de agente no diretório atual ou em ~/.config/playit_gg/
NEEDS_AUTH=true

# Verificar configuração global do Playit
if [ -f "$HOME/.config/playit_gg/playit.toml" ]; then
    NEEDS_AUTH=false
    echo "[PLAYIT] Agente já autenticado!"
fi

# ================================================
# INICIAR PLAYIT AGENT
# ================================================
echo "[PLAYIT] Iniciando túnel..."

# Mudar para diretório do Playit para que os arquivos fiquem lá
cd "$PLAYIT_DIR"

# Iniciar o Playit em segundo plano
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
        echo "Iniciando em modo interativo..."
        echo ""
        "$PLAYIT_PATH" &
    else
        "$PLAYIT_PATH" --setup-code "$PLAYIT_SETUP_CODE" &
    fi
else
    # Já está autenticado, apenas iniciar
    "$PLAYIT_PATH" &
fi

# Voltar ao diretório do script
cd "$SCRIPT_DIR"

# Aguardar um momento para o Playit iniciar
sleep 2

echo "[PLAYIT] Túnel iniciado em segundo plano!"

# ================================================
# PREPARAR SERVIDOR BEDROCK
# ================================================
echo ""
echo "[BEDROCK] Preparando servidor..."
echo ""

cd servidor

# Verificar se bedrock_server ja existe
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

# Dar permissão
chmod +x bedrock_server 2>/dev/null || true

# Voltar ao diretório principal
cd "$SCRIPT_DIR"

# ================================================
# CRIAR/ATUALIZAR SERVER.PROPERTIES
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
# OBTER INFORMAÇÕES DE REDE
# ================================================
INTERNAL_IP=$(hostname -I 2>/dev/null | awk '{print $1}')
if [ -z "$INTERNAL_IP" ]; then
    INTERNAL_IP="127.0.0.1"
fi

EXTERNAL_IP=$(curl -s --max-time 5 "https://api.ipify.org" 2>/dev/null || echo "")

# ================================================
# INICIAR SERVIDOR BEDROCK
# ================================================
echo ""
echo "[BEDROCK] Iniciando servidor..."
echo ""

cd servidor
exec ./bedrock_server
