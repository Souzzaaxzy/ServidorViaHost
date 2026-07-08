#!/bin/bash

# ================================================
# Minecraft Bedrock Dedicated Server - Start
# ================================================

echo "=========================================="
echo "  Iniciando Minecraft Bedrock Server"
echo "=========================================="

# Verificar se é Linux
if [[ "$(uname)" != "Linux" ]]; then
    echo "Erro: Este script é apenas para Linux!"
    exit 1
fi

# Verificar se está no diretório correto
if [ ! -d "server" ]; then
    echo "Erro: Pasta 'server' não encontrada!"
    echo "Execute setup.sh primeiro."
    exit 1
fi

cd server

# Verificar se o arquivo bedrock_server existe
if [ ! -f "bedrock_server" ]; then
    echo "Erro: bedrock_server não encontrado!"
    echo "Execute setup.sh para baixar o servidor."
    exit 1
fi

# Dar permissão de execução (caso ainda não tenha)
if [ ! -x "bedrock_server" ]; then
    echo "Dando permissão de execução ao bedrock_server..."
    chmod +x bedrock_server
fi

# Verificar dependências
echo "Verificando dependências..."

# Verificar libcurl3 para distribuições antigas
if ldconfig -p | grep -q "libcurl.so" || ldconfig -p | grep -q "libcurl.so.4"; then
    echo "✓ libcurl encontrada"
else
    echo "! libcurl não encontrada, mas continuando..."
fi

# Criar symbolic link para библиотеки se necessário
if [ -d "libs" ]; then
    if [ ! -L "lib" ]; then
        ln -sf libs lib
    fi
fi

echo ""
echo "=========================================="
echo "  Servidor iniciando..."
echo "=========================================="
echo ""
echo "Para detener o servidor, pressione Ctrl+C"
echo "Ou conecte-se via console e digite: stop"
echo ""
echo "=========================================="
echo ""

# Iniciar o servidor
./bedrock_server
