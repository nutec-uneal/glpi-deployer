# GLPI Deploy

## Sumário

- [GLPI Deploy](#glpi-deploy)
  - [Sumário](#sumário)
  - [Sobre](#sobre)
    - [Requisitos e Dependências](#requisitos-e-dependências)
      - [Docker](#docker)
      - [Aplicação GLPI](#aplicação-glpi)
  - [Preparação de Ambiente](#preparação-de-ambiente)
    - [Docker:](#docker-1)
    - [GLPI:](#glpi)
  - [Instalação](#instalação)
    - [Criação de Diretórios - Armazenamento de Dados](#criação-de-diretórios---armazenamento-de-dados)
    - [Configuração dos Containers - Docker-Compose](#configuração-dos-containers---docker-compose)
    - [Configuração de Permissões](#configuração-de-permissões)
      - [Banco de Dados](#banco-de-dados)
      - [Aplicação - GLPI](#aplicação---glpi)
    - [Configurando Proxy Reverso - Nginx](#configurando-proxy-reverso---nginx)
    - [Finalização](#finalização)
- [Intalação com backup (Migração/Restauração)](#intalação-com-backup-migraçãorestauração)
  - [OBSERVAÇÕES](#observações)


## Sobre

GLPI é um sistema de código aberto escrito em PHP para Gerenciamento de Ativos de TI, rastreamento de problemas e central de serviços.

- [GLPI Website](https://glpi-project.org/)
- [GPLI Documentação](https://glpi-project.org/pt-br/documentacao/)

### Requisitos e Dependências

#### Docker

- [Docker e Docker-Compose](https://docs.docker.com/)

#### Aplicação GLPI 

- [GLPI Website](http://glpi-project.org/) (para baixar versão atual).
- [Repositório no Github](https://github.com/glpi-project/glpi/releases) (Todas as versões - Recomendado).
- Versões Testadas: 10.0.2 (INSEGURA), 10.0.5.


## Preparação de Ambiente

### Docker:

Certifique-se que a aplicação está executando.

```bash
# Em algumas distribuições Linux.

# Para verificar se o Docker está executando.
$ sudo systemctl status docker.service

# Para iniciar o Docker (caso necessário).
$ sudo systemctl start docker.service

# Para fazer o Docker iniciar junto com o Sistema Operacional.
$ sudo systemctl enable docker.service  
```

### GLPI:

Extraia o arquivo *glpi-{version}.tgz*. Copie a pasta extraída para "\*\*/glpi-deploy/app". 

Obs: "\*\*" simboliza um caminho qualquer na máquina do usuário. Ajuste-o de acordo com suas preferências/necessidades.

## Instalação

### Criação de Diretórios - Armazenamento de Dados 

```bash
# Dir. Config
$ mkdir **/dirconfig

# Dir. Dados da Aplicação
$ mkdir -p **/dirdata/{_cron,_dumps,_graphs,_lock,_pictures,_plugins,_rss,_sessions,_tmp,_uploads,_cache}

# Dir. Log
$ mkdir **/dirlog

# Dir. Dados do Banco
$ mkdir **/dirdbdata

# Copie o arquivo "local_define.php" para o diretório "config"
$ cp **/glpi-deploy/config-app/local_define.php **/dirconfig

# utilize "sudo" no início dos comandos caso o path requeira permissão de admin.
```

Sugestão (no Linux):
  - Dir. Config: */etc/glpi*
  - Dir. Dados da Aplicação: */var/lib/glpi*
  - Dir. Log: */var/log/glpi*
  - Dir. Dados do Banco: */var/lib/mysqlglpi*

### Configuração dos Containers - Docker-Compose

```yml
# docker-compose.yml
# ... networks

config:
  - subnet: '172.18.0.0/28'
    gateway: 172.18.0.1

# Configure subnet e gateway para o "range" de sua preferência.

# Não obrigatório.
```

```yml
# docker-compose.yml
# ... app

# Altere (descomente) a secção "port" caso queira.
# Não recomendado.
# Recomendado usar um proxy reverso para expor à internet (com HTTPS).
ports:
  - '80:80' # por exemplo.

# Altere a secção "volume",
#   aponte para as pastas criadas anteriomente.
# Ficando:
volumes:
  - '**/dirconfig:/etc/glpi'
  - '**/dirdata/:/var/lib/glpi'
  - '**/dirlog:/var/log/glpi'

# Altere o valor de ipv4_address de acordo
#   com o seu "range" configurado.
glpi-net:
  ipv4_address: 172.18.0.3
```

```yml
# docker-compose.yml
# ... db

# Altere (descomente) a secção "port" caso queira.
# Cuida, isso pode expor seu banco para outros. hosts.
# Só altere se isso realmente for desejado.
ports:
  - '127.0.0.1:3306:3306' # por exemplo

# Altere a secção "volume",
#   aponte para as pastas criadas anteriomente.
volumes:
  - '**/dirdbdata:/var/lib/mysql'

# Altere a secção "environment".
# Altere o conteúdo após "=".
environment:
  - MARIADB_ROOT_PASSWORD=rootpass
  - MARIADB_ROOT_HOST=localhost # "localhost" ou "%"(não recomendado)
  - MARIADB_USER=username
  - MARIADB_PASSWORD=userpass

# Altere o valor de ipv4_address de acordo
#   com o seu "range" configurado.
glpi-net:
  ipv4_address: 172.18.0.2
```

```bash
# Construa a imagem e execute os containers
$ docker-compose -f docker-compose.yml up
```

### Configuração de Permissões

#### Banco de Dados

```bash
# Em "db/grant.sql"

# Linhas 15 e 23. Todos os locais.
... TO 'username'@'%' IDENTIFIED BY 'userpass'; 

## Substitua 'username' em ...['username'@'%']... pelo valor inserido em MARIADB_USER

## Substitua 'userpass' em ...[IDENTIFIED BY 'userpass']... pelo valor inserido em MARIADB_PASSWORD

## Ao configurar a aplicação o banco de deve ser inserido como "db_glpi". Caso queira utilizar outro nome substitua o termo "db_glpi" na linha 23 pelo de sua preferência.
```

```bash
# Acesse o container através do comando
$ sudo docker exec -it glpi-db /bin/bash

# Entre no SGBD (com o usuário root e senha root)
$ mariadb -u root -p

# Agora, no terminal cole - um por vez - os dois comando do arquivo "db/grant.sql". Certifique-se de ter feitos as alterações.
```

#### Aplicação - GLPI
```bash
# Entre no container através do comando
$ sudo docker exec -it glpi-app /bin/bash

# Execute 
$ chown -R www-data:www-data /etc/glpi 
$ chown -R www-data:www-data /var/lib/glpi
$ chown -R www-data:www-data /var/log/glpi
```

### Configurando Proxy Reverso - Nginx

Para adicionar uma camada a mais de segurança recomendamos usar alguma aplicação de proxy reverso, como por exemplo o Nginx. Isso permite esconder o servidor Apache do usuário final além de tornar mais fácil e escalável configurar coisas como HTTPS, redirecionamentos, etc.

- [Guia para instalação e configuração do Nginx](https://github.com/nutecuneal/nginx-rproxy-deploy)

Por questão de segurança a rede do Nginx e do GLPI foram projetas para manter o isolamento dos containers. Por isso, execute o comando abaixo para permitir a comunicação entre containers:

```bash
# Adicione as permissões na "iptables"
$ iptables -I DOCKER-USER -s IP-GLPI -d IP-NGINX -j ACCEPT
$ iptables -I DOCKER-USER -s IP-NGINX -d IP-GLPI -j ACCEPT
```

### Finalização

A partir de seu navegador acesse o domínio/IP e a porta configurada no servidor.

Siga o [*Intall-Wizard GLPI*](https://glpi-install.readthedocs.io/en/latest/install/wizard.html) para concluir o processo.

<br>

**Obs**: Por motivo de segurança recomenda-se remover a pasta de instalação de dentro do código da aplicação. Por isso, faça:


```bash
# Remova os containers
$ sudo docker rm -f glpi-app glpi-db

# Remova o imagem
$ sudo docker rmi -f glpi-deploy-glpi

# Remova os caches de build
$ docker builder prune -a

# Execute os containers novamente
$ sudo docker-compose -f docker-compose.yml up
```

# Intalação com backup (Migração/Restauração)

## OBSERVAÇÕES

Dentro do GLPI:

- Autenticação e destinatário.
- Adicionar Remetente.
- `Geral:Assistência:Permitir abertura de chamados anônimos`
- `Configurar:notifições:notifições`

Ações automáticas:

- mailgate *(Puxa os chamados que vem do email)*
- queuednotification *(Envio da fila de notificação)*

Tarefa automática:

- Periodo de execução: É o horário em que a tarefa pode ser executada, ex: de 0 horas até 24 horas, daquele dia.

TO-DO:

**Verificar o modelo de resposta ao usuário do chamado**.