# Minecraft Bedrock Server

Servidor Minecraft Bedrock oficial com inicializacao automatica.

## Comando de Inicializacao

```bash
bash iniciar.sh
```

Pronto! O servidor sera baixado e iniciado automaticamente.

## Caracteristicas

- Baixa automaticamente o Minecraft Bedrock Server oficial
- Configura permissoes
- Cria server.properties padrao
- Inicia na porta **UDP 19132**

## Configuracao

```properties
server-name=ServidorViaHost Teste
gamemode=survival
difficulty=easy
max-players=5
allow-cheats=true
server-port=19132
```

## Conectar

1. Abra Minecraft Bedrock Edition
2. Va em **Jogar** > **Empresas**
3. Adicione servidor:
   - **Endereco:** `IP:19132`

## Para Hosts de Projetos

- **Comando:** `bash iniciar.sh`
- **Porta:** UDP 19132

## Limitacoes

- Usa apenas servidor Bedrock oficial (sem Java)
- Suporta x86_64 e ARM64
- Porta UDP 19132 deve estar liberada
