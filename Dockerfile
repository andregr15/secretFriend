FROM ruby:2.5.1

# Instalando o curl
RUN apt update && apt install -y curl

# Configurando o sistema para os repositórios atualizados do node e do yarn
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# Atualizando o sistema e instalando o pacotes
RUN apt update && apt install -y --no-install-recommends \
    build-essential nodejs yarn libpq-dev imagemagick

# Setando o caminho de instalação
ENV INSTALL_PATH /app

# Criando o caminho de instalação
RUN mkdir -p $INSTALL_PATH

# Setando o diretório de trabalho
WORKDIR $INSTALL_PATH

# Copiando o Gemfile
COPY Gemfile ./

# Setando o caminho das gems
ENV BUNDLE_PATH /box

# Copiando todos os arquivos
COPY . .