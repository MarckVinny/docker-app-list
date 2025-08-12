# Começando

Este repositório é um aplicativo de amostra para os usuários após o [guia de iniciantes](https://docs.docker.com/get-started/).

O aplicativo é baseado no aplicativo do [tutorial de início](https://github.com/docker/getting-started)

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

    > [!NOTE] Observação:  
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
