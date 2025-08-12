# Começando

Este repositório é um aplicativo de amostra para os usuários após o [guia de iniciantes](https://docs.docker.com/get-started/).

O aplicativo é baseado no aplicativo do [tutorial de início](https://github.com/docker/getting-started)

---

# Comandos Utilizados

## Persistir os dados das tarefas

Por padrão, o aplicativo de tarefas armazena seus dados em um banco de dados ***SQLite*** no sistema de arquivos `/etc/todos/todo.db` do contêiner. Se você não conhece o ***SQLite***, não se preocupe! É simplesmente um ***banco de dados relacional*** que armazena todos os dados em um único arquivo. Embora não seja o ideal para aplicativos de grande porte, funciona para demonstrações pequenas. Você aprenderá como migrar para um mecanismo de banco de dados diferente posteriormente.  

Como o banco de dados é um arquivo único, se você puder persistir esse arquivo no host e disponibilizá-lo para o próximo contêiner, ele poderá continuar de onde o último parou. Ao criar um volume e anexá-lo *(geralmente chamado de "montagem")* ao diretório onde você armazenou os dados, você pode persistir os dados. À medida que o contêiner grava no arquivo `todo.db`, ele persistirá os dados no host no volume.  

Como mencionado, você usará uma montagem de volume. Pense em uma montagem de volume como um bucket opaco de dados. O Docker gerencia completamente o volume, incluindo o local de armazenamento em disco. Você só precisa se lembrar do nome do volume.  

## Crie um volume e inicie o contêiner  

Você pode criar o volume e iniciar o contêiner usando a ***CLI*** ou a interface gráfica do Docker Desktop.

1. A seguir, estaremos utilizando a CLI.

    ```bash
    docker volume create todo-db
    ```

2. Pare e remova o contêiner do aplicativo de tarefas mais uma vez com `docker rm -f <id>`, pois ele ainda está em execução sem usar o volume persistente.

3. Inicie o contêiner do aplicativo de tarefas, mas adicione a opção `--mount` para especificar a montagem de um volume. Dê um nome ao volume e monte-o no contêiner, que captura todos os arquivos criados no caminho `/etc/todos`.

    ```bash
    docker run -dp 127.0.0.1:3000:3000 --mount type=volume,src=todo-db,target=/etc/todos getting-started
    ```

    > :warning: ***Observação:***  
    > Se você estiver usando o Git Bash, deverá usar uma sintaxe diferente para este comando.
    >
    >
    > ```bash
    > docker run -dp 127.0.0.1:3000:3000 --mount type=volume,src=todo-db,target=//etc/todos getting-started
    > ```
    > Para mais detalhes sobre as diferenças de sintaxe do Git Bash, consulte [Trabalhando com o Git Bash](https://docs.docker.com/desktop/troubleshoot-and-support/troubleshoot/topics/#docker-commands-failing-in-git-bash).

## Verifique se os dados persistem

1. Assim que o contêiner iniciar, abra o aplicativo e adicione ***alguns itens*** à sua ***lista de tarefas***.

2. Itens adicionados à ***lista de tarefas***  
    Pare e remova o contêiner do aplicativo de tarefas.  
    Use o ***Docker Desktop*** ou o ***Docker CLI*** `docker ps` para obter o `ID` e, em seguida, `docker rm -f <id>` para removê-lo.

    ```bash
    # Obtem o ID do Container
    docker ps

    CONTAINER ID   IMAGE        COMMAND                  CREATED             STATUS             PORTS                      NAMES
    9eee749774dd   app-docker   "docker-entrypoint.s…"   About an hour ago   Up About an hour   127.0.0.1:3000->3000/tcp   sad_bhaskara
    ```
    ```bash
    # Remove o Container forçado
    docker rm -f 9ee
    ```

3. Inicie um novo contêiner usando as etapas anteriores.

4. Abra o aplicativo.  
    Você deverá ver seus itens ainda na lista.

5. Vá em frente e remova o `container` quando terminar de conferir sua lista.

Agora você aprendeu como persistir dados.

## Mergulhe no volume

Muitas pessoas costumam perguntar ***"Onde o Docker armazena meus dados quando uso um volume?"***.  
Se quiser saber, você pode usar o comando `docker volume inspect`.


```bash
docker volume inspect todo-db
```

Você deverá ver uma saída como esta:

```bash
[
    {
        "CreatedAt": "2019-09-26T02:18:36Z",
        "Driver": "local",
        "Labels": {},
        "Mountpoint": "/var/lib/docker/volumes/todo-db/_data",
        "Name": "todo-db",
        "Options": {},
        "Scope": "local"
    }
]
```

Esta `Mountpoint` é a localização real dos dados no disco. Observe que, na maioria das máquinas, você precisará ter acesso `root` para acessar este diretório a partir do host.

## Usar montagens de vinculação

No tópico anterior, você usou uma ***montagem de volume*** para persistir os dados no seu banco de dados. Uma montagem de volume é uma ótima opção quando você precisa de um local persistente para armazenar os dados do seu aplicativo.

Uma montagem de vinculação é outro tipo de montagem que permite compartilhar um diretório do sistema de arquivos do ***host*** com o ***contêiner***. Ao trabalhar em uma aplicação, você pode usar uma ***montagem de vinculação*** para montar o ***código-fonte no contêiner***. O contêiner vê as alterações feitas no código imediatamente, assim que você salva um arquivo. Isso significa que você pode executar processos no contêiner que monitoram as alterações no sistema de arquivos e respondem a elas.

Neste tópico, você verá como usar montagens de vinculação e uma ferramenta chamada `nodemon` para monitorar alterações em arquivos e, em seguida, reiniciar o aplicativo automaticamente. Existem ferramentas equivalentes na maioria das outras linguagens e frameworks.

## Comparações rápidas de tipos de volume

A seguir estão exemplos de um volume nomeado e uma montagem de vinculação usando `--mount`:

- ***Volume Nomeado:***  
`type=volume,src=my-volume,target=/usr/local/data` 

- ***Montagem de Vinculação:***  
`type=bind,src=/path/to/data,target=/usr/local/data`  

A tabela a seguir descreve as principais diferenças entre volume nomeado e montagens de vinculação.

|                       | Volumes nomeados         | Montagens de ligação      |
|-----------------------|-------------------------|---------------------------|
| Localização do host   | O Docker escolhe        | Você decide               |
| Preenche o novo volume com o conteúdo do contêiner | Sim                    | Não                      |
| Suporta drivers de volume | Sim                  | Não                      |

## Testando montagens de vinculação

Antes de ver como você pode usar montagens de vinculação para desenvolver seu aplicativo, você pode executar um experimento rápido para obter uma compreensão prática de como as montagens de vinculação funcionam.

1. Verifique se o seu diretório `getting-started-app` está em um diretório definido na configuração de compartilhamento de arquivos do Docker Desktop. Essa configuração define quais partes do seu sistema de arquivos você pode compartilhar com contêineres. Para obter detalhes sobre como acessar a configuração, consulte [Compartilhamento de arquivos](https://docs.docker.com/desktop/settings-and-maintenance/settings/#file-sharing).

> ℹ ***Observação***  
> A guia Compartilhamento de arquivos só está disponível no modo Hyper-V, porque os arquivos são compartilhados automaticamente no modo WSL 2 e no modo de contêiner do Windows.

2. Abra um terminal e altere o diretório para o diretório `getting-started-app`.

3. Execute o seguinte comando `bash` para iniciar em um contêiner `ubuntu` com uma montagem de vinculação.

    ```bash
    docker run -it --mount type=bind,src="$(pwd)",target=/src ubuntu bash
    ```
    
    A opção `--mount type=bind` informa ao Docker para criar uma montagem de vinculação, onde `src` é o diretório de trabalho atual na sua máquina `host` *(`getting-started-app`)*, e `target` é onde esse diretório deve aparecer dentro do contêiner *(`/src`)*.

4. Depois de executar o comando, o Docker inicia uma sessão `bash` interativa no diretório raiz do sistema de arquivos do contêiner.


```bash 
root@ac1237fad8db:/# pwd
/
root@ac1237fad8db:/# ls
bin   dev  home  media  opt   root  sbin  srv  tmp  var
boot  etc  lib   mnt    proc  run   src   sys  usr
```

5. Alterar diretório para o diretório `src`.

Este é o diretório que você montou ao iniciar o contêiner. Listar o conteúdo deste diretório exibe os mesmos arquivos que estão no diretório `getting-started-app` da sua máquina host.

```bash
root@ac1237fad8db:/# cd src
root@ac1237fad8db:/src# ls
Dockerfile  node_modules  package.json  spec  src  yarn.lock
```

6. Crie um novo arquivo chamado `myfile.txt`.

```bash
root@ac1237fad8db:/src# touch myfile.txt
root@ac1237fad8db:/src# ls
Dockerfile  myfile.txt  node_modules  package.json  spec  src  yarn.lock
```

7. Abra o diretório `getting-started-app` no host e observe que o arquivo `myfile.txt` está no diretório.

```bash
├── getting-started-app/
│ ├── Dockerfile
│ ├── myfile.txt
│ ├── node_modules/
│ ├── package.json
│ ├── spec/
│ ├── src/
│ └── yarn.lock
```

8. No host, exclua o myfile.txtarquivo.

9. No contêiner, liste o conteúdo do appdiretório mais uma vez. Observe que o arquivo desapareceu.

```bash
root@ac1237fad8db:/src# ls
Dockerfile  node_modules  package.json  spec  src  yarn.lock
```

10. Pare a sessão do contêiner interativo com ***Ctrl+ D***.

Isso é tudo para uma breve introdução às montagens de vinculação. Este procedimento demonstrou como os arquivos são compartilhados entre o ***host*** e o ***contêiner*** e como as alterações são imediatamente refletidas em ambos os lados. Agora você pode usar montagens de vinculação para desenvolver software.


