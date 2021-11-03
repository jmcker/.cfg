# this file is processed on each interactive invocation of bash

# avoid problems with scp -- don't process the rest of the file if non-interactive
[[ $- != *i* ]] && return

is-ssh-con() {
    if [ -n "${SSH_CLIENT}" ] || [ -n "${SSH_TTY}" ]; then
        [ -n "${1}" ] && echo '<ssh>' # Be loud
        return 0
    else
        return 1
    fi
}

is-wsl() {
    if uname -r 2>&1 | grep "Microsoft" &> /dev/null; then
        [ -n "${1}" ] && echo " WSL" # Be loud
        return 0
    else
        return 1
    fi
}

update-window-title() {
    local window_host="${DISTRO_NAME}$(is-wsl yes)"
    is-ssh-con && local window_host="${USER}@${HOSTNAME} [${window_host}]"
    echo -ne "\033]0;${window_host}  |  $(dirs +0)\a"
}

# In case install-key script isn't defined
current-ssh-ring() {
    echo ""
}

export PS1='\[\e[01;32m\]\u@\h\[\e[01;30m\]$(is-ssh-con loud)\[\e[01;32m\]:\[\e[01;34m\]\w ($(current-ssh-ring)) $ \[\e[0m\]'
export PROMPT_COMMAND="update-window-title;"
export LS_COLORS='di=1;34:ow=1;34:'
export VISUAL=vim
export EDITOR="${VISUAL}"
export HISTSIZE=1000
export HISTCONTROL=ignorespace

export PATH="${HOME}/bin/:${PATH}"
export PATH="${HOME}/.local/bin:${PATH}"

export DISTRO_NAME=$(source /etc/os-release; echo -n "${PRETTY_NAME:-${NAME} ${VERSION_ID}}")

# Cycle through completion options
bind "TAB:menu-complete"
bind '"\e[Z":menu-complete-backward'
#bind "set show-all-if-ambiguous on"
#bind "set menu-complete-display-prefix on"

alias mail=mailx

alias .bashrc="vim ~/.bashrc"
alias .vimrc="vim ~/.vim/vimrc"
alias bc="bc -l"

# Git controls for dotfile repo
alias cfg='git --git-dir=${HOME}/.cfg --work-tree=${HOME}'
cfg config --local status.showUntrackedFiles no

alias ls="ls --group-directories-first --color=auto"
alias lsa="ls -A"
alias dir="dir --color=auto"
alias grep="grep --color=auto"
alias fold="fold -s"
alias cat="cat -v"
alias sudo="sudo --preserve-env=HTTP_PROXY,HTTPS_PROXY,NO_PROXY,http_proxy,https_proxy,no_proxy"
alias version="uname -a && lsb_release -a"
alias extip="dig -4 +short myip.opendns.com A @resolver1.opendns.com && dig -6 +short myip.opendns.com AAAA @resolver1.opendns.com"
alias json="python3 -m json.tool"
alias sqlite="sqlite3"
alias python="python3"
alias pip="pip3"
alias cloc='cloc --fullpath --not-match-d="$(tr "\n" "|" < ${HOME}/.clocignore)"'
alias gitaddx="git update-index --chmod +x"
alias cdg='cd "`git rev-parse --show-toplevel`"' # single quotes to prevent expansion
alias newb='/mnt/c/Windows/System32/cmd.exe /c start ubuntu.exe -c "cd $(printf %q "${PWD}"); /bin/bash"'
alias ssh-nk="ssh -o PreferredAuthentications=keyboard-interactive,password -o PubkeyAuthentication=no"
alias sftp-nk="sftp -o PreferredAuthentications=keyboard-interactive,password -o PubkeyAuthentication=no"
alias rdp="xfreerdp /v:localhost /w:1920 /h:1000"
alias bigbois="echo Loading... && du -sh --exclude . --exclude .. * .* 2>/dev/null | sort -rh | more -15"
alias mac-clean-zip="find . -name '.DS_Store' -exec rm -v {} \; && find . -name '__MACOSX' -prune -exec rm -rv {} \;"

bashrc() {
    vim ~/.bashrc
    source ~/.bashrc
    echo Sourced ~/.bashrc.
}

# Start a Windows program
win() {
    /mnt/c/Windows/System32/cmd.exe /c "${@}"
}

# Mount Windows flashdrive or disk
# Param is the drive letter (lowercase?)
winmnt() {
    sudo mkdir -p /mnt/${1}
    sudo mount -t drvfs ${1}: /mnt/${1}
}

# Prefer native VSCode when launching from WSL
code() {

    local path_arg="${1:-${PWD}}"
    local expanded_path="$(realpath ${path_arg})"

    if is-wsl && [ "${expanded_path##/mnt}" != "${expanded_path}" ]; then
        echo "Launching Windows VSCode for ${expanded_path}..."
        win "code ${@} && exit"
    else
        echo "Launching VSCode for ${expanded_path}..."
        command code ${@}
    fi
}

