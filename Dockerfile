FROM ubuntu:focal-20230412
LABEL org.opencontainers.image.authors="carlos@florez.co.uk"

ARG LOCALTIME=Pacific
ARG DEBIAN_FRONTEND=noninteractive
ARG MAVEN_CURRENT_VERSION=3.9.6

ENV TMP_SCRIPTS=/tmp/scripts
ENV TMP_CONFIG=/tmp/config
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US
ENV LC_ALL=en_US.UTF-8
ENV TERM=xterm-256color
ENV LOCALTIME=$LOCALTIME
ENV MAVEN_CURRENT_VERSION=$MAVEN_CURRENT_VERSION
ENV DOT_HOME=/usr/local/src/dotfiles
ENV DOT_HOME_SCRIPTS=$DOT_HOME/scripts
ENV DOT_HOME_LIB=$DOT_HOME/lib
ENV DOT_HOME_VIM=$DOT_HOME/vim
ENV MAVEN_HOME=$DOT_HOME_LIB/maven/apache-maven-$MAVEN_CURRENT_VERSION

SHELL ["/bin/bash", "-c"]
RUN mkdir {$DOT_HOME,$DOT_HOME_SCRIPTS,$DOT_HOME_LIB,$DOT_HOME_VIM,$DOT_HOME_LIB/jdtls,$DOT_HOME_LIB/maven}

ADD ./lib $DOT_HOME_LIB

RUN mkdir -p $TMP_SCRIPTS $TMP_CONFIG
ADD ./scripts $TMP_SCRIPTS
ADD ./config $TMP_CONFIG
RUN chmod +x -R $TMP_SCRIPTS  
RUN ln -s /usr/share/zoneinfo/US/$LOCALTIME /etc/localtime

# Installation/config script
RUN $TMP_SCRIPTS/install-dependencies.sh

RUN rm -r $TMP_SCRIPTS $TMP_CONFIG
