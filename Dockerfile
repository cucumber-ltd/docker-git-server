FROM alpine:3.5
MAINTAINER Cucumber Limited <devs@cucumber.io>

# We're using the v3.5 Alpine registry
# Search Alpine packages: https://pkgs.alpinelinux.org/packages?name=&branch=v3.5&repo=main&arch=x86_64
RUN apk add --upgrade --update --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.5/main \
    openssh=7.4_p1-r0 \
    git=2.11.2-r0 \
    curl=7.52.1-r3 \
    ruby=2.3.3-r0 \
    ruby-json=2.3.3-r0 \
    && \
    adduser -h /home/git -s /bin/sh -D -H -u 2000 git && passwd -u git

COPY files/sshd_config /etc/ssh/sshd_config
COPY files/start.sh /start.sh
COPY files/git_acl_shell-1.0.1.gem /tmp
RUN gem install --no-rdoc --no-ri /tmp/git_acl_shell-1.0.1.gem

VOLUME /srv/git/archives
VOLUME /home/git
VOLUME /etc/ssh/host-keys

EXPOSE 22
ENTRYPOINT ["/start.sh"]
CMD ["/usr/sbin/sshd", "-De"]
