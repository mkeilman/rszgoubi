#!/bin/bash

set -eu -o pipefail
    
rszgoubi_repo="$HOME/rszgoubi"

do_reboot() {
    sudo shutdown -r +1
}

main() {
    run_as_root
    run_as_user
    do_reboot
}

run_as_root() {
sudo -s -- <<EOF
    dnf upgrade -y
    dnf install -y htop tmux vim-enhanced docker git gettext
    systemctl enable docker.service
    systemctl start docker.service 
    docker pull radiasoft/rszgoubi:latest
    sed -i -e 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
EOF
}

_git() {
    git "--git-dir=$rszgoubi_repo/.git" "$@"
}

run_as_user() {
    test -d "$HOME/tmp" || mkdir "$HOME/tmp"

    if [[ ! -d "$rszgoubi_repo" ]]; then
        git clone https://github.com/radiasoft/rszgoubi.git "$rszgoubi_repo"
    fi

    _git remote | grep -q radiasoft || _git remote add radiasoft git@github.com:radiasoft/rszgoubi.git
}

main "$@"
