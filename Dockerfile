# DOCKER-VERSION 0.3.4
FROM    centos:6.4
MAINTAINER Taylor Buley (buley@outlook.com)

# Pre-Install
# N.B. A barebones CentOS box may require you to enable networking.
# sed -i -e 's/^ONBOOT="no/ONBOOT="yes/' /etc/sysconfig/network-scripts/ifcfg-eth0
# service network restart
RUN cd /usr/local/src && wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm && rpm -Uvh epel-*.rpm && rm epel-*.rpm
RUN sed -i 's/enabled=0/enabled=1/' /etc/yum.repos.d/epel*.repo
RUN cd /usr/local/src && wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm && rpm -Uvh remi-*.rpm && rm remi-*.rpm
RUN sed -i 's/enabled=0/enabled=1/' /etc/yum.repos.d/remi*.repo
RUN cd /usr/local/src && wget http://apt.sw.be/redhat/el6/en/x86_64/rpmforge/RPMS/rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm  && rpm -Uvh rpmforge-*.rpm && rm rpmforge-*.rpm
RUN rpm --import http://apt.sw.be/RPM-GPG-KEY.dag.txt
RUN sed -i 's/enabled=0/enabled=1/' /etc/yum.repos.d/rpmforge*.repo
RUN yum -y update
RUN yum -y upgrade

# Core Utilities
RUN yum -y install rsync openssl-dev openssh-clients man curl wget time cronie which telnet kernel-devel libicu-devel libexpat "Development Tools" dkms

# Editors
RUN yum -y install vim
RUN export EDITOR=vi

# Shells
RUN yum -y install zsh
RUN chsh -s /bin/zsh
RUN wget --no-check-certificate http://install.ohmyz.sh -O - | sh

# Revision Control
RUN yum -y install git
RUN git config --global user.name "Taylor Buley"
RUN git config --global user.email buley@outlook.com
RUN git config --global color.ui auto
RUN git config --global advice.pushNonFastForward false
RUN git config --global advice.statusHints false
RUN git config --global core.whitespace trailing-space,space-before-tab
RUN git config --global diff.renames copies
RUN git config --global diff.mnemonicprefix true
RUN git config --global rerere.enabled true
RUN git config --global merge.stat true

# node
RUN cd /usr/local/src && wget http://nodejs.org/dist/v0.10.29/node-v0.10.29-linux-x64.tar.gz \
	&& tar -xvvf node-* && rm node-v0.10.29-linux-x64.tar.gz
RUN cd /usr/local/src && curl -L http://npmjs.org/install.sh | sh
RUN npm install -g grunt-cli jshint jslint less coffee-script

# System clocks
RUN yum -y install ntp
RUN chkconfig ntpd on
RUN ntpdate pool.ntp.org
RUN /etc/init.d/ntpd start


# Application
RUN /usr/sbin/useradd --create-home --home-dir /usr/local/application --shell /bin/bash -U application
RUN chown -R application /usr/local/
RUN chown -R application /usr/src/
RUN chown -R application /usr/lib/
RUN chown -R application /usr/bin/
RUN chown -R application /src

# Puppet

RUN /usr/sbin/useradd --create-home --home-dir /usr/local/application --shell /bin/bash -g application -p $(echo "technology" | openssl passwd -1 -stdin) -U puppet
RUN yum -y install puppet
RUN echo "%puppet ALL=NOPASSWD: ALL" >> /etc/sudoers

# Monit
RUN /usr/sbin/useradd --create-home --home-dir /usr/local/application --shell /bin/bash -g application -p $(echo "technology" | openssl passwd -1 -stdin) -U puppet
RUN yum -y install monit
RUN echo "%monit ALL=NOPASSWD: ALL" >> /etc/sudoers

# Cleanup
RUN yum -y clean all
EXPOSE  80, 443, 5222
RUN ["coffee", "index.coffee"]
