#!/bin/sh

set -e

[ "$DEBUG" == 'true' ] && set -x

DAEMON=sshd
archive_dir=/srv/git/archives
git_home=/home/git
host_keys_dir=/etc/ssh/host-keys

# Generate Host keys, if required
if [ ! -f ${host_keys_dir}/ssh_host_rsa_key ]; then
    ssh-keygen -f ${host_keys_dir}/ssh_host_rsa_key -N '' -b 4096 -t rsa
else
    echo "Using existing host key"
fi

# Restore archived Git repositories
archives=$(find ${archive_dir} -maxdepth 1 -mindepth 1 -type f -name "*.git.tgz" )
for archive in ${archives}
do
  tar xzf "${archive}" --directory "${git_home}"
  rm -rf "${archive}"
done

mkdir -p ${git_home}/.ssh
chmod 700 ${git_home}/.ssh
touch ${git_home}/.ssh/authorized_keys
chmod 600 ${git_home}/.ssh/authorized_keys

# Make sure everything in ${git_home} is owned by git user, all ssh sessions will
# run as the git user.
chown -R git:git ${git_home}

# Echo content and permissions for debugging purposes:
echo "ls -al ${git_home}"
ls -al ${git_home}
echo "ls -al ${git_home}/.ssh"
ls -al ${git_home}/.ssh

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
if [ "$(basename $@)" == "$DAEMON" ]; then
    trap stop SIGINT SIGTERM
    $@ &
    pid="$!"
    mkdir -p /var/run/$DAEMON && echo "${pid}" > /var/run/$DAEMON/$DAEMON.pid
    wait "${pid}" && exit $?
else
    exec "$@"
fi
