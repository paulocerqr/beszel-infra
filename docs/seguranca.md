# Segurança e publicação

## Controles do projeto

- Hub publicado apenas em loopback; acesso pelo HTTPS privado do Tailscale Serve.
- Novos Agents no modelo WebSocket não precisam de porta 45876 aberta; `DISABLE_SSH` afeta somente o servidor SSH interno do Agent.
- Restrinja na tailnet quem acessa o painel e quem alcança o Hub. Acesso à rede não substitui autenticação no Beszel.
- `.env` com permissão 600, tokens por sistema e credenciais fora do Git.
- Acesso a `docker.sock` é sensível: mount `:ro` não limita as operações da API Docker. Aceite e documente esse risco antes de habilitar a coleta.

## Antes de publicar

Em 17/10/2026, os IPs administrativos, caminhos pessoais de chaves, hostname privado e identificadores GCP conhecidos foram substituídos por exemplos nos arquivos e no histórico local. Branches e referências remotas locais foram reescritas; reflogs e objetos antigos locais foram expurgados. Isso não altera o GitHub, outros clones ou caches externos. O push com reescrita permanece pendente de autorização e coordenação.

Revise arquivos atuais e histórico Git, incluindo `info.md`, documentos de contexto e `terraforms.tf`. O `.gitignore` não remove informações já versionadas. Não reescreva histórico compartilhado sem planejamento.

Remova ou masque tokens, senhas, chaves privadas, emails, IDs de projetos/contas, endereços de administração e nomes privados desnecessários. Chave pública não é segredo, mas pode ser omitida em evidências. Não basta cobrir texto com uma camada reversível: exporte e confira a imagem final.

Os prints compartilhados no diagnóstico continham um token. Substitua-o no Hub e no host afetado; a rotação ainda não foi confirmada. Esses prints não foram copiados para os assets do projeto.

## Backup e incidentes

Backups podem conter credenciais e dados do painel. Proteja acesso e armazenamento. Uma cópia local não cobre perda da VM. Procedimento de restauração testado está pendente; consulte [operação](operacao.md).
