FROM ubuntu:bionic

ADD provision.sh /provision.sh
RUN chmod +x provision.sh
RUN ./provision.sh

