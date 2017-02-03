FROM buildpack-deps:jessie-scm

#FROM sonnt/eclipse
#MAINTAINER sonnt

RUN echo "deb http://http.debian.net/debian jessie-backports main" >> /etc/apt/sources.list

RUN apt-get -y update && apt-get install -y --no-install-recommends \
        apt-utils \
        lib32z1 lib32ncurses5 \
        bzip2 \
        unzip \
        xz-utils \
        sudo \
        arduino \
        git \
        build-essential \
        libc6-dbg \
        gdb \
        valgrind \
        net-tools \
        nano \
        openssh-server \
        meld \
        curl \
        openjdk-8-jre-headless \
        openjdk-8-jdk \
        usbutils \
        ctags \
        erlang \
        erlang-doc \
        gcc-arm-none-eabi


# Default to UTF-8 file.encoding
ENV LANG C.UTF-8
RUN echo "export NO_AT_BRIDGE=1" >> /etc/profile;\
    echo "JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> /etc/profile;\
    /usr/sbin/update-java-alternatives -s java-1.8.0-openjdk-amd64;

RUN echo  "GatewayPorts yes \n\
X11Forwarding yes\n\
X11DisplayOffset 10\n\
PrintMotd no\n\
PrintLastLog yes\n\
PermitRootLogin yes\n\
TCPKeepAlive yes" >> /etc/ssh/sshd_config;

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

#default DISPLAY
ENV DISPLAY :0

RUN [ -f /opt/eclipse/eclipse ] || \
    { \
      curl -sS -k -o /tmp/eclipsecpp64neon.tar.gz "https://office.ehomevn.com/products/files/httphandlers/filehandler.ashx?action=view&fileid=sbox-10-%7csonnt%7cSoftware%7cDeveloperTools%7ceclipse.tar.gz&version=0&doc=dy9iU1c1OCtPV29ObE9oQmRNcEdiT3pNKys1MVhOZnZONUxuTFhyQkl2ND0_InNib3gtMTAtfHNvbm50fFNvZnR3YXJlfERldmVsb3BlclRvb2xzfGVjbGlwc2UudGFyLmd6Ig2" >/dev/null && echo "export ECLIPSE_ORG=0" >> /etc/profile;\
      tar -xhf /tmp/eclipsecpp64neon.tar.gz -C /opt && rm /tmp/eclipsecpp64neon.tar.gz;\
    }
RUN [ -f /opt/eclipse/eclipse ] || \
    { wget http://ftp.kaist.ac.kr/eclipse/technology/epp/downloads/release/neon/2/eclipse-cpp-neon-2-linux-gtk-x86_64.tar.gz\
      -O /tmp/eclipsecpp64neon.tar.gz &&\
      tar -xf /tmp/eclipsecpp64neon.tar.gz -C /opt && \
      chmod 555 opt/eclipse/eclipse && \
      rm /tmp/eclipsecpp64neon.tar.gz; \
      echo "export ECLIPSE_ORG=1" >> /etc/profile;
    }
RUN sed -ire "9i-vm" /opt/eclipse/eclipse.ini;\
    sed -ire "10i${JAVA_HOME}/jre/bin/java" /opt/eclipse/eclipse.ini;\
    chmod +x /opt/eclipse/eclipse;
ENV GA_VERSION  5_4-2016q3-20160926
#4_9-2015q3-20150921 
RUN wget -q https://launchpadlibrarian.net/287101520/gcc-arm-none-eabi-$GA_VERSION-linux.tar.bz2 -O /tmp/gcc-arm-none-eabi-$GA_VERSION-linux.tar.bz2 \
    && tar xjf /tmp/gcc-arm-none-eabi-$GA_VERSION-linux.tar.bz2 -C /usr/local && \
    rm /tmp/gcc-arm-none-eabi-$GA_VERSION-linux.tar.bz2
#share X11 from host
VOLUME ["/tmp/.X11-unix"]

#create user with sudo perm
#RUN adduser --disabled-password --gecos sonnt sonnt
RUN mkdir -p /home/sonnt/workspace &&  mkdir -p /home/sonnt/.ssh
ADD config/.ssh /home/sonnt/.ssh/
ADD config/.eclipse /home/sonnt/.eclipse/
ADD config/.gitconfig /home/sonnt/.gitconfig
RUN cp /etc/skel/.bashrc /home/sonnt/.bashrc && \
    cp /etc/skel/.profile /home/sonnt/.profile && \
    echo "export NO_AT_BRIDGE=1" >> /home/sonnt/.profile && \
    echo "export NO_AT_BRIDGE=1" >> /home/sonnt/.bashrc && \
    echo "sonnt:x:1000:1000:sonnt,,,:/home/sonnt:/bin/bash" >> /etc/passwd && \
    echo "sonnt:x:1000:" >> /etc/group && \
    echo "sonnt ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/sonnt && \
    chmod 0440 /etc/sudoers.d/sonnt && \
    chown sonnt:sonnt -R /home/sonnt
#    sudo -usonnt ssh-keygen -f /home/sonnt/.ssh/id_rsa -t rsa -N ''
#for arduino use serial
RUN usermod  -aG dialout sonnt
RUN rm -rf /var/lib/apt/lists/*

USER sonnt
ENV HOME /home/sonnt
WORKDIR /home/sonnt/workspace
CMD sleep 10; nohup /opt/eclipse/eclipse &>/dev/null &
