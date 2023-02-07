# User's Guide

# GLPI-Agent

Glpi-agent:

  - É um serviço que permite gerar o inventário da máquina e enviar seus resultados para um servidor de confiança.
  - Ele também permite indentificar máquinas na rede e gerar seus inventários, utilizando o protocolo SNMP.
  - Funciona tanto no Windows como no Linux.

Caso tenha algum problema ou dúvida durante a instalação e uso do agente, acesse a documentação:   (https://glpi-agent.readthedocs.io/en/latest/)

## Instalação Windows
<br>

Para realizar a instalação no windows, você deve baixar o instalador do agente no site ou GitHub do glpi.

- Download agent: (https://github.com/glpi-project/glpi-agent/releases)

Ao terminar, execute o .exe:

  - Aceite o contrato e avance.
  - Pode deixar o caminho de instalação no *"Program Files/"* mesmo.
  - No tipo de instalação temos 3 opções:
    - Typical: Instala somente as ferramentas necessárias para a obtenção do inventário. **(Recomendado para as máquinas dos usuários).**
     - Complete: Instala todas as ferramentas para inventário, descobrimento de máquinas na rede via SNMP e inventário remoto. **(Recomendado para a máquina que vai utilizar os recursos de SNMP, pois assim ela consegue enviar essas informações ao servidor do GLPI).**   
     - Custom: Permite selecionar quais ferramentas serão instaladas nessa máquina.
- Após selecinado, devemos inserir a url do nosso servidor em Remote target: https://example.com.br/front/inventory.php  
- Agora é  avançar e aguardar a instalação.

### Enviar inventário
<br>

Ao terminar a instalação, o agente já vai ser iniciado e enviará o inventário automáticamente para o servidor configurado de tempos em tempos, mas podemos adiantar o primeiro envio e ver se tudo esta funcionando. Para isso:

- Acesse o caminho: "*C:Program Files/GLPI Agent/*"
- Ao entrar na pasta procure pelo bat glpi-agent e o execute.
- Depois procure o bat glpi-inventory e o execute. Ele pode demorar um pouco para ser executado pois vai colher as informações da sua máquina.
- Quando ele encerrar, abra um navegador e digite: [localhost:62354](localhost:62354)
- Vai abrir uma página simples, onde mostra o que o agente está fazendo, qual a próxima hora de envio do inventário ao servidor e uma opção para forçar o envio imediato.
- Clique em Force Inventory e pronto, o inventário foi enviado para o servidor do GLPI.
- Abra o servidor e verifique se as informações da máquina chegaram. 

**Obs: O caminho *"C:Program Files/GLPI Agent/"* só exite se você deixou ele como padrão na hora da instalação, caso tenha alterado, procure a pasta do Glpi Agent no caminho informado por você.**



## Inventário da rede via SNMP
<br>

Para realizar o inventário da rede, a máquina que realizará isso deve ter o agente instalado com a opção complete.

Diferente do inventário da máquina que é realizado de forma automática e sempre atualiza as informações, o inventário de rede é feito de forma manual e não atualiza as informações no servidor automáticamente. Assim, caso algum dispositivo mude de ip ou seja adicionados mais dispositivos na rede, o processo manual deve ser realizado novamente.

**Obs: Antes de enviar um inventário manual para o Glpi, verifique se a regra de import denied está inativa:**

1. Acesse o sistema do Glpi
2. Na aba Administração clique em inventário
3. Procure: Regras para importação e vínculo de equipamentos e clique
4. Selecione Dispositivo de rede 
5. Clique em NetworkEquipment import denied
6. Caso esteja ativa, desative e clique em salvar


### Procurar dispositivos na rede
<br>

Os comandos que podem ser utilizados são:

- glpi-netdiscovery -> Faz a identificação dos dispositivos na rede.
- glpi-netinventory -> Gera o inventário dos dispositivos.
- glpi-injector -> Faz o envio do inventário de rede para o servidor.
  

**Obs: Antes de procurar um dispositivo, verifique se ele possui o protocolo SNMP ativo, alguns por padrão vem desativado.**
  
Para todos os procedimentos  devemos utilizar o cmd do Windows.


- ```cmd
  REM/ -> Local de comentário

   REM/ Acesse a pasta do Glpi-agent

  cd C:Program Files/Glpi Agent/

  REM/ utilize o comando glpi-netdiscovery e seus parâmetros para procurar os dispositivos

  glpi-netdiscovery --first 192.168.1.1 --last 192.168.1.254 --port 161 --community public -i -s  dispostivos\

  REM/ -i -> Já gera o inventário da máquina também, sem precisar usar o comando glpi-netinventory depois.

  REM/ -s -> Informe em que pasta você quer salvar os arquivos de inventário, se a pasta estiver fora da Glpi Agent, informe o caminho completo, ex.: C:Users\Documentos\inventario
  ```

Execute o comando ajustando os parâmetros a sua necessidade. Algumas explicações sobre os parâmetros usados:

- port -> É a porta que o dispositivo usa para o SNMP, por padrão é a 161.
- community -> É o nome da comunidade no dispositivo, por padão é public.
- --v1, --v2c -> Pode ser necessário especificar caso o dispositivo não utilize a v1 que é a padrão.
- --host -> Caso queira somente identificar 1 dispositivo na rede utilize ao invés de --first e --last.

Ex.:

```cmd 
glpi-netdiscovery --host 192.168.1.20 --port 161 --v2c --community public -i -s dispositivos\
```

Após o comando executar e caso não informe erros, serão criadas sub-pastas dentro de dispositivos:

- netdiscovery
- netinventory

A pasta que interessa para adicionar os dispositivos no servidor é a *netinvetory*. Agora devemos fazer o envio dos arquivos gerados para o servidor.

```cmd
Rem/ Dentro da pasta do Glpi Agent execute

glpi-injector -v -f dispositivos\netinventory\192.168.1.20.xml --url https://login@example.com.br/front/inventory.php ou https://login@ip-servidor
```

Nesse caso o envio será de um arquivo apenas, caso seja uma pasta inteira utilize:

```cmd
glpi-injector -v -R -d dispositivos\netinventory --url https://login@example.com.br/front/
```

Explicação dos parâmetros:

- -v -> Vai dando um feedback para o usuário sobre o que o comando esta fazendo.
- -f -> Lê um arquivo.
- -R -> Recursivo, ou seja, tudo que estiver na pasta.
- -d -> Lê o diretório.
- --url -> É o caminho do servidor, nele é preciso informar o nome do usuário de login e o endereço do servidor.
  

Acesse o sistema do Glpi e verifique se os dispositivos foram adicionados corretamente.

Também é possivel fazer o envio do inventário de rede pelo sistema do Glpi, porém a desvantagem é que ele só aceita 1 arquivo por vez. Para isso:

1. Acesse o sistema do Glpi
2. Na aba Administração clique em inventário
3. Selecione Importar do arquivo
4. Clique em Escolher arquivo
5. Escolha o arquivo
6. Clique em Upload
7. Volte e verifique se foi adicionado corretamente

## Instalação Linux

Para fazer a instalação no linux, você deve baixar o AppImage do glpi-agent.

- Download agent: (https://github.com/glpi-project/glpi-agent/releases)

Após o download ter sido realizado, entre no terminal:

```bash 
# Acesse o caminho onde você fez o download. Ex.: Downloads

cd Downloads/

# Permita que o AppImage seja executado:

chmod +x glpi-agent-1.4-x86_64.AppImage

# Instale o glpi-agent

sudo ./glpi-agent-1.4-x86_64.AppImage --install --server https://example.com.br/front/inventory.php  --delaytime=10

```

O parâmetro *delaytime* é usado para fazer o envio das informações ao servidor alvo pela primeira vez, nesse exemplo o tempo é 10 segundos.

Abra o sistema do glpi e verifique se as informações da máquina chegaram corretamente.

