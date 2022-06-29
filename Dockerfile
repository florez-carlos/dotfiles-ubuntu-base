FROM ubuntu:focal-20220316
LABEL org.opencontainers.image.authors="carlos@florez.co.uk"

ARG LOCALTIME=Eastern

ENV TMP_SCRIPTS=/tmp/scripts
ENV TMP_CONFIG=/tmp/config
ENV TERM=xterm-256color
ENV LOCALTIME=$LOCALTIME
SHELL ["/bin/bash", "-c"]
RUN mkdir -p $TMP_SCRIPTS
RUN mkdir -p $TMP_CONFIG
ADD ./scripts $TMP_SCRIPTS
ADD ./config $TMP_CONFIG
RUN chmod +x -R $TMP_SCRIPTS  
RUN ln -s /usr/share/zoneinfo/US/$LOCALTIME /etc/localtime
RUN $TMP_SCRIPTS/install-dependencies.sh
RUN rm -r $TMP_SCRIPTS
RUN rm -r $TMP_CONFIG
