# Docker SSH with Git ACL Shell

A docker container for serving git repositories over SSH using a Git shell that
implements per-repository access control similar to Gitlab Shell but without
dependencies on the Gitlab server.

## Install prerequisites

You need docker. You also need to set the registry and log in:

    export DOCKER_REGISTRY=registry.replicated.com
    docker login --username=devs@cucumber.io --password=........ ${DOCKER_REGISTRY}

## Build the image

    # Make sure everything is committed - we'll use the git sha to tag the image
    ./scripts/docker-build

## Run the container

    ./scripts/docker-run

The first time you run this you should see host keys being generated into the
host file system - take a look in `./data/etc/ssh/host-keys`

When you start the container on a Linux machine you should most likely pass `--user 2000`
to `docker run`. We didn't default to `USER 2000` in the `Dockerfile` because it's a hassle
on OS X.

## Archive repositories

The image has a built-in script that creates a `.git.tgz` archive for every git repo.
This can be run from the host's command line:

    ./scripts/docker-run archive-git-repos

## Restore repositories

Git repository archives stored in the archive volume (`/srv/git/archives`) are
automatically restored when the container starts. Existing repositories are
overwritten. Archives are deleted after a successful restore.

This prevents accidental overwriting of repositories after a second restart.

## Publish the image

    # Make sure everything is committed...
    ./scripts/docker-push

## Remove old authorized keys

    ssh-keygen -R [0.0.0.0]:2222

## Add your public key

We're going to add the key specifying a command to run (`git_acl_shell`) when
an SSH connection is established.

    echo -n 'command="git-acl-shell some-account-uid http://localhost:99999",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ' > data/home/git/.ssh/authorized_keys
    cat ~/.ssh/id_rsa.pub >> data/home/git/.ssh/authorized_keys

Under normal use, this line would be added by an application managing users' keys.

## Create a repo

    git init --bare data/home/git/test-repo.git

## Clone a repo over SSH

    git clone ssh://git@0.0.0.0:2222/home/git/test-repo.git

## Security

Try this:

    ssh -p 2222 git@0.0.0.0

You should be told interactive access is disallowed

## Upgrade the gem

Update `Dockerfile` to reference a new version of `git_acl_shell` (it's open source).
