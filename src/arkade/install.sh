#!/usr/bin/env bash

USERNAME="${USERNAME:-"${_REMOTE_USER:-"automatic"}"}"
UPDATE_RC="${UPDATE_RC:-"true"}"
KUBECTL_VERSION="${KUBECTL_VERSION:-"none"}"

set -eux

export DEBIAN_FRONTEND=noninteractive

# Determine the appropriate non-root user
if [ "${USERNAME}" = "auto" ] || [ "${USERNAME}" = "automatic" ]; then
    USERNAME=""
    POSSIBLE_USERS=("vscode" "node" "codespace" "$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)")
    for CURRENT_USER in "${POSSIBLE_USERS[@]}"; do
        if id -u "${CURRENT_USER}" > /dev/null 2>&1; then
            USERNAME="${CURRENT_USER}"
            break
        fi
    done
    if [ "${USERNAME}" = "" ]; then
        USERNAME=root
    fi
elif [ "${USERNAME}" = "none" ] || ! id -u ${USERNAME} > /dev/null 2>&1; then
    USERNAME=root
fi

updaterc() {
    if [ "${UPDATE_RC}" = "true" ]; then
        echo "Updating /etc/bash.bashrc and /etc/zsh/zshrc..."
        if [[ "$(cat /etc/bash.bashrc)" != *"$1"* ]]; then
            echo -e "$1" >> /etc/bash.bashrc
        fi
        if [ -f "/etc/zsh/zshrc" ] && [[ "$(cat /etc/zsh/zshrc)" != *"$1"* ]]; then
            echo -e "$1" >> /etc/zsh/zshrc
        fi
    fi
}


mkdir -p /usr/local/etc/dev-containers

# function installing kubectl for given version. return true if installed, false instead

install_arkade_tool() {
    TOOL=$1
    VERSION=$1  
    if [ "${VERSION}" != "none" && "${VERSION}" != "false" ]; then
        if [ "${VERSION}" = "latest" || "${VERSION}" = "true" ]; then
            arkade get $TOOL
            VERSION=latest
        else
            arkade get $TOOL --version "${KUBECTL_VERSION}"
        fi
        return 0
    fi
    return 1
}

add_to_rc () {
    if [ -f "/etc/zsh/zshrc" ]; then
        echo "${notice_script}" | tee -a /etc/zsh/zshrc
    fi

    if [ -f "/etc/bash.bashrc" ]; then
        echo "${notice_script}" | tee -a /etc/bash.bashrc
    fi
}

# Install Arkade if it's missing
if ! arkade version &> /dev/null ; then

    curl -sLS https://get.arkade.dev | sh

    export PATH=$PATH:/root/.arkade/bin

    updaterc "export PATH=$PATH:/root/.arkade/bin"

    echo "arkade version: $(arkade version)" >> /usr/local/etc/dev-containers/arkade.txt

    if install_arkade_tool kubectl "${KUBECTL_VERSION}"; then
        if [ -f "/etc/zsh/zshrc" ]; then
            echo '[[ $commands[kubectl] ]] && source <(kubectl completion zsh)' >> /etc/zsh/zshrc
        fi
        if [ -f "/etc/bash.bashrc" ]; then
            echo 'source <(kubectl completion bash)' >> /etc/bash.bashrc
            updaterc "alias k=kubectl\ncomplete -F __start_kubectl k"
        fi
        echo "kubectl version: $(kubectl version --client=true)" >> /usr/local/etc/dev-containers/arkade.txt
    fi
fi

# Display a notice on conda when not running in GitHub Codespaces
notice_script="$(cat << 'EOF'
    cat "/usr/local/etc/dev-containers/arkade.txt"
EOF
)"

updaterc "${notice_script}"


echo "Done!"
