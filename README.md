# GLPI Deploy

## Pré-instalação (Requisitos)

### Downloads

#### GLPI-Deploy
- ```bash
  # Clone o repositório do projeto.
  # 1. Clicando na botão download no site.
  # 2. Executando o comando abaixo (Necessário autenticação).

  $ git clone https://github.com/nutecuneal/glpi-deploy.git
  ```

#### Docker:
  - Docker é um plataforma que usa virtualização a nível de aplicação/"Sistema Operacinal" para entregar softwares empacotados, chamados de containers.
  - [Docker: Guia de Uso e instalação](https://docs.docker.com/desktop/).
#### GLPI:
  - Software de gerenciamento de serviços.
  - [GLPI Website](http://glpi-project.org/) (para baixar versão atual).
  - [Repositório do Github](https://github.com/glpi-project/glpi/releases ) (Todas as versões - Recomendado).
  - Versões Testadas: 10.0.2.

### Preparação

#### Docker:
- Certifique-se que a aplicação está executando.
- ```bash
  # Em algumas distribuições Linux.

  # Para verificar se o Docker está executando.
  $ sudo systemctl status docker.service
  
  # Para iniciar o Docker (caso necessário).
  $ sudo systemctl start docker.service

  # Para fazer o Docker iniciar junto com o Sistema Operacinal.
  $ sudo systemctl enable docker.service  
  ```

#### GLPI:
- Extraia o arquivo *glpi-{version}.tgz*. Copie a pasta extraída para dentro de "*$path1*/glpi-deploy/main". Onde *\$path1* é o caminho para pasta *glpi-deploy*.

## Primeira Instalação

```bash
# Entre na pasta glpi-deploy

$ cd $path1/glpi-deploy
```

### Criação de Diretórios

```bash

$ mkdir $path2/$glpistorage
$ mkdir $path2/$glpistorage/{config,data,log,database}
$ mkdir $path2/$glpistorage/data/{_cron,_dumps,_graphs,_lock,_pictures,_plugins,_rss,_sessions,_tmp,_uploads,_cache}

# Copiando arquivo de configuração de diretórios da aplicação
$ cp main/configs/php/local_define.php $path2/$glpistorage/config
```

### Construção dos Containers Docker

#### Banco de Dados

- Altere os seguintes arquivos (pasta "database") inserindo os valores preterido seguindo os modelos.
  
```bash
# Em ".env"

# Senha do usuário root
MARIADB_ROOT_PASSWORD

# HostS permitidoS para acesso ao usuário root. Pode ser ou "%" ou "localhost" (sem aspas). Padrão "localhost".  
MARIADB_ROOT_HOST

# Nome do usuário que será utilizado na aplicação do "GLPI". 
MARIADB_USER

# Senha do usuário
MARIADB_PASSWORD
```

```bash
# Em ".grant.sql"

#Linhas 15 e 23
... TO 'test'@'%' IDENTIFIED BY 'test'; 

## Substitua 'test' em ...['test'@'%']... pelo valor inserido em MARIADB_USER

## Substitua 'test' em ...[IDENTIFIED BY 'test']... pelo valor inserido em MARIADB_PASSWORD

## Ao configurar a aplicação o banco de deve ser inserido como "db_glpi". Caso queira utilizar outro nome substitua o termo "db_glpi" na linha 23 pelo de sua preferência.
```

#### Docker

```dockerfile
#  Em "docker-compose.yml"

# Service: glpi

## Altere o valor "5000" pela porta escolhida para a aplicação GLPI.
ports:
  - "5000:80" 

## Altere o valor "~/glpi-storage/" pelos caminhos definidos no tópico "Criação de Diretórios"
volumes:
  - ~/glpi-storage/config:/etc/glpi
  - ~/glpi-storage/data:/var/lib/glpi
  - ~/glpi-storage/log:/var/log/glpi

# Service: glpi_db
## Faça a mesma alteração seguindo o passo anterior
volumes:
  - ~/glpi-storage/database:/var/lib/mysql
```

```bash
# No terminal construa a imagem

$ sudo docker-compose -f docker-compose.yml up
```

### Configurando a Aplicação

```bash
# Para verificar se os containers estão executando
$ sudo docker container ls

# Entre no container através do comando
$ sudo docker exec -it glpi-db /bin/bash

# Execute
$ chown -R www-data:www-data /etc/glpi 
$ chown -R www-data:www-data /var/lib/glpi
$ chown -R www-data:www-data /var/log/glpi

$ mv /var/www/html/install/.htaccess /var/www/html/install/.htaccess$
```

Agora, em seu navegador acesse "localhost:portaGLPI" ou "ip:portaGLPI". Faça a configuração seguindo o [manual de instalação](https://glpi-install.readthedocs.io/en/latest/install/wizard.html).


Depois de concluído o processo de instalação, execute:

```bash

$ mv /var/www/html/install/.htaccess$ /var/www/html/install/.htaccess
```

# Intalação com backup (Migração/Restauração)

wget https://github.com/glpi-project/glpi/releases/download/10.0.2/glpi-10.0.2.tgz

mkdir glpi-storage
mkdir glpi-storage/{config,data,log,database}
mkdir glpi-storage/data/{_cron,_dumps,_graphs,_lock,_pictures,_plugins,_rss,_sessions,_tmp,_uploads,_cache}

cp main/php-files/local_define.php glpi-storage/config

Dentro do docker:

chown -R www-data:www-data /etc/glpi
chown -R www-data:www-data /var/lib/glpi
chown -R www-data:www-data /var/log/glpi

mv install/.htaccess install/.htaccess#
mv install/.htaccess# install/.htaccess


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