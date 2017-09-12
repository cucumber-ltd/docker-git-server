FROM alpine:3.6
MAINTAINER Cucumber Limited <devs@cucumber.io>

# We're using the v3.6 Alpine registry
# Search Alpine packages: https://pkgs.alpinelinux.org/packages?name=&branch=v3.6&repo=main&arch=x86_64
RUN apk add --upgrade --update --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.5/main \
    openssh=7.5_p1-r1 \
    git=2.13.5-r0 \
    curl=7.55.0-r0 \
    ruby=2.4.1-r3 \
    ruby-json=2.4.1-r3 \
    && \
    adduser -h /home/git -s /bin/sh -D -H -u 2000 git && passwd -u git

COPY files/sshd_config /etc/ssh/sshd_config
COPY files/start.sh /start.sh
COPY files/archive-git-repos /usr/local/bin/archive-git-repos
COPY files/restore-git-repos /usr/local/bin/restore-git-repos
RUN gem install --no-rdoc --no-ri git_acl_shell --version 1.0.4

VOLUME /srv/git/archives
VOLUME /home/git
VOLUME /etc/ssh/host-keys

EXPOSE 22
ENTRYPOINT ["/start.sh"]
CMD ["/usr/sbin/sshd", "-De"]
