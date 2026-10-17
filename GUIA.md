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

## 8. Cadastrar um novo servidor no Hub

Este procedimento instala somente o Agent no servidor remoto. Não copie o Compose do Hub para esse host. Para instalações existentes, confira a configuração antes de editar arquivos ou recriar containers.

### 8.1. Preparar e verificar a rede privada

Instale Docker e Tailscale conforme a seção 2, se ainda estiverem ausentes. Autentique o novo servidor na mesma tailnet do Hub, com permissões de acesso ao HTTPS do painel. Não é necessário configurar Tailscale Serve no servidor do Agent.

No novo servidor:

```bash
tailscale status
tailscale ip -4
curl --connect-timeout 10 --max-time 20 \
  -sS -o /dev/null -w 'HTTP %{http_code}\n' \
  https://seu-servidor.seu-tailnet.ts.net
```

Substitua o endereço pela URL HTTPS real do Hub, publicada pelo Tailscale Serve. Uma resposta `HTTP 200` confirma acesso à página pelo host, mas não garante resolução DNS dentro do container nem autenticação do Agent. Ping sozinho também não valida HTTPS.

### 8.2. Cadastrar o sistema no painel

No Hub, selecione **Adicionar Sistema**:

- **Nome:** um identificador do novo servidor, por exemplo `serverk3s`.
- **Host / IP:** o IP Tailscale do novo servidor, obtido com `tailscale ip -4` (`100.x.x.x`).
- **Porta:** mantenha `45876` no cadastro; no modo WebSocket descrito abaixo, ela não será usada para entrada no Agent.
- **Chave pública e token:** copie os valores apresentados pelo Hub para esse sistema.

Salve o cadastro. Use o token do novo sistema, sem reutilizar o token de outro host.

### 8.3. Criar o Compose do Agent

O modelo reutilizável está em [deploy/agent/compose.yml](deploy/agent/compose.yml), acompanhado do [.env.example](deploy/agent/.env.example). Ele exige URL, chave e token preenchidos antes da inicialização; o exemplo abaixo apresenta os mesmos parâmetros de rede e coleta.

No servidor remoto:

```bash
mkdir -p ~/beszel-agent
cd ~/beszel-agent
nano docker-compose.yml
```

Conteúdo do arquivo:

```yaml
services:
  beszel-agent:
    image: henrygd/beszel-agent:latest
    container_name: beszel-agent
    restart: unless-stopped
    network_mode: host
    dns:
      - 100.100.100.100
    volumes:
      - ./beszel_agent_data:/var/lib/beszel-agent
      - /var/run/docker.sock:/var/run/docker.sock:ro
    environment:
      HUB_URL: "${BESZEL_URL}"
      KEY: "${BESZEL_KEY}"
      TOKEN: "${BESZEL_TOKEN}"
      DISABLE_SSH: "true"
```

O Agent inicia uma conexão WebSocket de saída para o Hub por HTTPS. Não é necessário abrir a porta `45876` para entrada. `DISABLE_SSH` desativa o servidor SSH interno do Beszel Agent, sem afetar o SSH administrativo do sistema operacional. Consulte a [documentação das variáveis do Beszel](https://www.beszel.dev/guide/environment-variables).

**DNS privado dentro do container:** `network_mode: host` compartilha a rede, mas não garante que o container use a mesma resolução DNS do host. No Google Cloud, o Agent consultava `169.254.169.254`, que não resolvia o domínio privado do Hub, embora ping e curl funcionassem no host. A configuração `dns: 100.100.100.100` fez o Agent usar o resolvedor local do Tailscale e corrigiu a conexão. Esse padrão depende do Tailscale ativo no host. Consulte [Quad100 do Tailscale](https://tailscale.com/docs/reference/quad100) e [DNS por serviço no Compose](https://docs.docker.com/reference/compose-file/services/#dns).

### 8.4. Configurar URL e credenciais

Crie o arquivo com permissões restritas antes de inserir o token:

```bash
(umask 077; touch .env)
chmod 600 .env
nano .env
```

Conteúdo, substituindo os exemplos pelos valores reais:

```dotenv
BESZEL_URL=https://seu-servidor.seu-tailnet.ts.net
BESZEL_KEY="ssh-ed25519 COLE_A_CHAVE_PUBLICA_DO_HUB"
BESZEL_TOKEN="COLE_O_TOKEN_DO_NOVO_SISTEMA"
```

`BESZEL_URL` deve apontar para o Hub, não para o novo servidor nem para `localhost`. Preserve o nome HTTPS para validar o certificado; não o substitua diretamente pelo IP Tailscale. Não versione o `.env` nem compartilhe seu conteúdo.

### 8.5. Iniciar e validar o Agent

```bash
sudo docker compose config --quiet
sudo docker compose up -d beszel-agent
sudo docker compose ps
sudo docker compose logs --since=2m beszel-agent
sudo docker stats --no-stream beszel-agent
```

Confirme no painel que o novo sistema está online e recebe métricas. Um container com status `Up` não comprova conexão com o Hub.

Após editar o Compose ou as variáveis do `.env`, execute novamente `sudo docker compose up -d beszel-agent` para aplicar as mudanças. Um simples `docker restart` não atualiza as variáveis do container.

Se os logs mostrarem `lookup ... on 169.254.169.254:53: no such host`, confira o bloco `dns` e aplique a configuração novamente. Se o erro mudar, investigue a nova mensagem antes de alterar firewall ou credenciais. A imagem do Agent não possui `sh`; não use `docker exec ... sh` para diagnóstico.

O cadastro do `serverk3s` foi concluído com sucesso após essa correção de DNS, conforme validação manual informada pelo usuário.

## 9. Manutenção e recuperação

- Antes de atualizar, registre as imagens e versões em uso e faça backup recuperável do Hub.
- O Compose usa `latest`: uma atualização pode trazer uma versão diferente. Planeje a compatibilidade entre Hub e Agents e a reversão antes de baixar novas imagens.
- O bind mount de `beszel_data/` garante persistência local, mas não protege contra perda da VM. Defina cópia externa e teste restauração; não trate uma cópia de arquivos de banco em uso como backup consistente.
- Preserve o `.env` por um meio seguro, separado do Git, e proteja backups que contenham credenciais.
- Não remova diretórios persistentes para resolver problemas de inicialização.
- O socket Docker concede acesso sensível ao daemon; `:ro` no mount não restringe, por si só, as operações da API a consultas.
- Verifique periodicamente memória, espaço em disco e crescimento do histórico no ServerLow2.

Registre as configurações verificadas e as pendências em [OBSERVABILIDADE_BESZEL.md](OBSERVABILIDADE_BESZEL.md), sem incluir segredos.
