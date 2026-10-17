# Medição de consumo e custo

## O que queremos demonstrar

Quanto a coleta e a centralização consomem, em quais condições, e qual custo adicional geram. Usar uma VM gratuita ou créditos temporários não torna toda a infraestrutura permanentemente gratuita.

**Não há benchmark concluído.** Percentuais em um print isolado mostram estado instantâneo, não overhead do Beszel nem custo mensal.

## Protocolo mínimo

1. Registre data UTC, hardware, SO, versões/digests de Hub e Agents, número de hosts e carga de aplicações.
2. Execute `bash scripts/coletar-estado.sh` no host, com permissão para consultar Docker. Guarde a saída bruta fora do Git até revisá-la.
3. Colete amostras em repouso e sob carga normal, em horários anotados, incluindo CPU/RAM de Hub e Agent. A janela inicial sugerida é 24 horas com amostras em diferentes momentos; registre a janela realmente observada.
4. Observe o disco do Hub no início e no fim usando a mesma unidade. Registre tamanho, intervalo e número de sistemas; não extrapole crescimento linear sem ressalvas.
5. Se medir antes/depois da instalação, use carga comparável. Não desligue o Agent em produção apenas para obter baseline sem autorização.
6. Publique valores observados, quantidade de amostras e limitações. Sem baseline, descreva consumo absoluto, sem afirmar overhead causal.

O `docker stats` fornece consumo instantâneo dos containers. CPU em percentagem precisa ser interpretada considerando número de CPUs e método da ferramenta; memória do container não representa toda a memória do host.

## Resultados

| Data / janela | Host / versão | Sistemas no Hub | Amostras / carga | CPU Hub / Agent | RAM Hub / Agent | Crescimento de dados |
|---|---|---|---|---|---|---|
| Pendente | Pendente | Pendente | Pendente | Não medido | Não medido | Não medido |

## Custo incremental mensal

| Componente | Como apurar | Valor observado |
|---|---|---|
| VM do Hub | Fatura real; registrar franquia/free tier | Pendente |
| Disco e backups | Uso, retenção e armazenamento externo | Pendente |
| Tráfego | Fatura por provedor; separar franquia e excedente | Pendente |
| VMs monitoradas | Custo preexistente separado do custo de observabilidade | Pendente |
| Tailscale | Plano e condições efetivamente usados | Pendente |

Registre moeda, período e data. Créditos de laboratório devem ser identificados como temporários. Não publique números de conta ou dados de faturamento pessoais.
