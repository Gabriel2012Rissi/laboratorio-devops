# Meu Laboratório DevOps

Seguem algumas anotações úteis visando utilizar a pipeline **Git (GitLab ou Gitea)** + **SonarQube** + **Docker(DinD)** + **Jenkins** + **Docker Hub**. Lembre-se de que esse passo-a-passo é uma aproximação, então, podem haver alguns passos que serão levemente diferentes à depender das versões que serão utilizadas.

### Gitea

1. Acesso o [Gitea](http://localhost:8180);
2. Criar um usuário;
3. Configurações -> Aplicações;
   - Gerar novo token
     - Nome do token: **Jenkins**
     - Gerar token
4. Configurações -> Chaves SSH/GPG
   - Adicionar chave
     - Nome da Chave: **jenkins-key**
     - Conteúdo
     - Adicionar chave

Para criar uma chave SSH para usar no Gitea e no Jenkins, execute:

```
ssh-keygen -t ed25519 -C "seu-endereço-de-email"
```

- Enter file in which to save the key /home/user/.ssh/jenkins_key
  - Enter passphrase (empty for no passphrase): **sua-senha-aqui**
  - Enter same passphrase again: **sua-senha-aqui**

### Configurando o Jenkins

Passo-a-passo para a configuração inicial do Jenkins.

1. Para obter a senha inicial do Jenkins, execute:
   ```
   docker exec -it jenkins cat /var/jenkins_home/secrets/initialAdminPassword
   ```
2. Acesse o [Jenkins](http://localhost:8180);
3. Crie seu usuário e senha;
4. Gerenciar Jenkins -> Gerenciar extensões;
5. Instale os seguintes plugins:
   - Docker;
   - Docker Pipeline;
   - GitLab (ou Gitea).
6. Gerenciar Jenkins -> Manage Credentials -> Jenkins -> Global credentials (unrestricted):
7. Adicione as seguintes credenciais:
   - Certificados do Docker;
   - Token do GitLab (ou Gitea);
   - Token do SonarQube;
   - Chave SSH associada ao GitLab (ou Gitea);
   - Token Docker Hub.

#### Docker

Configurar a conexão remota com o container do Docker(DinD).

- Configurar nuvem Docker(DinD);
- Gerenciar Nós -> Configurar Nuvens;
  - Docker:
    - Docker Cloud details:
      - Name: **docker**
      - Docker Host URI: [tcp://docker:2376]()
    - Server Credential Add:
      - **X.509 Client Certificate**
        - Client Key:
        ```
        docker exec dind cat /certs/client/key.pem
        ```
        - Client Certificate:
        ```
        docker exec dind cat /certs/client/cert.pem
        ```
        - Server CA Certificate:
        ```
        docker exec dind cat /certs/server/ca.pem
        ```
    - Test Connection;
    - Aplicar e Salvar.

#### Plugin do GitLab

Configurar conexão com **GitLab**:

- Configurar o sistema;
  - GitLab:
    - GitLab connections:
      - Connection name: **GitLab Connection**
      - Gitlab host URL: [https://gitlab.com](https://gitlab.com)
      - Credentials:
        - **GitLab API Token**
      - Test Connection.

#### Plugin do Gitea

Configurar conexão com **Gitea**:

- Configurar o sistema;
  - Gitea:
    - GitLab connections:
      - Gitea Server name: **Gitea Connection**
      - Server URL: [http://gitea:3000](http://gitea:3000)
      - Manage hooks;
      - Credentials:
        - **Gitea API Token**

**Observação**

Para clonar um projeto com SSH no Gitea, use:
_ssh://git@gitea:2222/usuario/nome_do_projeto_no_gitea.git_

#### Plugin do SonarQube

1. Configurar conexão com o SonarQube:

   - Configurar o sistema;
   - SonarQube servers -> Add SonarQube;
   - SonarQube installations;
     - Name: **sonarqube**
     - Server URL [http://sonarqube:9000](http://sonarqube:9000)
     - Server authentication token
       - **SonarQube Token**

2. Configurar o Sonar-Scanner:
   - Global Tool Configuration;
   - SonarQube Scanner:
     - Name: **SONAR_SCANNER**
     - Instalar automaticamente;
       - Install from Maven Central;

### Dicas

#### SonarQube Multibranch

Por padrão o SonarQube Community não é capaz de trabalhar com projetos que utilizem múltiplos branch, sendo necessário utilizar a versão [Developer Edition](https://www.sonarqube.org/developer-edition), mas, existe o plugin [Sonarqube Community Branch Plugin](https://github.com/mc1arke/sonarqube-community-branch-plugin) que permite adicionar essa funcionalidade ao nosso SonarQube. Para baixá-lo e instalá-lo, utilize os comandos abaixo:

```
cd sonarqube/plugins
wget wget https://github.com/mc1arke/sonarqube-community-branch-plugin/releases/download/1.8.2/sonarqube-community-branch-plugin-1.8.2.jar
chmod +x sonarqube-community-branch-plugin-1.8.2.jar
```

Adicione ao **docker-compose.yml**, no service 'sonarqube', o seguinte environment:

```
...
environment:
  ...
  SONAR_WEB_JAVAADDITIONALOPTS: "-javaagent:./extensions/plugins/sonarqube-community-branch-plugin-1.8.2.jar=web"
  SONAR_CE_JAVAADDITIONALOPTS: "-javaagent:./extensions/plugins/sonarqube-community-branch-plugin-1.8.2.jar=ce"
```

**Observação:** Atualmente a versão mais recente do plugin [Sonarqube Community Branch Plugin](https://github.com/mc1arke/sonarqube-community-branch-plugin) compatível com o SonarQube LTS é a '1.8.2'; Caso esteja utilizando o SonarQube 'latest' ou alguma versão mais recente, simplesmente substitua a referência da versão pela que for compatível.

#### Criando webhook multibranch no Gitea

1. Instale o plugin [Multibranch Scan Webhook Trigger](https://plugins.jenkins.io/multibranch-scan-webhook-trigger) no Jenkins.
2. Atualize o job multibranch do jenkins, selecione a opção 'Scan by webhook':
   Token Trigguer: **my-token**
3. Logue no Gitea com seu usuário e senha;
4. Selecione o projeto;
5. Configurações -> Webhook -> Adicionar webhook -> Gitea:
   - URL de destino: [http://jenkins:8080/multibranch-webhook-trigger/invoke?token=my-token]()
6. Faça qualquer alteração em um dos branches do projeto, o webhook irá disparar uma trigger de construção no Jenkins.

#### Deploy com Kubernetes

1. Instale o plugin [Kubernetes CLI](https://plugins.jenkins.io/kubernetes-cli);
2. Adicione o arquivo 'kubeconfig.yml' às credenciais;
3. Na pipeline, adicione o stage abaixo:

```
stage('Deploy Kubernetes') {
    steps {
        withKubeConfig([credentialsId: 'kubeconfig']) {
            sh 'kubectl apply -f deployment.yaml'
        }
    }
}
```
