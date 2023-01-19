FROM jenkins/jenkins:lts-alpine

# Alternar para o usuário 'root'
USER root

# Atualizar e instalar as dependências
RUN apk update && \
    apk add --no-cache alpine-sdk \
                       bash \
                       docker \
                       git \
                       openrc \
    && \
    rm -rf /var/cache/apk/*

# Adicionar o usuário 'jenkins' ao grupo 'docker'
# para que seja possível utilizar os comandos.
RUN addgroup jenkins docker

# Iniciar o docker durante o boot da imagem.
RUN rc-update add docker boot

# Instalando o 'kubectl'
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/kubectl

# Alternar para o usuário 'jenkins'
USER jenkins