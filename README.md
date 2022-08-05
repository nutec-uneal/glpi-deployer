# GLPI Deploy

## Pré-instalação (Requisitos)

### Downloads

#### Projeto GLPI-Deploy
- ```bash
  # Clone o repositório do projeto.
  # 1. Ou clicando na botão download no site do Github.
  # 2. Ou Executando o comando abaixo (Necessário autenticação).

  $ git clone https://github.com/nutecuneal/glpi-deploy.git
  ```

#### Docker:
  - Docker é um plataforma que usa virtualização a nível de aplicação/"Sistema Operacional" para entregar softwares empacotados, chamados de containers.
  - Instale o Docker e o Docker-Compose
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

  # Para fazer o Docker iniciar junto com o Sistema Operacional.
  $ sudo systemctl enable docker.service  
  ```

#### GLPI:
- Extraia o arquivo *glpi-{version}.tgz*. Copie a pasta extraída para dentro de "*$path1*/glpi-deploy/main". Onde *\$path1* é o caminho para pasta *glpi-deploy* clonada na seção [Projeto GLPI-Deploy](#Projeto-GLPI-Deploy).

## Primeira Instalação

```bash
# Entre na pasta glpi-deploy

$ cd $path1/glpi-deploy
```

### Criação de Diretórios

```bash
$ mkdir -p $path2/lib/glpi/{config,data,database}
$ mkdir -p $path2/lib/glpi/data/{_cron,_dumps,_graphs,_lock,_pictures,_plugins,_rss,_sessions,_tmp,_uploads,_cache}
$ mkdir -p $path3/log/glpi

# Copiando arquivo de configuração de diretórios da aplicação
$ cp main/configs/php/local_define.php $path2/lib/glpi/config

# utilize "sudo" no início dos comandos caso o path requeira permissão de admin.
```
- **Um possível valor para *\$path2* e *\$path3* é "/var" ou qualquer outro caminho de sua preferência.**

### Construção dos Containers Docker

#### Banco de Dados

- Altere os seguintes arquivos (pasta "database") inserindo os valores preterido seguindo os modelos.
  
```bash
# Em ".env"

# Senha do usuário root
MARIADB_ROOT_PASSWORD

# Hosts permitidos para acesso ao usuário root. Pode ser ou "%" ou "localhost" (sem aspas). Padrão "localhost".  
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
  - ~/glpi-storage/lib/glpi/config:/etc/glpi
  - ~/glpi-storage/lib/glpi/data:/var/lib/glpi
  - ~/glpi-storage/log/glpi:/var/log/glpi

## Descomente a linha (remova o "#" no início da linha)
## (Antes)
"# - ./main/glpi/install:/var/www/html/install"
## (Depois)
"- ./main/glpi/install:/var/www/html/install"


# Service: glpi_db
## Faça as mesmas alterações.
volumes:
  - ~/glpi-storage/lib/glpi/database:/var/lib/mysql
```

```bash
# No terminal construa a imagem

$ sudo docker-compose -f docker-compose.yml up
```

### Configurando a Aplicação

```bash
# Para verificar se os containers estão executando
$ sudo docker container ls
```

#### GLPI - Banco de Dados

```bash
# Acesse o container através do comando
$ sudo docker exec -it glpi-db /bin/bash

# Entre no SGBD (com o usuário root e sua senha)
$ mariadb -u root -p

# Agora, no terminal cole - um por vez - os dois comando do arquivo "grant.sql". Certifique-se de ter feitos as alterações mencionadas no início do tutorial.
```

#### GLPI - Aplicação
```bash
# Entre no container através do comando
$ sudo docker exec -it glpi /bin/bash

# Execute
$ chown -R www-data:www-data /etc/glpi 
$ chown -R www-data:www-data /var/lib/glpi
$ chown -R www-data:www-data /var/log/glpi
```

Informações para acesso local:
  - GLPI: 172.16.1.3:80 ou "localhost:portaGLPI" ou "ipHost:portaGLPI"
  - GLPI Banco de Dados: 172.16.1.2:3306 ou "localhost:3306"

Agora, em seu navegador acesse a aplicação GLPI. Faça a configuração seguindo o [manual de instalação](https://glpi-install.readthedocs.io/en/latest/install/wizard.html).

<br>

Por motivo de segurança recomenda-se remover a pasta de instalação de dentro do código da aplicação. Por isso, faça:


```dockerfile
#  Em "docker-compose.yml"
# Service: glpi
## Comente a linha (inserindo "#"
## (Antes)
"- ./main/glpi/install:/var/www/html/install"
## (Depois)
"# - ./main/glpi/install:/var/www/html/install"
```
```bash
# Remova os containers
$ sudo docker rm -f glpi glpi-db

# Remova o imagem
$ sudo docker rmi -f glpi-deploy-glpi

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