# Scripts de diagnóstico

Executar no host inspecionado, com Bash e ferramentas Linux. Sem instalação, SSH automático, alteração de rede ou reinício de serviços.

```bash
bash scripts/coletar-estado.sh
bash scripts/verificar-hub.sh https://seu-hub.seu-tailnet.ts.net
```

`coletar-estado.sh` mostra data UTC, memória, discos e, quando o usuário tem acesso ao Docker, estado/imagem e consumo instantâneo dos containers Beszel. Não imprime variáveis, tokens ou logs. Se não tiver permissão Docker, avisa e retorna erro; execute com `sudo bash scripts/coletar-estado.sh` apenas se apropriado ao host.

`verificar-hub.sh` exige URL HTTPS sem credenciais, query ou fragmento e usa curl com validação TLS e timeout. Retorna zero somente para HTTP 200. Isso comprova acesso HTTPS a partir do host, não DNS no Agent, WebSocket ou autenticação.

A saída pode conter caminhos de discos e nomes internos. Revise antes de versionar; saídas brutas podem ser guardadas em `reports/`, ignorado pelo Git.

Teste local, com respostas simuladas, sem rede ou Docker real:

```bash
bash tests/check-scripts.sh
```
