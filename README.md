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
- Extraia o arquivo *glpi-{version}.tgz*. Copie a pasta extraída para dentro de "*path1*/glpi-deploy/main". Onde *path1* é o caminho para pasta *glpi-deploy*.

## Primeira Instalação

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