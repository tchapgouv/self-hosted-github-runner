#!/bin/bash
set -x -e -o pipefail
echo "# RUNNING: $(dirname $0)/$(basename $0)"

script="git.sh"
cat <<'EOF_SCRIPT' > /home/ubuntu/${script}
#!/bin/bash

## https://raw.githubusercontent.com/actions/runner-images/main/images/linux/scripts/installers/git.sh

GIT_REPO="ppa:git-core/ppa"
GIT_LFS_REPO="https://packagecloud.io/install/repositories/github/git-lfs"

## Install git
add-apt-repository $GIT_REPO -y
apt-get update
apt-get install git -y
git --version
# Git version 2.35.2 introduces security fix that breaks action\checkout https://github.com/actions/checkout/issues/760
cat <<EOF >> /etc/gitconfig
[safe]
        directory = *
EOF

# Install git-lfs
curl -s $GIT_LFS_REPO/script.deb.sh | bash
apt-get install -y git-lfs

# Install git-ftp
apt-get install git-ftp -y

# Remove source repo's
add-apt-repository --remove -y $GIT_REPO
rm /etc/apt/sources.list.d/github_git-lfs.list

EOF_SCRIPT

echo "# run /home/ubuntu/${script}"
chmod +x /home/ubuntu/${script}
/bin/bash -c /home/ubuntu/${script}
echo "# end /home/ubuntu/${script}"
