# 🎮 ServidorViaHost - Minecraft Bedrock Server

Projeto de teste para verificar se um ambiente Linux/Docker consegue executar um **servidor Minecraft Bedrock oficial**.

## ⚠️ Requisitos Importantes

- **Não usa Java** - Minecraft Bedrock usa C++
- **Apenas servidor Bedrock oficial** - NukkitX ou PocketMine NÃO são usados
- **Suporte:** Linux (x86_64, ARM64), Termux Android, Docker

## 📁 Estrutura do Projeto

```
ServidorViaHost/
├── server/                 # Arquivos do Minecraft Bedrock Server
│   ├── bedrock_server      # Executável principal
│   ├── server.properties   # Configurações do servidor
│   └── ...
├── setup.sh               # Script de instalação
├── start.sh              # Script de inicialização
├── udp-test.js           # Teste de porta UDP (Node.js)
├── Dockerfile            # Para ambientes Docker
└── README.md             # Este arquivo
```

## 🚀 Instalação e Uso

### Termux (Android)

```bash
# 1. Instalar dependências no Termux
pkg update && pkg install wget unzip nodejs

# 2. Navegar até o diretório do projeto
cd /caminho/para/ServidorViaHost

# 3. Dar permissão de execução
chmod +x setup.sh start.sh

# 4. Executar o setup
./setup.sh

# 5. Iniciar o servidor
./start.sh
```

### Linux (Desktop/Server)

```bash
# 1. Instalar dependências
# Ubuntu/Debian:
sudo apt-get install wget unzip curl

# Fedora/RHEL:
sudo dnf install wget unzip curl

# Arch Linux:
sudo pacman -S wget unzip curl

# 2. Navegar até o diretório do projeto
cd /caminho/para/ServidorViaHost

# 3. Dar permissão de execução
chmod +x setup.sh start.sh

# 4. Executar o setup
./setup.sh

# 5. Iniciar o servidor
./start.sh
```

### Docker

```bash
# 1. Build da imagem
docker build -t minecraft-bedrock-test .

# 2. Executar com setup
docker run -it --cap-add=NET_RAW --cap-add=NET_BIND_SERVICE \
   -p 19132:19132/udp \
   -v $(pwd)/server:/minecraft/server \
   minecraft-bedrock-test /bin/bash setup.sh

# 3. Executar o servidor
docker run -it --cap-add=NET_RAW --cap-add=NET_BIND_SERVICE \
   -p 19132:19132/udp \
   -v $(pwd)/server:/minecraft/server \
   minecraft-bedrock-test
```

## 🔌 Teste de Porta UDP

O projeto inclui um teste de porta UDP para verificar se o ambiente suporta conexões na porta 19132.

### Pré-requisitos
```bash
# Instalar Node.js
# Ubuntu/Debian:
sudo apt-get install nodejs npm

# Termux:
pkg install nodejs

# Verificar instalação:
node --version
```

### Executar o Teste

```bash
# No diretório do projeto
node udp-test.js
```

### Saídas Possíveis

**Sucesso:**
```
==========================================
  UDP 19132 aberto com sucesso
==========================================
Endereço: 0.0.0.0:19132
Família: IPv4

O servidor Minecraft Bedrock pode usar esta porta.
```

**Erro (Porta em uso):**
```
==========================================
  ERRO ao abrir UDP 19132
==========================================
Código do erro: EADDRINUSE
Motivo: Porta já está em uso.
Solução: Outra aplicação está usando a porta 19132.
```

**Erro (Permissão negada):**
```
==========================================
  ERRO ao abrir UDP 19132
==========================================
Código do erro: EACCES
Motivo: Permissão negada.
Solução: Execute como root ou use sudo.
```

## 🎮 Conectando ao Servidor

### Informações de Conexão
- **IP:** Endereço IP da máquina host
- **Porta:** 19132 (UDP)
- **Versão:** Compatível com a versão baixada

### Como Conectar

1. Abra o Minecraft Bedrock Edition (Win10, Xbox, Mobile, Switch)
2. Vá em **Jogar** → **Servidores**
3. Ou vá em **Jogar** → **Empresas**
4. Adicione um servidor com:
   - **Nome:** ServidorViaHost
   - **Endereço:** `SEU_IP:19132`
5. Conecte-se!

### Encontrando seu IP

**Linux/Termux:**
```bash
# IP local
hostname -I | awk '{print $1}'

# IP público
curl ifconfig.me
```

## 📝 Configurações Padrão (server.properties)

```properties
server-name=Bedrock Test Server
gamemode=survival
difficulty=normal
max-players=5
allow-cheats=true
server-port=19132
```

### Parâmetros Principais

| Parâmetro | Descrição | Valor Padrão |
|-----------|-----------|--------------|
| `server-name` | Nome do servidor | Bedrock Test Server |
| `gamemode` | Modo de jogo (survival/creative/adventure) | survival |
| `difficulty` | Dificuldade (peaceful/easy/normal/hard) | normal |
| `max-players` | Máximo de jogadores | 5 |
| `allow-cheats` | Permite comandos de admin | true |
| `server-port` | Porta UDP do servidor | 19132 |
| `level-name` | Nome do mundo | Bedrock Level |

## ⚠️ Limitações e Problemas Conhecidos

### Portas UDP

- **O Minecraft Bedrock usa UDP**, não TCP
- Algumas redes/hospitais bloqueiam portas UDP
- Em Docker, é necessário `--cap-add=NET_RAW` para绑定 portas UDP
- Em Termux, portas abaixo de 1024 podem requerir root

### Arquiteturas

- **Suportado:** x86_64, ARM64
- **NÃO suportado:** ARMv7 (Raspberry Pi 1/2) - Use NukkitX

### Termux-Specifico

- Para portas < 1024, instale `tsu` ou use `termux-setup-storage`
- O servidor pode ter performance limitada em dispositivos móveis

### Docker-Specifico

- O Bedrock Server precisa de acesso RAW socket
- Use `--sysctl net.ipv4.ip_unprivileged_port_start=19132` no Docker

## 🔧 Solução de Problemas

### "libcurl.so.4: cannot open shared object file"
```bash
# Ubuntu/Debian
sudo apt-get install libcurl4

# Fedora
sudo dnf install libcurl
```

### "Cannot open libstdc++.so.6"
```bash
# Ubuntu/Debian
sudo apt-get install libstdc++6
```

### Servidor não inicia
```bash
# Verifique se o executável tem permissão
chmod +x server/bedrock_server

# Verifique logs
./start.sh 2>&1 | tee log.txt
```

## 📜 Licença

Este projeto é apenas para fins de teste. O Minecraft Bedrock Server é propriedade da Microsoft/Mojang e está sujeito aos seus termos de serviço.

## 🤝 Contribuições

Sinta-se à vontade para abrir issues ou pull requests para melhorias!

---

**Feito com ❤️ para testes de servidor Minecraft Bedrock**
