FROM ubuntu:resolute-20261006
LABEL org.opencontainers.image.authors="mail@florezcarlos.com"
LABEL org.opencontainers.image.version="3.0.0"

ARG LOCALTIME=UTC
ARG DEBIAN_FRONTEND=noninteractive

ARG PYTHON_VERSIONS="v3.12.15 v3.13.17"
ARG PYTHON_DEFAULT=3.13

ENV TMP_SCRIPTS=/tmp/scripts
ENV TMP_CONFIG=/tmp/config
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US
ENV LC_ALL=en_US.UTF-8
ENV TERM=xterm-256color
ENV LOCALTIME=$LOCALTIME
ENV PYTHON_VERSIONS=$PYTHON_VERSIONS
ENV PYTHON_DEFAULT=$PYTHON_DEFAULT
ENV DOT_HOME=/usr/local/src/dotfiles
ENV DOT_HOME_SCRIPTS=$DOT_HOME/scripts
ENV DOT_HOME_LIB=$DOT_HOME/lib
ENV DOT_HOME_VIM=$DOT_HOME/vim

SHELL ["/bin/bash", "-c"]
RUN mkdir {$DOT_HOME,$DOT_HOME_SCRIPTS,$DOT_HOME_LIB,$DOT_HOME_VIM}

ADD ./lib $DOT_HOME_LIB

RUN mkdir -p $TMP_SCRIPTS $TMP_CONFIG
ADD ./scripts $TMP_SCRIPTS
ADD ./config $TMP_CONFIG
RUN chmod +x -R $TMP_SCRIPTS  
RUN ln -s /usr/share/zoneinfo/$LOCALTIME /etc/localtime
# 24.04 introduced a new ubuntu (1000) user
RUN groupmod -g 1099 ubuntu
RUN usermod -u 1099 ubuntu

# Installation/config script
RUN $TMP_SCRIPTS/install-dependencies.sh

RUN rm -r $TMP_SCRIPTS $TMP_CONFIG
