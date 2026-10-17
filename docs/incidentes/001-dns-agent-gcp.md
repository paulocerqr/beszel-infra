# Incidente 001 — Agent no Google Cloud não resolvia o Hub

## Contexto e impacto

Durante o cadastro do `serverk3s`, o container estava em execução, mas o sistema permanecia offline no painel. O host conseguia pingar o Hub e recebia HTTP 200 por HTTPS. O incidente afetava a coleta desse host; não há evidência de impacto nas aplicações.

Os logs compartilhados registram tentativas em 17/10/2026; timezone e relógio dessa origem não foram verificados. Não foi medido tempo total de resolução.

## Evidência sanitizada

```text
WARN WebSocket connection failed err="dial tcp: lookup <hub>.ts.net on 169.254.169.254:53: no such host"
```

O Agent usava o resolvedor do Google Cloud, incapaz de resolver o nome privado da tailnet nesse contexto. O funcionamento no host não comprovava DNS dentro do container. Compartilhar a rede com `network_mode: host` não torna idêntica a configuração do resolvedor.

## Correção

Adicionado ao serviço do Agent e aplicado com Compose:

```yaml
network_mode: host
dns:
  - 100.100.100.100
```

A URL HTTPS do Hub foi mantida, assim como WebSocket e `DISABLE_SSH: "true"`. Não foi necessário abrir portas públicas.

## Validação e aprendizado

O usuário confirmou a conexão após a alteração. A configuração passou a integrar o [modelo de Agent](../../deploy/agent/compose.yml) e o [guia](../../comandos.md).

O DNS depende do Tailscale ativo. A imagem não contém `sh`; comandos de diagnóstico que tentavam abrir shell não funcionaram. Verifique DNS, TLS e autenticação como etapas distintas.

As capturas originais expunham token e não foram publicadas. Rotação da credencial continua sem confirmação.
