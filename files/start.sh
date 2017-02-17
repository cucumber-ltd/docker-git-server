#!/bin/sh

set -e

[ "$DEBUG" == 'true' ] && set -x

DAEMON=sshd

# Generate Host keys, if required
if [ ! -f /etc/ssh/host-keys/ssh_host_rsa_key ]; then
    ssh-keygen -f /etc/ssh/host-keys/ssh_host_rsa_key -N '' -b 4096 -t rsa
else
    echo "Using existing host key"
fi

mkdir -p /home/git/.ssh
chmod 700 /home/git/.ssh
touch /home/git/.ssh/authorized_keys
chmod 600 /home/git/.ssh/authorized_keys

# Make sure everything in /home/git is owned by git user, all ssh sessions will
# run as the git user.
chown -R git:git /home/git

# Echo content and permissions for debugging purposes:
echo "ls -al /home/git"
ls -al /home/git
echo "ls -al /home/git/.ssh"
ls -al /home/git/.ssh

stop() {
    echo "Received SIGINT or SIGTERM. Shutting down $DAEMON"
    # Get PID
    pid=$(cat /var/run/$DAEMON/$DAEMON.pid)
    # Set TERM
    kill -SIGTERM "${pid}"
    # Wait for exit
    wait "${pid}"
    # All done.
    echo "Done."
}

echo "Running $@"
if [ "$(basename $DAEMON)" == "$DAEMON" ]; then
    trap stop SIGINT SIGTERM
    $@ &
    pid="$!"
    mkdir -p /var/run/$DAEMON && echo "${pid}" > /var/run/$DAEMON/$DAEMON.pid
    wait "${pid}" && exit $?
else
    exec "$@"
fi