# Add custom commands to docker
docker() {
    local docker_command="command docker"

    if is-wsl; then
        echo "Using Windows docker.exe..."
        echo
        docker_command="win docker.exe"
    fi

    if [ "${1}" == "health" ]; then
        ${docker_command} inspect --format='{{json .State.Health}}' ${2} | json
    elif [ "${1}" == "net-debug" ]; then
        echo "Installing network debug tools in ${2}..."
        ${docker_command} exec ${2} /bin/bash -c 'apt update && apt install net-tools iproute2 dnsutils curl'
        echo
        echo "Installed. Starting shell..."
        echo
        ${docker_command} exec -it ${2} /bin/bash
    else
        ${docker_command} ${@}
    fi
}

# Use Windows nmap
nmap() {
    if is-wsl; then
        echo "Using Windows nmap.exe..."
        echo
        win "nmap.exe ${@}"
    else
        command nmap ${@}
    fi
}

find-new-host() {
    cidr=$(ip route | awk '/\/[0-9]/ {print $2}' | grep $(ip route | awk '/default/ {print $4}' | sed 's/.[0-9]$//'))
    echo
    echo "Unplug the device and press any key to continue..."
    read

    echo "Recording NMAP scan of ${cidr}..."
    before=$(nmap -sn "${cidr}" | grep "scan report")
    echo
    echo "Plug in the device and press any key to continue..."
    read
    after=$(nmap -sn "${cidr}" | grep "scan report")
    echo "Diff:"
    echo
    diff <(echo "${before}") <(echo "${after}")
}

# Test for DNNSEC validation
# Can provide @X.X.X.X as an arg to test non-default DNS server
test-dnssec() {
    local output=$(dig +dnssec dnssec-failed.org A ${@})
    if echo "${output}" | grep -E 'status: SERVFAIL' &> /dev/null; then
        echo "DNNSEC validation is OK"
        return 0
    else
        echo "No DNNSEC validation"
        return 1
    fi
}

# Unset proxy-related environment variables
unset-proxy() {
    unset HTTP_PROXY
    unset HTTPS_PROXY
    unset FTP_PROXY
    unset http_proxy
    unset https_proxy
    unset ftp_proxy
}

# Print the result of a simple equation
calc() {
    echo "$1" | bc
}

# Compile to assembly
asm() {
    gcc -std=gnu99 -S -o "${1}" "${2}"
}

start-gpg-agent() {
    export GPG_AGENT_INFO=${HOME}/.gnupg/S.gpg-agent:0:1
    export GPG_TTY=$(tty)
    gpg-connect-agent /bye &> /dev/null || gpg-agent --daemon --options "${HOME}/.gpg-agent.conf" &> /dev/null
}

# Start php in interactive mode if no arguments are passed
php() {
    if [ "${#}" -eq 0 ]; then
        /usr/bin/php -a
    else
        /usr/bin/php "${@}" # Pass on all arguments
    fi
}

phpserv() {
    php -S localhost:${1:-8080}
}

pyserv() {
    python -m http.server ${1:-8080}
}

pyserv2() {
    python -m SimpleHTTPServer ${1:-8080}
}

# https://github.com/jessfraz/dotfiles/blob/master/.bashrc
# Add tab completion for SSH hostnames based on ~/.ssh/config
# ignoring wildcards
[ -f "${HOME}/.ssh/config" ] && complete -o "default" \
	-o "nospace" \
	-W "$(grep "^Host" ~/.ssh/config | \
	grep -v "[?*]" | cut -d " " -f2 | \
	tr ' ' '\n')" scp sftp ssh

# Load operating system specific files
unamestr=`uname`
if [ "${unamestr}" == 'Darwin' ]; then                  # OSX
    [ -f "${HOME}/.osxrc" ] && source ${HOME}/.osxrc
elif [ "${unamestr}" == 'Linux' ]; then                 # Linux
    [ -f "${HOME}/.linuxrc"  ] && source ${HOME}/.linuxrc
fi

# Load Purdue specific files
if hostname | grep "cs.purdue.edu" &> /dev/null; then
    [ -f "${HOME}/.purduerc" ] && source ${HOME}/.purduerc
fi

# Load work specific files
if [ -f "${HOME}/.workrc" ]; then
    source ${HOME}/.workrc
fi

# Delay loading NVM until it's needed
if [ -f "${HOME}/.nvm/nvm.sh" ]; then
    export NVM_DIR="${HOME}/.nvm"
    [ -s "${NVM_DIR}/bash_completion" ] && source "${NVM_DIR}/bash_completion"

    alias load-nvm='unalias nvm node npm yarn gulp grunt webpack && source ${NVM_DIR}/nvm.sh'
    alias nvm='load-nvm && nvm'
    alias node='load-nvm && node'
    alias npm='load-nvm && npm'
    alias yarn='load-nvm && yarn'
    alias gulp='load-nvm && gulp'
    alias grunt='load-nvm && grunt'
    alias webpack='load-nvm && webpack'
fi

# Configure SSH and GPG agents
start-gpg-agent
if [ -f "${HOME}/.ssh/.install-key.env" ]; then
    source "${HOME}/.ssh/.install-key.env"
    ssh-ring start
fi

