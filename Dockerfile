FROM ubuntu
 
RUN echo 'deb http://archive.ubuntu.com/ubuntu precise main universe' > /etc/apt/sources.list && \
    echo 'deb http://archive.ubuntu.com/ubuntu precise-updates universe' >> /etc/apt/sources.list && \
    apt-get update

#SSHD
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server &&	mkdir /var/run/sshd && \
    echo 'root:root' |chpasswd

#Utilities
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y vim less net-tools inetutils-ping curl git telnet nmap socat dnsutils netcat tree htop unzip sudo

#Chef Server
RUN wget https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/12.04/x86_64/chef-server_11.0.11-1.ubuntu.12.04_amd64.deb&& \
    dpkg -i chef*.deb && \
    rm chef*.deb

#Docker client only
RUN wget -O /usr/local/bin/docker https://get.docker.io/builds/Linux/x86_64/docker-latest && \
    chmod +x /usr/local/bin/docker

#Configuration
#Reconfigure
RUN sysctl -w kernel.shmall=4194304 && \
    sysctl -w kernel.shmmax=17179869184 && \
    /opt/chef-server/embedded/bin/runsvdir-start & \
    chef-server-ctl reconfigure && \
    chef-server-ctl stop
#Fix Nginx redirect problem when behind NAT
RUN sed -i -e 's|proxy_set_header Host .*|proxy_set_header Host $http_host;|' /var/opt/chef-server/nginx/etc/chef_http_lb.conf

ADD . /docker
RUN cp -r /docker/sv/ssh /opt/chef-server/service/

RUN mkdir -p /etc/chef-server && ln -s /docker/chef-server.rb /etc/chef-server/

#Knife
RUN mkdir -p /root/.chef && \
    ln -s /docker/knife.rb /root/.chef/
#RUN ln -s /docker/chef-repo /root/

RUN echo 'export PATH=/opt/chef-server/embedded/bin:$PATH' >> /root/.bashrc
CMD /docker/init
EXPOSE 22


