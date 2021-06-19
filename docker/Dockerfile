FROM ubuntu

ENV DEBIAN_FRONTEND=noninteractive
ENV package="makedeb"

RUN apt-get update
RUN apt-get dist-upgrade -y

RUN apt-get install wget gpg git ssh -y

RUN wget -qO - 'https://proget.hunterwittenborn.com/debian-feeds/makedeb.pub' | gpg --dearmor | tee /usr/share/keyrings/makedeb-archive.keyring.gpg &> /dev/null
RUN echo 'deb [signed-by=/usr/share/keyrings/makedeb-archive-keyring.gpg arch=all] https://proget.hunterwittenborn.com/ makedeb main' | tee /etc/apt/sources.list.d/makedeb.list

RUN apt-get update
RUN apt-get install "${package}"

ENTRYPOINT ["/bin/bash"]
