# Inventário e expansão

Atualizado em 16/10/2026 a partir da documentação e das validações compartilhadas pelo usuário. Sem inventário remoto automatizado.

| Identificador | Ambiente | Recursos conhecidos | Estado |
|---|---|---|---|
| ServerLow2 | Oracle Micro | 1 vCPU / 1 GB RAM | Hub e Agent local; online no print compartilhado |
| Doméstico | Ubuntu Server | i5-3337U / 6 GB RAM / SSD 240 GB | Agent online no print compartilhado; Docker em produção |
| serverk3s | Google Cloud / Debian 13 | 4 vCPU / 16 GB RAM / disco 30 GB | Agent conectado após ajuste de DNS, confirmado pelo usuário |
| Novo host 1 | A confirmar | A levantar | Planejado |
| Novo host 2 | A confirmar | A levantar | Planejado |
| Novo host 3 | A confirmar | A levantar | Planejado |

ServerLow1 e EC2 t3.small aparecem no contexto como candidatos. O terceiro novo host não está identificado. Os Workers Kubernetes planejados não são tratados como existentes.

## Ficha a preencher para cada novo host

- Alias público, provedor, SO e arquitetura; manter endereços administrativos no inventário privado.
- CPU, RAM, discos, serviços existentes e criticidade.
- Docker presente? Tailscale ativo? Permissão de saída HTTPS ao Hub?
- Instalação escolhida, diretório, versão/digest, responsável e data.
- Sistemas de arquivos e containers que devem aparecer no painel.
- Evidência revisada e resultado da validação.

## Critérios de aceite por host

- [ ] Identidade e escopo confirmados antes de executar comandos.
- [ ] Configuração e autorização da implantação registradas.
- [ ] Agent online e métricas atualizadas no Hub.
- [ ] CPU/RAM/discos esperados conferidos; Docker conferido se aplicável.
- [ ] Consumo registrado segundo o protocolo de medição.
- [ ] Recuperação após reinício do Agent validada em janela autorizada.
- [ ] Alerta de indisponibilidade testado em janela autorizada.
- [ ] Versão, evidências e pendências documentadas sem segredos.

Implante um host por vez. Nenhum item acima autoriza reinício ou interrupção de produção automaticamente.
