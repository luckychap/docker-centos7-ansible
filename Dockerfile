FROM centos:7
LABEL maintainer="LuckyChap"

## Systemd cleanup base image - https://hub.docker.com/_/centos/
RUN (cd /lib/systemd/system/sysinit.target.wants && for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -vf $i; done) && \
  rm -vf /lib/systemd/system/multi-user.target.wants/* && \
  rm -vf /etc/systemd/system/*.wants/* && \
  rm -vf /lib/systemd/system/local-fs.target.wants/* && \
  rm -vf /lib/systemd/system/sockets.target.wants/*udev* && \
  rm -vf /lib/systemd/system/sockets.target.wants/*initctl* && \
  rm -vf /lib/systemd/system/basic.target.wants/* && \
  rm -vf /lib/systemd/system/anaconda.target.wants/*

## Install requirements & perform update
RUN yum makecache fast \
 && yum -y install epel-release \
 && yum -y update \
 && yum -y install \
           sudo \
           python-pip \
           python-devel \
           @development \
 && yum clean all

## Install Ansible & testing tools via pip
RUN pip install ansible yamllint ansible-lint flake8 testinfra molecule

## Disable requiretty.
RUN sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/'  /etc/sudoers

## Ansible DIR & inventory file
RUN mkdir -p /etc/ansible
RUN echo -e '[local]\nlocalhost ansible_connection=local' > /etc/ansible/hosts

VOLUME ["/sys/fs/cgroup"]
CMD ["/usr/lib/systemd/systemd"]
