# Minecraft Bedrock Server + Playit.gg

Servidor Minecraft Bedrock oficial com acesso via internet usando **Playit.gg** para criação automática de túneis.

## Inicialização

```bash
npm start
```

Ou diretamente:

```bash
bash start.sh
```

O servidor será iniciado automaticamente junto com o agente Playit.gg.

## Características

- Minecraft Bedrock Server oficial (Mojang/Microsoft)
- Integração automática com **Playit.gg** para acesso externo
- Download automático do agente Playit na primeira execução
- Arquiteturas suportadas: x86_64, ARM64, ARMv7
- Servidor Bedrock na porta **UDP 19132**

## Configuração do Playit.gg

### 1. Obter o Código de Setup

1. Acesse [playit.gg/account](https://playit.gg/account)
2. Faça login ou crie uma conta
3. Copie seu **Setup Code** (código de configuração)

### 2. Configurar o Código

Edite o arquivo `start.sh` e altere a variável `PLAYIT_SETUP_CODE`:

```bash
# No início do arquivo start.sh
PLAYIT_SETUP_CODE="SEU_CODIGO_AQUI"
```

### 3. Reiniciar o Playit (se necessário)

Se precisar reconfigurar o Playit:

```bash
# Pare o processo atual (Ctrl+C)
#删除 arquivos de configuração
rm -rf playit/

# Inicie novamente
npm start
```

## Arquivos do Playit

Os arquivos do Playit são armazenados na pasta `playit/`:

```
playit/
├── playit-linux-amd64   # Agente executável
├── playit               # Link simbólico para o agente
├── agent/               # Configuração do agente
├── config/              # Configurações
└── credentials/         # Credenciais de autenticação
```

## Descobrir o Endereço do Servidor

Após iniciar o servidor, o Playit.gg fornecerá um endereço público.

### Opção 1: Ver no Console

Quando o servidor inicia, o Playit mostra algo como:

```
Tunnel to: proxy.playit.gg:12345
```

Este é o endereço que você usa no Minecraft.

### Opção 2: Acessar Dashboard

1. Acesse [playit.gg/account](https://playit.gg/account)
2. Faça login
3. Veja seus túneis ativos e os endereços

### Opção 3: Verificar logs

```bash
tail -f playit/agent/logs/*.log
```

## Conectar ao Servidor

1. Abra **Minecraft Bedrock Edition**
2. Vá em **Jogar** > **Empresas**
3. Clique em **Adicionar Servidor**
4. Preencha:
   - **Nome:** ServidorViaHost
   - **Endereço:** `proxy.playit.gg:PORT` (do túnel)
   - **Porta:** (vazia ou a porta indicada)
5. Clique em **Salvar** e conecte!

## Configuração do Servidor

Edite `servidor/server.properties`:

```properties
server-name=ServidorViaHost
gamemode=survival
difficulty=easy
max-players=10
view-distance=6
tick-distance=4
allow-cheats=true
server-port=19132
```

## Estrutura do Projeto

```
ServidorViaHost/
├── start.sh              # Script principal de inicialização
├── package.json          # Configuração npm
├── README.md             # Este arquivo
├── playit/               # Agente e configurações do Playit
│   ├── playit            # Executável do Playit
│   ├── agent/            # Configuração do agente
│   ├── config/           # Configurações
│   └── credentials/     # Credenciais
└── servidor/             # Servidor Minecraft Bedrock
    ├── bedrock_server     # Executável do servidor
    ├── server.properties # Configuração do servidor
    └── world/            # Mundos salvos
```

## Troubleshooting

### "Código não configurado"

Edite `start.sh` e defina o `PLAYIT_SETUP_CODE`.

### Playit não inicia

```bash
# Verifique se há processos antigos
pkill -f playit

# Limpe e reinicie
rm -rf playit/
npm start
```

### Servidor não aparece no Minecraft

1. Verifique se o Playit está rodando corretamente
2. Acesse [playit.gg/account](https://playit.gg/account) para verificar túneis
3. Asegure-se de usar o endereço correto do túnel

### Porta UDP 19132

O servidor Bedrock usa UDP. Se tiver problemas:
- No Linux: `sudo ufw allow 19132/udp`
- No Windows: Configure o firewall
- Em hosts de projetos: A porta geralmente é liberada automaticamente
