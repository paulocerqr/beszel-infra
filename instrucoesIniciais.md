# Configurando servidor que o beszel irá ficar

## `1. Docker + Docker Compose`

```bash
# 1. Instalar dependências
sudo apt update
sudo apt upgrade

# 2. Adicionar repositório oficial do Docker

sudo install -m 0755 -d /etc/apt/keyrings

sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  -o /etc/apt/keyrings/docker.asc

sudo chmod a+r /etc/apt/keyrings/docker.asc

sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

# 3. Instalar Docker + Compose
sudo apt update
sudo apt install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin
  
# 4. Habilitar Docker na inicialização

sudo systemctl enable --now docker

# 5. Executar Docker sem sudo (opcional)

sudo usermod -aG docker $USER
newgrp docker

# 5.1 instalar pacotes de comandos caso de erro(Ubuntu 26.04 Minimal não possui o comando newgrp instalado por padrão.)

sudo apt install -y util-linux-extra

# 6. Verificar instalação

docker --version
docker compose version
docker run hello-world
```

## `2. Tailscale`

```bash
# 1. Instalar Tailscale
curl -fsSL https://tailscale.com/install.sh | sh

# 2. Habilitar o serviço
sudo systemctl enable --now tailscaled

# 3. Conectar à sua conta Tailscale
sudo tailscale up # gera um link para autenticação

# 4. Verificar a conexão
tailscale status
tailscale ip -4 # retorna um ip

# 5. Acessar sua VM pelo Tailscale

ssh ubuntu@ip_retornado

```

## `3. Beszel + Configuração`

```bash
# 1. Criar o diretório
mkdir -p ~/beszel
cd ~/beszel

# Preparar o acesso pelo Tailscale
sudo tailscale serve --bg 8090 # Esse comando cria um endereço HTTPS privado na sua rede Tailscale
tailscale serve status # verifica se foi criada

export TERM=xter # acesso ssh necessita

# 2. Criar o Docker Compose
nano docker-compose.yml

"
services:
  beszel:
    image: henrygd/beszel:latest
    container_name: beszel
    restart: unless-stopped
    environment:
      APP_URL: "${BESZEL_URL}"
    ports:
      - "127.0.0.1:8090:8090"
    volumes:
      - ./beszel_data:/beszel_data
      - ./beszel_socket:/beszel_socket
    # healthcheck:
    #   test: ['CMD', '/beszel', 'health', '--url', 'http://localhost:8090']
    #   interval: 120s
    #   start_period: 10s
    #   timeout: 5s

  beszel-agent:
    image: henrygd/beszel-agent:latest
    container_name: beszel-agent
    restart: unless-stopped
    network_mode: host
    volumes:
      - ./beszel_agent_data:/var/lib/beszel-agent
      - ./beszel_socket:/beszel_socket
      - /var/run/docker.sock:/var/run/docker.sock:ro
    environment:
      LISTEN: /beszel_socket/beszel.sock
      HUB_URL: http://127.0.0.1:8090
      KEY: "${BESZEL_KEY}"
      TOKEN: "${BESZEL_TOKEN}"
    # healthcheck:
    #   test: ['CMD', '/agent', 'health']
    #   interval: 120s
"

# 3. Configurar as variáveis
nano .env

"
BESZEL_URL=https://seu-hub.seu-tailnet.ts.net
BESZEL_KEY=
BESZEL_TOKEN=
"

# Proteger arquivo
chmod 600 .env

```

## `4. Inicializar o Hub`

- Acesse `“BESZEL_UR”` no navegador e adicione um Sistema
- Nome pode ser o da sua escolha
- Host / IP coloque: `/beszel_socket/beszel.sock`
- Copie a chave publica e o token e depois adicione no .env

![image.png](Configurando%20servidores/image.png)

```bash
# Inicia Containers 
docker compose up -d beszel

# adicione as credenciais no .env

"
BESZEL_URL=https://seu-hub.seu-tailnet.ts.net
BESZEL_KEY="ssh-ed25519 AAAA..."
BESZEL_TOKEN="seu-token"
"

# Agora inicie o agente
docker compose up -d

# Para acompanhar os logs e veja se o agente subiu
docker compose ps
docker compose logs -f

# Agora em “BESZEL_UR” deve aparecer o seu host e as informações dele
```
