FROM alpine:3.5
MAINTAINER Cucumber Limited <devs@cucumber.io>

# Search Alpine packages: https://pkgs.alpinelinux.org/packages
RUN apk add --upgrade --update --no-cache openssh=7.4_p1-r0 git=2.11.1-r0 curl=7.52.1-r1 ruby=2.3.3-r0 ruby-json=2.3.3-r0 && \
    adduser -h /home/git -s /bin/sh -D -H -u 2000 git && passwd -u git

COPY files/sshd_config /etc/ssh/sshd_config
COPY files/start.sh /start.sh
COPY files/git_acl_shell-1.0.0.gem /tmp
RUN gem install --no-rdoc --no-ri /tmp/git_acl_shell-1.0.0.gem

VOLUME /etc/ssh/host-keys
VOLUME /home/git

EXPOSE 22
ENTRYPOINT ["/start.sh"]
CMD ["/usr/sbin/sshd", "-De"]
