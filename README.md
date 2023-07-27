# GLPI Deployer

O [GLPI](https://glpi-project.org/) é um sistema de código aberto escrito em PHP para Gerenciamento de Ativos de TI, rastreamento de problemas e central de serviços. [GPLI Documentação](https://glpi-project.org/pt-br/documentacao/).

## Sumário

- [GLPI Deployer](#glpi-deployer)
  - [Sumário](#sumário)
    - [Sequência de leitura](#sequência-de-leitura)
  - [1. Requisitos e Dependências](#1-requisitos-e-dependências)
  - [2. Instalação](#2-instalação)
    - [2.1. Configuração de Domínio](#21-configuração-de-domínio)
    - [2.2. Diretórios](#22-diretórios)
    - [2.3. Docker-Compose (Parte Comum)](#23-docker-compose-parte-comum)
      - [2.3.1 Volumes](#231-volumes)
      - [2.3.2 Rede](#232-rede)
    - [2.4. Usando Docker-Compose](#24-usando-docker-compose)
      - [2.4.1 Argumentos (Args)](#241-argumentos-args)
      - [2.4.2 Portas](#242-portas)
      - [2.4.3 Variáveis de Ambiente (Environment)](#243-variáveis-de-ambiente-environment)
      - [2.4.4 Construindo](#244-construindo)
    - [2.5. Usando Docker-Compose (Swarm Mode)](#25-usando-docker-compose-swarm-mode)
      - [2.5.1 Construindo a Imagem](#251-construindo-a-imagem)
      - [2.5.2 Variáveis de Ambiente (Environment)](#252-variáveis-de-ambiente-environment)
      - [2.5.3 Docker Secrets](#253-docker-secrets)
      - [2.5.4 Construindo](#254-construindo)
  - [3 Mais Informações](#3-mais-informações)
    - [3.1. Banco de Dados](#31-banco-de-dados)
    - [3.2. Pasta de Instalação](#32-pasta-de-instalação)
    - [3.3. Proxy Reverso](#33-proxy-reverso)
    - [3.4. GLPI Tarefas](#34-glpi-tarefas)
  - [4. Guia de Usuário](#4-guia-de-usuário)


### Sequência de leitura

Instalação - Docker-Compose (Convencional): 2, 2.1, 2.2, 2.3, 2.5.1, 2.6

Instalação - Swarm-Mode: 2, 2.1, 2.2, 2.4, 2.5.2, 2.6


## 1. Requisitos e Dependências

- [Docker e Docker-Compose](https://docs.docker.com/)

- [GLPI Website](http://glpi-project.org/) (para baixar versão atual).

- [Repositório no Github](https://github.com/glpi-project/glpi/releases) (Todas as versões - Recomendado).

- Versões Testadas: 10.0.2 (INSEGURA), 10.0.5, 10.0.9.
  

## 2. Instalação

Obs.: "***$(pwd)***" simboliza um caminho qualquer na máquina do usuário. Ajuste-o de acordo com suas preferências/necessidades.

### 2.1. Configuração de Domínio

Em "*./app/configs/apache/sites-available/glpi.domain.conf*" preencha os campos: "**ServerName**", nome do domínio utilizado; "**ServerAdmin**", email do dono/organização.

### 2.2. Diretórios

```bash
# Banco de Dados. Crie os diretórios.

# Dir. de dados.
$ mkdir $(pwd)/lib-mysql
```

```bash
# GLPI. Crie os diretórios.

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
# Copie o arquivo "./glpi-deployer/app/configs/app/local_define.php" para o diretório de configurações.

$ cp $(pwd)/glpi-deployer/app/configs/app/local_define.php $(pwd)/etc-glpi
```

Obs.: configure o proprietário (usuário e grupo) e as permissões das pastas de acordo com o *PUID* e *PGID* utilizado. Tema abordado na seção [Argumentos (Args)](#241-argumentos-args).


### 2.3. Docker-Compose (Parte Comum)

#### 2.3.1 Volumes

```yml
# (docker-compose|deploy.docker-compose).yml

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

#### 2.3.2 Rede

```yml
# (docker-compose|deploy.docker-compose).yml

# Em "networks.glpi-net.ipam", altere os valores caso necessário. 

config:
# Endereço da rede.
  - subnet: 172.18.0.0/28
```

### 2.4. Usando Docker-Compose

#### 2.4.1 Argumentos (Args)

Opcionalmente pode ser adicionado algumas diretivas personalizadas, como: 

```yml
# docker-compose.yml
# Adicione em "services.app.build".

args:
# URL do GLPI (link da internet) ou arquivo.tgz na pasta `app`.
# Default: <https://github.com/glpi-project/glpi/releases/download/10.0.9/glpi-10.0.9.tgz>
  - GLPI_SOURCECODE_URI=${URI_VALUE}

# ID do Usuário usado. Default: 1024.
  - PUID=${PUID_VALUE}
  
# ID do Grupo usado. Default: 1024.
  - PGID=${PGID_VALUE}
```

#### 2.4.2 Portas

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

#### 2.4.3 Variáveis de Ambiente (Environment)

```yml
# docker-compose.yml
# Em "services.db".

environment:
# Senha do usuário root.
  - MARIADB_ROOT_PASSWORD=

# Host do root. "localhost" ou "%" (não recomendado).
  - MARIADB_ROOT_HOST=

# Nome do usuário criado.
  - MARIADB_USER=

# Senha do usuário.
  - MARIADB_PASSWORD=

# Nome do banco de dados criado.
  - MARIADB_DATABASE= 
```

#### 2.4.4 Construindo

```bash
# Execute
$ docker-compose up

# Ou
$ docker-compose -f docker-compose.yml up
```

### 2.5. Usando Docker-Compose (Swarm Mode)

#### 2.5.1 Construindo a Imagem

```bash
# Execute

$ docker build -t glpinutec:v2.0 app
```

Obs.: Opcionalmente podem ser adicionadas as seguintes diretivas ao comando ([Saiba Mais](#241-argumentos-args)):
1. --build-arg GLPI_SOURCECODE_URI=${URI_VALUE}
2. --build-arg PUID=${PUID_VALUE}
3. --build-arg PGID=${PGID_VALUE}

#### 2.5.2 Variáveis de Ambiente (Environment)

```yml
# deploy.docker-compose.yml
# Em "services.db".

environment:
# Host do root. "localhost" ou "%" (não recomendado).
  - MARIADB_ROOT_HOST=

# Nome do usuário criado.
  - MARIADB_USER=

# Nome do banco de dados criado.
  - MARIADB_DATABASE= 
```

#### 2.5.3 Docker Secrets

Crie duas "**secrets**" para armazenar as senhas do banco, com o seguintes nomes: "**glpisec-dbroot-passwd**" e "**glpisec-dbuser-passwd**". Consulte a documentação do Docker caso necessário.

#### 2.5.4 Construindo

```bash
# Execute
$ cat  | docker stack deploy --compose-file stack.docker-compose.yml ${STACK_NAME}
```

## 3 Mais Informações

### 3.1. Banco de Dados

Obs.: altere qualquer conteúdo interno no formato **\`$...\`**, esses valores devem ser definidos pelo usuário.  

1. Em "**db.app-user.sql**" contém as definições para o usuário que será usado pela aplicação.<br>
2. Em "**user-readonly.sql**" contém as definições para a criação de um usuário somente leitura (opcional).

### 3.2. Pasta de Instalação

Por questão de segurança o diretório que permite fazer a instalação do GLPI foi removida do diretório da aplicação, por isso, para efetuar a instalação/atualização é necessário copiar o diretório "**/utils/install**" para "**/var/www/html**". Lembre-se de remover assim que finalizar a instalação. Siga o [*Intall-Wizard GLPI*](https://glpi-install.readthedocs.io/en/latest/install/wizard.html) para concluir o processo.

### 3.3. Proxy Reverso

Para adicionar uma camada a mais de segurança recomendamos usar alguma aplicação de proxy reverso, como por exemplo o Nginx ou Traefik. Isso permite esconder o servidor Apache do usuário final além de tornar mais fácil e escalável configurar coisas como HTTPS, redirecionamentos, etc. 

1. [Guia para instalação - Traefik](https://github.com/nutecuneal/traefik-deployer).
2. [Guia para instalação - Nginx](https://github.com/nutecuneal/proxy-manager-deployer).

### 3.4. GLPI Tarefas

O GLPI executa tarefas paras as mais diversas finalidades, como, por exemplo, enviar/receber chamados. Os scripts do diretório "**scripts/glpi-jobs**" foram criados para facilitar essa atividade, bata seguir as orientações do script "**example-run-glpi-job.sh**", e depois adicionar ao crontab da máquina host. 

Obs.: o script retorna status de execução, com saídas via stdout (sucesso) e stderr (error).

## 4. Guia de Usuário

> [Clique aqui para ir ao guia](./README.usersguide.md)
