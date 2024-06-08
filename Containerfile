FROM docker.io/library/ubuntu:22.04 AS base

# Replace sh with bash
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

ENV DEBIAN_FRONTEND=noninteractive

LABEL com.github.containers.toolbox="true" \
      usage="This image is meant to be used with the toolbox or distrobox command" \
      summary="Ubuntu Dev Environment" \
      maintainer="jim@starryhope.com"

COPY ./extra-packages /extra-packages

RUN apt-get update &&   \ 
    apt-get upgrade -y &&  \
    DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install \
        $(cat extra-packages | xargs) && \
    rm -rd /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y locales && \
      sed -i '/ru_RU.UTF-8/s/^# //g' /etc/locale.gen && \
      locale-gen && \
      update-locale LC_ALL="ru_RU.UTF-8"

RUN apt-get update && apt-get install -y wget gpg && \
      wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg && \
      install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg && \
      echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | tee /etc/apt/sources.list.d/vscode.list > /dev/null && \
      apt install -y apt-transport-https && \
      apt update && \
      apt install -y code

rm -f packages.microsoft.gpg

# Install VHS
# RUN DOWNLOAD_URL=$(curl -s https://api.github.com/repos/charmbracelet/vhs/releases/latest | \
#     jq -r '.assets[] | select(.name| test(".*.amd64.deb$")).browser_download_url') \
#     && wget "${DOWNLOAD_URL}" -O package.deb \
#     && dpkg -i package.deb \
#     && rm package.deb \
#     && wget https://github.com/tsl0922/ttyd/releases/latest/download/ttyd.x86_64 -O /tmp/ttyd && \
#     install -c -m 0755 /tmp/ttyd /usr/bin/ttyd

# Install Github CLI
#RUN DOWNLOAD_URL=$(curl -s https://api.github.com/repos/cli/cli/releases/latest | \
#    jq -r '.assets[] | select(.name| test(".*_amd64.deb$")).browser_download_url') \
#    && wget "${DOWNLOAD_URL}" -O package.deb \
#    && dpkg -i package.deb \
#    && rm package.deb

#### Node ####
# nvm environment variables
RUN mkdir /usr/local/nvm
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 20.9.0

# NVM
#RUN touch ~/.bashrc && chmod +x ~/.bashrc
#RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
#RUN source $NVM_DIR/nvm.sh \
#    && nvm install $NODE_VERSION \
#    && nvm alias default $NODE_VERSION \
#    && nvm use default 

# add node and npm to path so the commands are available
ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# Aliases
# RUN echo "alias ll='ls -alF'" >> /etc/profile
