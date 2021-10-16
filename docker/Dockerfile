FROM ubuntu

SHELL ["/bin/bash", "-c"]
ARG DEBIAN_FRONTEND=noninteractive
ARG package="makedeb"

RUN apt-get update
RUN apt-get dist-upgrade -y

RUN apt-get install wget curl jq gpg git ssh sudo -y

RUN wget -qO - 'https://proget.hunterwittenborn.com/debian-feeds/makedeb.pub' | gpg --dearmor | tee /usr/share/keyrings/makedeb-archive-keyring.gpg &> /dev/null
RUN echo 'deb [signed-by=/usr/share/keyrings/makedeb-archive-keyring.gpg arch=all] https://proget.hunterwittenborn.com/ makedeb main' | tee /etc/apt/sources.list.d/makedeb.list

RUN apt-get update
RUN apt-get install "${package}" -y

RUN adduser --disabled-password --gecos '' makedeb
RUN adduser makedeb sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER makedeb
WORKDIR /home/makedeb

ENTRYPOINT ["/bin/bash"]
