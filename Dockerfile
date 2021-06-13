FROM ubuntu:latest

ARG NODE_VERSION=14.17.0
ARG GO_VERSION=1.16.5
ARG HASKELL_LANG_SERVER_VERSION=1.1.0

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y vim curl unzip git screen haskell-platform

# Set up Node.JS
RUN curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" && \
    tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1 --no-same-owner && \
    rm "node-v$NODE_VERSION-linux-x64.tar.xz" && \
    ln -s /usr/local/bin/node /usr/local/bin/nodejs && \
    npm install --global yarn && \
    yarn --version

# Set up Go, must be done before the vim setup
ADD https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz go.tar.gz
RUN rm -rf /usr/local/go && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz
ENV PATH /usr/local/go/bin:$HOME/go/bin:/opt/go/bin:$PATH

# Add the Vim configuration
WORKDIR /root
ADD https://github.com/iselind/dotfiles/archive/refs/heads/master.zip master.zip
RUN unzip master.zip && \
    mv dotfiles-master/vim .vim && \
    mv dotfiles-master/zshrc .zshrc && \
    mv dotfiles-master/screenrc .screenrc && \
    rm -rf master.zip dotfiles-master
RUN GOBIN=/usr/local/bin vim +PlugInstall +qall
RUN npm install coc-json coc-pyright coc-yaml --global-style --ignore-scripts --no-bin-links --no-package-lock --only=prod
RUN rm -rf ${HOME}/.cache ${HOME}/.config ${HOME}/.npm ${HOME}/go

# Setup Haskell stuff
ADD https://github.com/haskell/haskell-language-server/releases/download/${HASKELL_LANG_SERVER_VERSION}/haskell-language-server-Linux-${HASKELL_LANG_SERVER_VERSION}.tar.gz .
RUN tar -xf haskell-language-server-Linux-${HASKELL_LANG_SERVER_VERSION}.tar.gz -C /usr/local/bin && \
    rm -f haskell-language-server-Linux-${HASKELL_LANG_SERVER_VERSION}.tar.gz && \
    chmod +x /usr/local/bin/haskell-language-server-*
RUN curl -sSL https://get.haskellstack.org/ | sh
