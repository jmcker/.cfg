# this file is processed on each interactive invocation of bash

# avoid problems with scp -- don't process the rest of the file if non-interactive
[[ $- != *i* ]] && return

is-ssh-con() {
    if [ -n "${SSH_CLIENT}" ] || [ -n "${SSH_TTY}" ]; then
        echo -ne '<ssh>'
    fi
}

update-window-title() {
    local window_host="bash"
    [ ! -z "${WSL_DISTRO_NAME}" ] && local window_host="${WSL_DISTRO_NAME}"
    [ ! -z "$(is-ssh-con)" ] && local window_host="${USER}@${HOSTNAME}"
    echo -ne "\033]0;${window_host}  |  $(dirs +0)\a"
}

# In case install-key script isn't defined
current-ssh-ring() {
    echo ""
}

PS1='\[\e[01;32m\]\u@\h\[\e[01;30m\]$(is-ssh-con)\[\e[01;32m\]:\[\e[01;34m\]\w ($(current-ssh-ring)) $ \[\e[0m\]'
PROMPT_COMMAND="update-window-title;"
export LS_COLORS='di=1;34:ow=1;34:'
export VISUAL=vim
export EDITOR="${VISUAL}"
export HISTSIZE=1000

bind "TAB:menu-complete"
bind '"\e[Z":menu-complete-backward'
#bind "set show-all-if-ambiguous on"
#bind "set menu-complete-display-prefix on"

alias mail=mailx
alias i=dirinfo

alias .bashrc="vim ~/.bashrc"
alias .vimrc="vim ~/.vim/vimrc"
alias bc="bc -l"

# Git controls for dotfile repo
alias cfg='git --git-dir=${HOME}/.cfg --work-tree=${HOME}'
cfg config --local status.showUntrackedFiles no

alias ls="ls --color=auto"
alias lsa="ls -A"
alias dir="dir --color=auto"
alias grep="grep --color=auto"
alias fold="fold -s"
alias version="uname -a && lsb_release -a"
alias extip="dig -4 +short myip.opendns.com A @resolver1.opendns.com && dig -6 +short myip.opendns.com AAAA @resolver1.opendns.com"
alias json="python -m json.tool"
alias sqlite="sqlite3"
alias python="python3"
alias gitaddx="git update-index --chmod +x"
alias cdg='cd "`git rev-parse --show-toplevel`"' # single quotes to prevent expansion
alias newb='/mnt/c/Windows/System32/cmd.exe /c start ubuntu.exe -c "cd $(printf %q "${PWD}"); /bin/bash"'
alias ssh-nk="ssh -o PreferredAuthentications=keyboard-interactive,password -o PubkeyAuthentication=no"
alias rdp="xfreerdp /v:localhost /w:1920 /h:1000"
alias bigbois="echo Loading... && du -sh --exclude . --exclude .. * .* 2>/dev/null | sort -rh | more -15"

bashrc() {
    vim ~/.bashrc
    source ~/.bashrc
    echo Sourced ~/.bashrc.
}

# Start a Windows program
win() {
    /mnt/c/Windows/System32/cmd.exe /c "${@}"
}

code() {
    local expanded_path="$(realpath ${1})"

    if [ ! -z "${WSL_DISTRO_NAME}" ] && [ "${expanded_path##/mnt}" != "${expanded_path}" ]; then
        echo "Launching Windows VSCode for ${expanded_path}..."
        win "code ${@} && exit"
    else
        echo "Launching VSCode for ${expanded_path}..."
        command code ${@}
    fi
}

nmap() {
    if [ ! -z "${WSL_DISTRO_NAME}" ]; then
        echo "Using Windows nmap.exe..."
        echo
        win "nmap ${@}"
    else
        command nmap ${@}
    fi
}

# Mount Windows flashdrive or disk
winmnt() {
    mount -t drvfs ${1}: /mnt/${1}
}

# Print the result of a simple equation
calc() {
    echo "$1" | bc
}

# Compile to assembly
asm() {
    gcc -std=gnu99 -S -o "${1}" "${2}"
}

# Move to CS251 Project directory
cdp() {
    cd ${HOME}/OneDrive\ -\ purdue.edu/Archive/CS\ 252/Lab\ "${1}"/lab"${1}"-src/
}

start-gpg-agent() {
    export GPG_AGENT_INFO=${HOME}/.gnupg/S.gpg-agent:0:1
    export GPG_TTY=$(tty)
    gpg-connect-agent /bye &> /dev/null || gpg-agent --daemon &> /dev/null
}

# data git via ssh
gitp() {
    git "${1}" ssh://jmckern@data.cs.purdue.edu:/homes/cs252/sourcecontrol/work/jmckern/"${2}"
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
    python3 -m http.server ${1:-8080}
}

pyserv2() {
    python2 -m SimpleHTTPServer ${1:-8080}
}

export PATH="${HOME}/bin/:${PATH}"
export PATH="${HOME}/.local/bin:${PATH}"
export PATH="/home/${USER}/bin/:${PATH}"
export PATH="/opt/qt/5.9.2/gcc_64/bin:${PATH}" # Qt on data.cs
export PATH="${PATH}:/p/xinu/bin" # XINU on xinu.cs
export JAVA8_HOME=/usr/lib/jvm/java-8-oracle/

# Load  operating system specific files
unamestr=`uname`
if [ "${unamestr}" == 'Darwin' ]; then                  # OSX
    [ -f "${HOME}/.osx_bashrc" ] && source ${HOME}/.osx_bashrc
elif [ "${unamestr}" == 'Linux' ]; then                 # Linux
    [ -f "${HOME}/.linux_bashrc"  ] && source ${HOME}/.linux_bashrc
fi

if [ -f ".workrc" ]; then
    source ${HOME}/.workrc
fi

# Configure SSH and GPG agents
start-gpg-agent
if [ -f ${HOME}/.ssh/.install-key.env ]; then
    source ${HOME}/.ssh/.install-key.env
    ssh-ring start
fi
