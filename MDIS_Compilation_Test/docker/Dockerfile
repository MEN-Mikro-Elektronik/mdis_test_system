FROM ubuntu:22.04

RUN apt-get update -y
RUN apt-get install build-essential -y
RUN apt-get install flex -y
RUN apt-get install bison -y
RUN apt-get install libelf-dev -y
RUN apt-get install vim -y
RUN apt-get install git -y
RUN apt-get install ack -y
RUN apt-get install tree -y
RUN apt-get install rsync -y
RUN apt-get install bc -y
RUN apt-get install kmod -y
RUN apt-get install libssl-dev -y
RUN apt-get install curl -y
RUN apt-get install icu-devtools -y
RUN apt-get install sshpass -y

RUN apt-get install python3 pip -y
RUN pip install junit-xml

ARG USER=docker
ARG UID=1000
ARG GID=1000
RUN useradd -m ${USER} --uid=${UID}

RUN apt-get install sudo -y
RUN adduser ${USER} sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Setup default user, when enter docker container
USER ${UID}:${GID}
WORKDIR /home/${USER}

ENTRYPOINT /bin/bash -li
