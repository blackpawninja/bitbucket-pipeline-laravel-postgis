FROM ubuntu:xenial

# Let the container know that there is no tty
ENV DEBIAN_FRONTEND noninteractive
ENV COMPOSER_NO_INTERACTION 1

ADD provision.sh /provision.sh
RUN chmod +x provision.sh
RUN ./provision.sh

ADD supervisord.conf /etc/supervisor/supervisord.conf

