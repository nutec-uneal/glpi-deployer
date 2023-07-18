# GLPI Deployer

O [GLPI](https://glpi-project.org/) é um sistema de código aberto escrito em PHP para Gerenciamento de Ativos de TI, rastreamento de problemas e central de serviços. [GPLI Documentação](https://glpi-project.org/pt-br/documentacao/).

## Sumário

- [GLPI Deployer](#glpi-deployer)
  - [Sumário](#sumário)
    - [Sequência de leitura](#sequência-de-leitura)
  - [1. Requisitos e Dependências](#1-requisitos-e-dependências)
  - [2. Instalação](#2-instalação)
    - [2.1. Criação de Diretórios](#21-criação-de-diretórios)
      - [2.1.1 Banco de Dados](#211-banco-de-dados)
      - [2.1.2 Aplicação](#212-aplicação)
    - [2.2. Config. Docker-Compose (Parte Comum)](#22-config-docker-compose-parte-comum)
      - [2.2.1 Volumes](#221-volumes)
      - [2.2.2 Rede](#222-rede)
    - [2.3. Usando Docker-Compose](#23-usando-docker-compose)
      - [2.3.1 Argumentos (Args)](#231-argumentos-args)
      - [2.3.2 Portas](#232-portas)
      - [2.3.3 Variáveis de Ambiente (Environment)](#233-variáveis-de-ambiente-environment)
    - [2.4. Usando Docker-Compose (Swarm Mode)](#24-usando-docker-compose-swarm-mode)
      - [2.4.1 Construindo a Imagem](#241-construindo-a-imagem)
      - [2.4.2 Variáveis de Ambiente (Environment)](#242-variáveis-de-ambiente-environment)
      - [2.4.3 Docker Secrets](#243-docker-secrets)
    - [2.5. Construindo](#25-construindo)
      - [2.5.1. Docker-Compose](#251-docker-compose)
      - [2.5.2. Swarm Mode](#252-swarm-mode)
    - [2.6. Mais Informações](#26-mais-informações)
      - [2.6.1. Banco de Dados](#261-banco-de-dados)
      - [2.6.2. Pasta de Instalação](#262-pasta-de-instalação)
      - [2.6.3. Proxy Reverso](#263-proxy-reverso)
      - [2.6.4. Finalização](#264-finalização)
  - [3. Guia de Usuário](#3-guia-de-usuário)


### Sequência de leitura

Instalação - Docker-Compose (Convencional): 2, 2.1, 2.2, 2.3, 2.5.1, 2.6

Instalação - Swarm-Mode: 2, 2.1, 2.2, 2.4, 2.5.2, 2.6

<br>


## 1. Requisitos e Dependências

- [Docker e Docker-Compose](https://docs.docker.com/)

- [GLPI Website](http://glpi-project.org/) (para baixar versão atual).

- [Repositório no Github](https://github.com/glpi-project/glpi/releases) (Todas as versões - Recomendado).

- Versões Testadas: 10.0.2 (INSEGURA), 10.0.5, 10.0.9.
  

## 2. Instalação

Obs.: ***$(pwd)*** simboliza um caminho qualquer na máquina do usuário. Ajuste-o de acordo com suas preferências/necessidades.

### 2.1. Criação de Diretórios

#### 2.1.1 Banco de Dados

```bash
# Crie os diretórios.

# Dir. de dados.
$ mkdir $(pwd)/lib-mysql
```

#### 2.1.2 Aplicação

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
# Copie o arquivo "local_define.php" que está em, ".
#   "$(pwd)/glpi-deployer/app/configs/app", para o diretório de configurações.

$ cp $(pwd)/glpi-deployer/app/configs/app/local_define.php $(pwd)/etc-glpi
```

Obs.: configure o proprietário (usuário e grupo) e as permissões das pastas de acordo com o *PUID* e *PGID* utilizado. Tema abordado na seção [Argumentos (Args)](#argumentos-args).


### 2.2. Config. Docker-Compose (Parte Comum)

#### 2.2.1 Volumes

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

#### 2.2.2 Rede

```yml
# (docker-compose|deploy.docker-compose).yml

# Em "networks.glpi-net.ipam", altere os valores caso necessário. 

config:
# Endereço da rede.
  - subnet: 172.18.0.0/28
```


### 2.3. Usando Docker-Compose

#### 2.3.1 Argumentos (Args)

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

#### 2.3.2 Portas

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



#### 2.3.3 Variáveis de Ambiente (Environment)

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


### 2.4. Usando Docker-Compose (Swarm Mode)

#### 2.4.1 Construindo a Imagem

```bash
# Execute

$ docker build -t glpinutec:v2.0 app
```

Obs.: Opcionalmente pode ser adicionado os seguintes parâmetros ao comando ([Saiba Mais](#231-argumentos-args)):
1. --build-arg GLPI_SOURCECODE_URI=${URI_VALUE}
2. --build-arg PUID=${PUID_VALUE}
3. --build-arg PGID=${PGID_VALUE}

#### 2.4.2 Variáveis de Ambiente (Environment)

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

#### 2.4.3 Docker Secrets

> Crie duas **secrets** para armazenar as senhas do banco, com o seguintes nomes: **glpisec-dbroot-passwd** e **glpisec-dbuser-passwd**. Consulte a documentação do Docker caso necessário.


### 2.5. Construindo

#### 2.5.1. Docker-Compose

```bash
# Execute
$ docker-compose up

# Ou
$ docker-compose -f docker-compose.yml up
```

#### 2.5.2. Swarm Mode

```bash
# Execute
$ cat deploy.docker-compose.yml | docker stack deploy --compose-file - ${STACK_NAME}
```


### 2.6. Mais Informações

#### 2.6.1. Banco de Dados

Obs.: altere qualquer conteúdo interno no formato **\`$...\`**, esses valores devem ser definidos pelo usuário.  

> Em **db.app-user.sql** contém as definições para o usuário que será usado pela aplicação.<br>
> Em **user-readonly.sql** contém as definições para a criação de um usuário somente leitura (opcional).

#### 2.6.2. Pasta de Instalação

Por questão de segurança o diretório que permite fazer a instalação do GLPI foi removida do diretório da aplicação, por isso, para efetuar a instalação/atualização é necessário copiar o diretório **/utils/install** para **/var/www/html**. Lembre-se de remover assim que finalizar a instalação.

#### 2.6.3. Proxy Reverso

> Para adicionar uma camada a mais de segurança recomendamos usar alguma aplicação de proxy reverso, como por exemplo o Nginx ou Traefik. Isso permite esconder o servidor Apache do usuário final além de tornar mais fácil e escalável configurar coisas como HTTPS, redirecionamentos, etc. [Guia para instalação de um Proxy Manager](https://github.com/nutecuneal/proxy-manager-deployer).

#### 2.6.4. Finalização

1. A partir de seu navegador acesse o domínio/IP e a porta configurada no servidor.
2. Siga o [*Intall-Wizard GLPI*](https://glpi-install.readthedocs.io/en/latest/install/wizard.html) para concluir o processo.

Dica.: você poderá localizar os containers na rede através de seus IPs, para inspecionar isso use o comando "***docker inspect CONTAINER_NAME***". Ou simplesmene use o "***alias***" do container - "**glpi-app**" e/ou "**glpi-db**" - como se fosse um **Hostname/DNS**.

## 3. Guia de Usuário

> [Clique aqui para ir ao guia](./README.usersguide.md)
