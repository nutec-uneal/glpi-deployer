# GLPI Deployer

O [GLPI](https://glpi-project.org/) é um sistema de código aberto escrito em PHP para Gerenciamento de Ativos de TI, rastreamento de problemas e central de serviços. [GPLI Documentação](https://glpi-project.org/pt-br/documentacao/).

## Sumário

- [GLPI Deployer](#glpi-deployer)
  - [Sumário](#sumário)
  - [Requisitos e Dependências](#requisitos-e-dependências)
  - [Instalação](#instalação)
    - [Diretório](#diretório)
      - [Banco de Dados](#banco-de-dados)
      - [Aplicação](#aplicação)
    - [Docker-Compose](#docker-compose)
      - [Argumentos (Args)](#argumentos-args)
      - [Portas](#portas)
      - [Volumes](#volumes)
      - [Variáveis de Ambiente (Environment)](#variáveis-de-ambiente-environment)
      - [Rede](#rede)
    - [Executando Docker-Compose](#executando-docker-compose)
    - [Limitação de Acesso](#limitação-de-acesso)
      - [Banco de Dados](#banco-de-dados-1)
    - [Configurando Proxy Reverso](#configurando-proxy-reverso)
    - [Finalização](#finalização)
    - [Segurança](#segurança)
      - [Pasta de Instalção](#pasta-de-instalção)
  - [Guia de Usuário](#guia-de-usuário)


## Requisitos e Dependências

- [Docker e Docker-Compose](https://docs.docker.com/)

- [GLPI Website](http://glpi-project.org/) (para baixar versão atual).

- [Repositório no Github](https://github.com/glpi-project/glpi/releases) (Todas as versões - Recomendado).

- Versões Testadas: 10.0.2 (INSEGURA), 10.0.5, 10.0.9.

<br>

## Instalação

Obs.: ***$(pwd)*** simboliza um caminho qualquer na máquina do usuário. Ajuste-o de acordo com suas preferências/necessidades.

### Diretório

#### Banco de Dados

```bash
# Crie os diretórios.

# Dir. de dados.
$ mkdir $(pwd)/lib-mysql
```

#### Aplicação

```bash
# Crie os diretórios.

# Dir. para configurações.
$ mkdir $(pwd)/etc-glpi

# Dir. para dados.
$ mkdir -p $(pwd)/lib-glpi/{_cron,_dumps,_graphs,_lock,_pictures,_plugins,_rss,_sessions,_tmp,_uploads,_cache,_docs}

# Dir. para logs do glpi.
$ mkdir $(pwd)/log-glpi

# Dir. para armazenar os plugins, marketplace.
$ mkdir $(pwd)/glpi_marketplace

# Dir. para logs do apache.
$ mkdir $(pwd)/log_apache2
```

```bash
# Copie o arquivo "local_define.php" que está em,  ".
# "$(pwd)/glpi-deployer/app/configs/app", para o diretório de configurações.

$ cp $(pwd)/glpi-deployer/app/configs/app/local_define.php $(pwd)/etc-glpi
```

Obs.: configure o proprietário (usuário e grupo) e as permissões das pastas de acordo com o *PUID* e *PGID* utilizado. Tema abordado na seção [Argumentos (Args)](#argumentos-args).

### Docker-Compose

#### Argumentos (Args)

Opcionalmente pode ser adicionado algumas diretivas personalizadas, como: 

```yml
# docker-compose.yml
# Adicione em "services.app.build".

args:
# URL do GLPI (link da internet) ou arquivo.tgz na pasta `app`.
# Default: glpi-10.0.9.tgz
  - GLPI_SOURCECODE_URI=${URI_VALUE}

# ID do Usuário usado. Default: 1024.
  - PUID=${PUID_VALUE}
  
# ID do Grupo usado. Default: 1024.
  - PGID=${PGID_VALUE}
```

#### Portas

```yml
# docker-compose.yml
# Em "services.app".
# Comente/Descomente (e/ou altere) as portas/serviços que você deseja prover.

# Não recomendado alterar.
# Prefira um proxy reverso para expor à internet (com HTTPS).

ports:
# Porta para HTTP.
  - '80:80'
```

```yml
# docker-compose.yml 
# Em "services.db".
# Comente/Descomente (e/ou altere) as portas/serviços que você deseja oferecer.

# Cuidado, isso pode expor seu banco para outros hosts. Só altere se realmente for desejado.

ports:
# Bind "localhost" com o container.
# Porta padrão Mysql/MariaDB.
  - '127.0.0.1:3306:3306'
```

#### Volumes

```yml
# docker-compose.yml

# Aponte para as pastas criadas anteriormente.

# Em "services.app".
volumes:
  - $(pwd)/etc_glpi:/etc/glpi
  - $(pwd)/lib_glpi:/var/lib/glpi
  - $(pwd)/log_glpi:/var/log/glpi
  - $(pwd)/log_apache2:/var/log/apache2
  - $(pwd)/glpi_marketplace:/var/www/html/marketplace

# Em "services.db".
volumes:
  - '$(pwd)/lib-mysql:/var/lib/mysql
```

#### Variáveis de Ambiente (Environment)

```yml
# docker-compose.yml
# Em "services.db".

environment:
# Senha do usuário root
  - MARIADB_ROOT_PASSWORD=

# Host do root. "localhost" ou ["%"(não recomendado)]
  - MARIADB_ROOT_HOST=

# Nome do usuário criado 
  - MARIADB_USER=

# Senha do usuário
  - MARIADB_PASSWORD=

# Banco de dados criado
  - MARIADB_DATABASE= 
```

#### Rede

```yml
# docker-compose.yml
# Em "networks.glpi-net.ipam", altere os valores caso necessário. 

config:
# Endereço da rede.
  - subnet: 172.18.0.0/28
```

### Executando Docker-Compose

```bash
$ docker-compose -f docker-compose.yml up
```

### Limitação de Acesso

#### Banco de Dados

```sql
/*
 db/grant.sql

 Linhas 15 e 23 (Todos os locais).
*/

... TO 'username'@'%' IDENTIFIED BY 'userpass'; 

```

1. Substitua ***username*** pelo valor inserido em ***MARIADB_USER***.
2. Substitua ***userpass*** pelo valor inserido em ***MARIADB_PASSWORD***.
3. Ao configurar a aplicação o banco de deve ser inserido como ***db_glpi***. Caso opte por utilizar outro nome substitua o termo ***db_glpi*** na linha 23 pelo de sua preferência.

Acesse o banco de dados utilizando uma aplicação gráfica ou via terminal.

```bash
# Via terminal

# Entre no container
$ docker exec -it glpi-db /bin/bash

# Entre no SGBD (com o usuário root e senha root)
$ mariadb -u root -p

# Agora cole - um por vez - os dois comando.

# Certifique-se de ter feitos as alterações.
```


### Configurando Proxy Reverso

> Para adicionar uma camada a mais de segurança recomendamos usar alguma aplicação de proxy reverso, como por exemplo o Nginx. Isso permite esconder o servidor Apache do usuário final além de tornar mais fácil e escalável configurar coisas como HTTPS, redirecionamentos, etc. [Guia para instalação de um Proxy Manager](https://github.com/nutecuneal/proxy-manager-deployer).

### Finalização

1. A partir de seu navegador acesse o domínio/IP e a porta configurada no servidor.
2. Siga o [*Intall-Wizard GLPI*](https://glpi-install.readthedocs.io/en/latest/install/wizard.html) para concluir o processo.

Dica.: você poderá localizar os containers na rede através de seus IPs, para inspecionar isso use o comando "***docker inspect CONTAINER_NAME***". Ou simplesmene use o "***alias***" do container - "**glpi-app**" e/ou "**glpi-db**" - como se fosse um **Hostname/DNS**.

### Segurança

#### Pasta de Instalção

Por motivo de segurança recomenda-se remover a pasta de instalação de dentro do código da aplicação. Por isso, faça:

```
# app/.dockerignore

# Descomente a linha que ignora a pasta de instalação do GLPI.

# Antes
#**/glpi/install

# Depois
**/glpi/install
```

```bash
# Remova os containers
$ docker rm -f glpi-app glpi-db

# Remova a imagem
$ docker rmi -f glpi-deployer-glpi

# Remova os caches de build
$ docker builder prune -a

# Execute o Docker-Compose novamente
$ docker-compose -f docker-compose.yml up
```
## Guia de Usuário

> [Clique aqui para ir ao guia](./README.usersguide.md)

