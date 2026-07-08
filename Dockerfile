# Minecraft Bedrock Dedicated Server - Docker Image
# https://minecraft.net

FROM ubuntu:22.04

LABEL maintainer="ServidorViaHost"
LABEL description="Minecraft Bedrock Dedicated Server for testing"

# Variáveis de ambiente
ENV DEBIAN_FRONTEND=noninteractive
ENV MINECRAFT_VERSION=1.21.40

# Instalar dependências
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    libcurl4 \
    libssl3 \
    && rm -rf /var/lib/apt/lists/*

# Criar diretório do servidor
WORKDIR /minecraft

# Copiar scripts de setup (opcional - pode ser usado para setup interno)
COPY setup.sh /minecraft/setup.sh
RUN chmod +x setup.sh

# Copiar script de start
COPY start.sh /minecraft/start.sh
RUN chmod +x start.sh

# NOTA: Os arquivos do servidor devem ser baixados na execução
# O bedrock_server não pode ser incluído diretamente devido à licença
# Execute setup.sh dentro do container ou monte os arquivos

# Criar estrutura de diretórios
RUN mkdir -p /minecraft/server

# Copiar server.properties padrão
COPY server/server.properties /minecraft/server/server.properties

# Expor porta UDP do Minecraft Bedrock
EXPOSE 19132/udp

# Permitir configuração de players
RUN useradd -m -s /bin/bash minecraft && \
    chown -R minecraft:minecraft /minecraft

USER minecraft

# Comando padrão - inicia o servidor (assumindo que está configurado)
CMD ["/bin/bash", "-c", "cd /minecraft/server && ./bedrock_server"]

# Para build e uso:
# 
# Build:
#   docker build -t minecraft-bedrock-test .
#
# Run (com setup automático):
#   docker run -it --cap-add=NET_RAW --cap-add=NET_BIND_SERVICE \
#      -p 19132:19132/udp \
#      -v $(pwd)/server:/minecraft/server \
#      minecraft-bedrock-test /bin/bash setup.sh
#
# Run (servidor já configurado):
#   docker run -it --cap-add=NET_RAW --cap-add=NET_BIND_SERVICE \
#      -p 19132:19132/udp \
#      -v $(pwd)/server:/minecraft/server \
#      minecraft-bedrock-test
#
# Observação: A porta UDP 19132 precisa ser exposta com --cap-add=NET_RAW
