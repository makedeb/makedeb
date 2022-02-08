FROM ubuntu:20.04
ARG DEBIAN_FRONTEND=noninteractive

# Install needed deps.
RUN apt-get update
RUN apt-get install bats sed grep tar git jq devscripts sudo -y

# Set up the build user.
RUN useradd -m makedeb
RUN echo 'makedeb ALL=(ALL:ALL) NOPASSWD:ALL' >> /etc/sudoers

COPY ./entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
