# Minecraft Bedrock Server - ServidorViaHost

Projeto de teste para hospedagem com inicializacao automatica do **servidor Minecraft Bedrock oficial**.

## Comando de Inicializacao

```
bash iniciar.sh
```

Este e o comando que o host executa automaticamente ao ligar o projeto.

## Estrutura do Projeto

```
ServidorViaHost/
├── servidor/                 # Arquivos do Minecraft Bedrock
│   ├── bedrock_server        # Executavel principal
│   ├── server.properties     # Configuracoes
│   └── ...
├── iniciar.sh               # Entry point (comando do host)
├── start.sh                # Script de inicializacao
├── setup.sh                # Script de instalacao
├── package.json            # Compatibilidade Node.js
├── udp-test.js             # Teste de porta UDP
├── Dockerfile              # Para Docker
└── README.md               # Este arquivo
```

## Como Funciona

### Fluxo de Inicializacao

```
Host executa: bash iniciar.sh
       |
       v
start.sh verifica existencia do servidor
       |
       v
Se nao existir -> executa setup.sh (baixa servidor)
       |
       v
Se existir -> verifica permissoes
       |
       v
Inicia bedrock_server
```

### Setup Automatico

O `setup.sh`:
1. Detecta arquitetura do sistema (x86_64, ARM64)
2. Mostra se e compativel
3. Baixa servidor Bedrock oficial
4. Extrai arquivos na pasta `servidor/`
5. Configura permissoes

## Plataformas Compativeis

- Linux (x86_64, ARM64)
- Docker
- Hosts de projetos (Railway, Render, etc.)
- Termux Android
- ARMv7 (suporte limitado)

## Conectar ao Servidor

### Informacoes
- **Porta:** UDP 19132
- **Versao:** Compativel com Minecraft Bedrock Edition

### No Minecraft
1. Abra Minecraft Bedrock Edition
2. Va em **Jogar** > **Empresas** ou **Servidores**
3. Adicione servidor:
   - **Nome:** ServidorViaHost
   - **Endereco:** `IP_DO_HOST:19132`
4. Conecte!

### Encontrar IP do Servidor
```bash
# IP local
hostname -I | awk '{print $1}'

# IP publico
curl ifconfig.me
```

## Porta UDP 19132

O Minecraft Bedrock usa **UDP**, nao TCP.

### Importante
- A porta 19132 deve estar liberada no firewall
- Em Docker: use `-p 19132:19132/udp`
- Algumas redes bloqueiam UDP

### Testar Porta
```bash
node udp-test.js
```

## Configuracoes (server.properties)

```properties
server-name=ServidorViaHost Teste
gamemode=survival
difficulty=easy
max-players=5
view-distance=6
tick-distance=4
allow-cheats=true
server-port=19132
```

## Para Hosts de Projetos

### Configuracao Comum
- **Build Command:** `chmod +x *.sh`
- **Start Command:** `bash iniciar.sh`

### Docker
```bash
docker build -t minecraft-bedrock .
docker run -p 19132:19132/udp minecraft-bedrock
```

## Limitacoes

1. **Sem Java** - Usa apenas servidor Bedrock C++
2. **Sem alternativas** - Nao usa PocketMine ou NukkitX
3. **Arquitetura** - ARMv7 pode nao funcionar
4. **Portas UDP** - Algumas redes bloqueiam

## Licenca

Este projeto e para fins de teste. O Minecraft Bedrock Server e propriedade da Microsoft/Mojang.
