# Operação

## Diagnóstico sem alterar serviços

Execute no host correspondente:

```bash
bash scripts/coletar-estado.sh
bash scripts/verificar-hub.sh https://seu-hub.seu-tailnet.ts.net
```

Consulte logs com `sudo docker compose logs --tail=100 beszel-agent` no diretório do Agent; no Hub, use o serviço `beszel`. Revise os logs antes de compartilhar.

| Sintoma | Verificação inicial |
|---|---|
| `no such host` | DNS usado pelo container; conferir `dns: 100.100.100.100` e Tailscale ativo |
| Timeout | Tailnet, permissões de acesso e destino HTTPS |
| Connection refused | Serviço e Tailscale Serve no Hub |
| Erro TLS | Nome HTTPS, certificado e relógio do sistema; não desabilitar validação TLS |
| Falha de autenticação | Chave pública e token do sistema, sem imprimi-los em relatórios |
| Container Up / host offline | Logs do Agent e do Hub; estado do processo não valida coleta |

O teste HTTPS não testa o handshake WebSocket nem a autenticação do Agent. O incidente real está em [001-dns-agent-gcp.md](incidentes/001-dns-agent-gcp.md).

## Atualização controlada

Antes de qualquer mudança: registrar versão/digest, revisar compatibilidade e release notes, validar backup recuperável e combinar janela quando houver impacto. Atualize um Agent por vez. Aplique mudanças do Compose com `docker compose up -d`; `docker restart` não atualiza variáveis de ambiente.

O modelo atual usa `latest`. Reversão exige a imagem anterior identificada e avaliação de compatibilidade dos dados; restaurar apenas uma imagem não garante reversão de migrações do banco.

## Alertas a configurar e testar

Comece por indisponibilidade, memória e disco. Defina limiares e duração após medir o comportamento normal de cada host. Registre canal, destinatário, condição, teste, recebimento e recuperação. Nenhuma entrega de notificação está confirmada neste repositório.

Teste indisponibilidade em janela autorizada; não interrompa serviços de aplicação. Uma falha do Hub requer verificação independente se houver necessidade de alerta sobre o próprio painel.

## Backup e restauração — entrega pendente

Definir destino externo, frequência, retenção e proteção de credenciais. Escolher um método consistente suportado pela versão instalada; copiar banco aberto sem coordenação não é uma validação de backup.

O teste deve restaurar em ambiente isolado, sem Agents de produção apontados para ele. Registrar versão, data do backup, duração da recuperação, acesso administrativo e histórico recuperado. RPO (perda tolerável de dados) e RTO (tempo tolerável de recuperação) ainda precisam ser definidos e medidos.

Não há script de backup neste projeto porque o método e o destino ainda não foram validados.
