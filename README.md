# Observabilidade com Beszel

Repositório de configuração e documentação do monitoramento dos meus servidores com **Beszel**, priorizando baixo consumo de recursos, acesso privado e facilidade de manutenção.

O foco deste projeto é centralizar métricas de CPU, memória, disco, rede e containers Docker, conforme o suporte e a configuração dos Agents. Kubernetes, provisionamento de infraestrutura e deploy de aplicações ficam fora do escopo principal.

## Arquitetura e estado atual

O **Beszel Hub** está instalado no **ServerLow2**, uma VM Oracle Cloud Micro com 1 vCPU e 1 GB de RAM. O painel é acessado de forma privada pelo **Tailscale Serve**.

| Servidor | Papel | Estado documentado |
|---|---|---|
| ServerLow2 — Oracle Cloud | Hub e Agent local | Instalados |
| Servidor doméstico — Ubuntu Server | Agent; host de aplicações Docker em produção | Instalado; conexão e métricas a validar |
| ServerLow1 — Oracle Cloud | Candidato a receber Agent | Instalação não confirmada |
| EC2 t3.small — AWS | Candidato a receber Agent | Instalação não confirmada |
| serverk3s — Google Cloud | Candidato a receber Agent | Instalação não confirmada |

Os estados refletem a documentação disponível, sem validação remota. A escolha dos próximos servidores a monitorar ainda está pendente.

## Arquivos do projeto

| Arquivo | Conteúdo |
|---|---|
| [docker-compose.yml](docker-compose.yml) | Hub e Agent local, com persistência, reinício automático e comunicação local por socket Unix |
| [.env.example](.env.example) | Modelo das variáveis de URL, chave pública e token |
| [OBSERVABILIDADE_BESZEL.md](OBSERVABILIDADE_BESZEL.md) | Arquitetura de observabilidade, estado da implantação e verificações pendentes |
| [instrucoesIniciais.md](instrucoesIniciais.md) | Procedimento inicial de instalação com Docker Compose e Tailscale |
| [info.md](info.md) | Inventário geral e contexto complementar da infraestrutura |

O Compose presente no repositório configura o Hub e seu Agent local; a instalação de Agents remotos deve ser preparada para cada servidor.

## Configuração e cuidados operacionais

- O Hub publica a porta `8090` somente em `127.0.0.1`; o acesso privado previsto utiliza Tailscale Serve.
- As variáveis `BESZEL_URL`, `BESZEL_KEY` e `BESZEL_TOKEN` são configuradas em um arquivo `.env` local, usando `.env.example` como referência.
- Os diretórios `beszel_data/`, `beszel_agent_data/` e `beszel_socket/` são persistidos localmente e ignorados pelo Git, assim como o `.env`.
- Credenciais e chaves privadas não devem ser versionadas. Persistência local não substitui backup.
- Alterações em servidores, serviços e rede exigem autorização prévia, preservando as aplicações e os dados de produção.

## Próximos passos

1. Validar o funcionamento do Hub e dos Agents existentes, incluindo métricas e consumo de recursos.
2. Confirmar os próximos servidores e sua conectividade privada.
3. Preparar e, após autorização, instalar os Agents adicionais, um servidor por vez.
4. Documentar versões, atualização, alertas e backup/restauração do Hub.

O Beszel cobre o monitoramento de recursos previsto neste projeto. Logs de aplicações, tracing e métricas específicas de Kubernetes exigem soluções próprias e não fazem parte da implantação atual.
