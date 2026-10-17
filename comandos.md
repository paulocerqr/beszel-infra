# Guia inicial — Beszel com Docker Compose e Tailscale

Este guia documenta a instalação do Hub e do Agent local no ServerLow2, Oracle Cloud Micro com 1 vCPU e 1 GB RAM, e orienta a expansão para Agents remotos.

**O Hub, o Agent local e o Agent doméstico já estão instalados.** Nas instalações existentes, comece pelas verificações; execute etapas de configuração apenas quando necessárias e autorizadas. Os comandos abaixo são instruções para execução manual, não um script de instalação automática.

## 1. Verificar o ambiente existente

No servidor que será inspecionado:

```bash
hostname
cat /etc/os-release
free -h
df -h
sudo docker --version
sudo docker compose version
sudo docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'
tailscale status
tailscale serve status
```

Se algum comando não existir, registre a dependência ausente antes de instalar. Confirme o diretório real do projeto: `~/beszel` é apenas o caminho sugerido para uma instalação nova.

No diretório da instalação existente:

```bash
sudo docker compose ps
sudo docker compose logs --tail=100 beszel beszel-agent
sudo docker stats --no-stream beszel beszel-agent
```

Revise os logs antes de compartilhá-los e oculte credenciais ou dados sensíveis. Não execute comandos de atualização ou recriação nesta etapa.

## 2. Preparar dependências em um servidor novo

### Docker e Compose

Instale somente se estiverem ausentes, seguindo o procedimento oficial para o sistema identificado:

