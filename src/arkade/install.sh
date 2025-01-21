#!/usr/bin/env bash

USERNAME="${USERNAME:-"${_REMOTE_USER:-"automatic"}"}"
UPDATE_RC="${UPDATE_RC:-"true"}"
KUBECTL_VERSION="${KUBECTL:-"none"}"
HELM_VERSION="${HELM:-"none"}"
K9S_VERSION="${HELM:-"none"}"
CUSTOM_TOOLS="${CUSTOM_TOOLS:-""}"

set -e

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
    VERSION=$2
        echo "Installing ${TOOL} with ${VERSION}"
    if [ "${VERSION}" != "none" ] && [ "${VERSION}" != "false" ]; then
        if [ "${VERSION}" = "latest" ] || [ "${VERSION}" = "true" ]; then
            echo "Installing ${TOOL} version: ${VERSION}"
            arkade get $TOOL
        else
            echo "Installing ${TOOL} version: ${VERSION}"
            arkade get $TOOL --version "${VERSION}"
        fi
        return 0
    fi
    return 1
}

# Install Arkade if it's missing
# if ! arkade version &> /dev/null ; then
if true ; then

    curl -sLS https://get.arkade.dev | sh

    export PATH=$PATH:/root/.arkade/bin

    updaterc "export PATH=$PATH:/root/.arkade/bin"

    if [ -f "/etc/bash.bashrc" ]; then
        echo 'source /etc/bash_completion' >> /etc/bash.bashrc
    fi

    echo "arkade version: $(arkade version | grep "Version:" | cut -d ' ' -f 2)" >> /usr/local/etc/dev-containers/apps.txt

    if install_arkade_tool kubectl "${KUBECTL_VERSION}"; then
        if [ -f "/etc/zsh/zshrc" ]; then
            echo '[[ $commands[kubectl] ]] && source <(kubectl completion zsh)' >> /etc/zsh/zshrc
        fi
        if [ -f "/etc/bash.bashrc" ]; then
            echo 'source <(kubectl completion bash)' >> /etc/bash.bashrc
            updaterc "alias k=kubectl\ncomplete -F __start_kubectl k"
        fi
        echo "kubectl version: $(kubectl version --client=true --output=json | jq '.clientVersion.gitVersion')" >> /usr/local/etc/dev-containers/apps.txt
    fi

    if install_arkade_tool helm "${HELM_VERSION}"; then
        if [ -f "/etc/zsh/zshrc" ]; then
            echo '[[ $commands[helm] ]] && source <(helm completion zsh)' >> /etc/zsh/zshrc
        fi
        if [ -f "/etc/bash.bashrc" ]; then
            echo 'source <(helm completion bash)' >> /etc/bash.bashrc
        fi
    fi

    install_arkade_tool k9s "${K9S_VERSION}"

    if [ "${CUSTOM_TOOLS}" != "" ]; then
        echo "Installing custom tools: ${CUSTOM_TOOLS}"
        arkade get ${CUSTOM_TOOLS}
    fi

fi

echo "Done!"
