/**
 * Minecraft Bedrock Server - UDP Port Test
 * 
 * Este script testa se a porta UDP 19132 está disponível
 * para o servidor Minecraft Bedrock.
 */

const dgram = require('dgram');

const PORT = 19132;
const HOST = '0.0.0.0';

const server = dgram.createSocket('udp4');

server.on('listening', () => {
    const address = server.address();
    console.log(`\n==========================================`);
    console.log(`  UDP ${PORT} aberto com sucesso`);
    console.log(`==========================================`);
    console.log(`Endereço: ${address.address}:${address.port}`);
    console.log(`Família: ${address.family}`);
    console.log(`\nO servidor Minecraft Bedrock pode usar esta porta.`);
    console.log(`\nPressione Ctrl+C para encerrar o teste.`);
    console.log(`==========================================\n`);
    
    // Manter o servidor aberto por alguns segundos para testes
    setTimeout(() => {
        console.log('Encerrando teste de porta...');
        server.close();
        process.exit(0);
    }, 5000);
});

server.on('error', (err) => {
    console.error(`\n==========================================`);
    console.error(`  ERRO ao abrir UDP ${PORT}`);
    console.error(`==========================================`);
    console.error(`Código do erro: ${err.code}`);
    
    if (err.code === 'EACCES') {
        console.error('Motivo: Permissão negada.');
        console.error('Solução: Execute como root ou use sudo.');
    } else if (err.code === 'EADDRINUSE') {
        console.error('Motivo: Porta já está em uso.');
        console.error('Solução: Outra aplicação está usando a porta 19132.');
        console.error('         Pare o outro serviço ou altere a porta no server.properties.');
    } else if (err.code === 'EADDRNOTAVAIL') {
        console.error('Motivo: Endereço não disponível.');
        console.error('Solução: Verifique a configuração de rede.');
    } else {
        console.error(`Motivo: ${err.message}`);
    }
    
    console.error(`\nDetalhe técnico: ${err}`);
    console.error(`==========================================\n`);
    
    server.close();
    process.exit(1);
});

server.on('message', (msg, rinfo) => {
    console.log(`Recebido: ${msg.toString()} de ${rinfo.address}:${rinfo.port}`);
});

// Iniciar o servidor
console.log('==========================================');
console.log('  Teste de Porta UDP - Minecraft Bedrock');
console.log('==========================================');
console.log(`Tentando abrir porta UDP ${PORT}...`);

server.bind(PORT, HOST);