- [Docker Engine no Ubuntu](https://docs.docker.com/engine/install/ubuntu/)
- [Docker Engine no Debian](https://docs.docker.com/engine/install/debian/)

Não use o repositório APT do Ubuntu em Debian. Não remova pacotes conflitantes nem atualize todo o sistema de produção sem avaliar os serviços existentes.

Após a instalação autorizada:

```bash
sudo systemctl enable --now docker
sudo docker --version
sudo docker compose version
```

Este guia usa `sudo docker`; adicionar um usuário ao grupo `docker` concede privilégios equivalentes a root e não é requisito.

### Tailscale

Se ainda não estiver instalado, siga a [instalação oficial para Linux](https://tailscale.com/download/linux). Em um host novo, após instalar:

```bash
sudo systemctl enable --now tailscaled
sudo tailscale up
tailscale status
tailscale ip -4
```

Conclua a autenticação na tailnet e valide suas regras de acesso. Não execute novamente a configuração de uma instalação existente sem verificar suas opções atuais.

## 3. Preparar os arquivos do Hub

Somente em uma instalação nova, crie o diretório:

```bash
mkdir -p ~/beszel
cd ~/beszel
```

Copie para esse diretório o [docker-compose.yml](docker-compose.yml) e o [.env.example](.env.example) deste repositório. O Compose é a referência da configuração; não é necessário manter outra cópia do YAML neste guia.

Ele define:

- Hub com porta `127.0.0.1:8090`, acessível localmente.
- Agent local com rede do host e socket Unix compartilhado em `/beszel_socket/beszel.sock`.
- Persistência em `beszel_data/` e `beszel_agent_data/`.
- Reinício automático com `unless-stopped`.
- Acesso ao socket Docker para métricas de containers.

Crie o `.env` apenas se ele ainda não existir:

```bash
(umask 077; cp -n .env.example .env)
chmod 600 .env
nano .env
```

Não substitua um `.env` existente. Inicialmente, mantenha chave e token vazios; eles serão obtidos após iniciar o Hub.

## 4. Configurar o acesso privado ao painel

Primeiro, confira se já existe configuração Serve neste host:

```bash
tailscale serve status
```

Se não houver configuração que precise ser preservada, configure o proxy HTTPS privado para o Hub:

```bash
sudo tailscale serve --bg http://127.0.0.1:8090
tailscale serve status
```

Siga as orientações apresentadas pelo Tailscale caso seja necessário habilitar HTTPS na tailnet. Antes de o Hub iniciar, o destino pode estar indisponível.

Use o endereço HTTPS exibido pelo Serve no `.env`:

```dotenv
BESZEL_URL=https://seu-servidor.seu-tailnet.ts.net
BESZEL_KEY=
BESZEL_TOKEN=
```

O acesso depende da conexão à tailnet e das permissões de rede. Use Serve, sem habilitar Funnel ou publicar a porta `8090` na internet. Consulte a [documentação do Serve](https://tailscale.com/docs/reference/tailscale-cli/serve).

## 5. Iniciar o Hub antes do Agent

No diretório do Compose:

```bash
sudo docker compose config --quiet
sudo docker compose up -d beszel
sudo docker compose ps
sudo docker compose logs --tail=100 beszel
```

A validação com `--quiet` evita imprimir a configuração expandida com o token. Não compartilhe a saída de `docker compose config` sem essa opção.

Acesse a URL privada pelo navegador e conclua o cadastro inicial do administrador, se for uma instalação nova. Em um Hub existente, use a conta já configurada.

## 6. Cadastrar e iniciar o Agent local

No painel do Hub:

1. Adicione um sistema chamado `ServerLow2`, caso ainda não exista.
2. No campo Host / IP, informe `/beszel_socket/beszel.sock`.
3. Copie a chave pública e o token apresentados para esse sistema.
4. Preencha as variáveis correspondentes no `.env` local.

```dotenv
BESZEL_URL=https://seu-servidor.seu-tailnet.ts.net
BESZEL_KEY="ssh-ed25519 CHAVE_PUBLICA_DO_HUB"
BESZEL_TOKEN="TOKEN_DO_SISTEMA"
```

Os valores acima são exemplos. Não registre tokens reais no Git ou na documentação.

```bash
sudo docker compose config --quiet
sudo docker compose up -d beszel-agent
sudo docker compose ps
sudo docker compose logs --tail=100 beszel-agent
```

O caminho do socket deve coincidir no painel, no volume compartilhado e em `LISTEN`. No Compose atual, `HUB_URL=http://127.0.0.1:8090` também permite ao Agent local alcançar o Hub pela rede do host. Essa URL local não deve ser copiada para Agents remotos.

A configuração de socket local segue a [documentação do Beszel](https://beszel.dev/guide/agent-installation).

## 7. Validar a instalação

Confirme:

- Hub e Agent em execução, sem reinícios recorrentes.
- ServerLow2 online no painel, com histórico sendo atualizado.
- Métricas de CPU, memória, disco e rede compatíveis com o host.
- Containers esperados aparecendo quando a integração Docker estiver habilitada.
- Acesso ao painel pela tailnet e publicação da porta Docker restrita a loopback.
- Consumo do Hub e do Agent compatível com a VM de 1 GB RAM.

```bash
sudo docker compose ps
sudo docker stats --no-stream beszel beszel-agent
sudo ss -lntp
```

Os healthchecks estão comentados no Compose atual; um container em execução, sozinho, não comprova que as métricas estejam chegando ao painel.

## 8. Adicionar Agents em outros servidores

Não replique o Hub nos servidores monitorados. O Agent doméstico já existe e deve ser validado antes de qualquer reinstalação.

Para cada host adicional:

1. Confirme identidade, sistema, recursos, acesso e conectividade privada com o Hub.
2. Cadastre o sistema no Hub e obtenha a configuração do Agent pela interface.
3. Use Compose onde Docker já estiver disponível; em hosts sem Docker, avalie o Agent binário com systemd.
4. Configure o endereço privado real do Hub, chave e token do sistema.
5. Após autorização, instale apenas o Agent e valide suas métricas antes de avançar ao próximo host.

O Beszel suporta WebSocket iniciado pelo Agent, o que permite planejar a conexão sem liberar uma porta pública de entrada no servidor monitorado. Confirme a versão e o modo escolhido antes de configurar listeners ou firewall. Consulte [instalação](https://beszel.dev/guide/agent-installation) e [segurança](https://beszel.dev/guide/security).

## 9. Manutenção e recuperação

- Antes de atualizar, registre as imagens e versões em uso e faça backup recuperável do Hub.
- O Compose usa `latest`: uma atualização pode trazer uma versão diferente. Planeje a compatibilidade entre Hub e Agents e a reversão antes de baixar novas imagens.
- O bind mount de `beszel_data/` garante persistência local, mas não protege contra perda da VM. Defina cópia externa e teste restauração; não trate uma cópia de arquivos de banco em uso como backup consistente.
- Preserve o `.env` por um meio seguro, separado do Git, e proteja backups que contenham credenciais.
- Não remova diretórios persistentes para resolver problemas de inicialização.
- O socket Docker concede acesso sensível ao daemon; `:ro` no mount não restringe, por si só, as operações da API a consultas.
- Verifique periodicamente memória, espaço em disco e crescimento do histórico no ServerLow2.

Registre as configurações verificadas e as pendências em [OBSERVABILIDADE_BESZEL.md](OBSERVABILIDADE_BESZEL.md), sem incluir segredos.
