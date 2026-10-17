# Arquitetura e decisões

## Fluxo de coleta

O Hub centraliza histórico, painel e alertas. Agents coletam recursos dos hosts e, com acesso ao daemon Docker, métricas dos containers. O painel do Hub permanece em loopback e é servido por HTTPS privado via Tailscale Serve.

No ServerLow2, o Compose compartilha um socket Unix entre Hub e Agent; o Agent também possui URL local do Hub. No serverk3s foi validado WebSocket de saída por HTTPS. O modo usado no servidor doméstico ainda precisa ser registrado.

## Decisões e consequências

| Escolha | Motivo | Limite / contrapartida |
|---|---|---|
| Beszel centralizado | Escopo de métricas compatível com uma operação pequena | Não cobre sozinho logs, tracing ou saúde funcional das aplicações |
| Reutilizar VM Micro | Evitar provisionar outra VM apenas para o painel | Memória de 1 GB; consumo e disco precisam ser acompanhados |
| Tailscale + Serve | Acesso privado e HTTPS | Dependência da tailnet, políticas de acesso e resolução de nomes |
| WebSocket nos novos Agents | Conexão iniciada pelo servidor monitorado | Saída HTTPS e autenticação precisam funcionar |
| Compose em hosts com Docker | Reutilizar ferramenta já operada | Docker não deve ser instalado automaticamente em hosts que não o usam |
| Agent binário como alternativa | Evitar introduzir Docker só para métricas | Serviço systemd e permissões precisam de procedimento específico |

## Pontos de falha

A queda do Hub interrompe o painel e a visão central; não prova indisponibilidade das aplicações. Uma falha comum de rede/Tailscale pode afetar vários Agents ao mesmo tempo. O próprio painel não é uma verificação externa independente de sua disponibilidade.

O histórico reside em disco local no ServerLow2. Backup externo e restauração testada ainda são pendências. Não há alta disponibilidade demonstrada.

## Referências

- [Instalação de Agents](https://beszel.dev/guide/agent-installation)
- [Segurança Beszel](https://beszel.dev/guide/security)
- [Tailscale Serve](https://tailscale.com/docs/reference/tailscale-cli/serve)
