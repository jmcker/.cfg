# this file is processed on each interactive invocation of bash

# avoid problems with scp -- don't process the rest of the file if non-interactive
[[ $- != *i* ]] && return

if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    PS1="\[\033[01;32m\]\u@\h\[\033[01;30m\]<ssh>\[\033[01;32m\]:\[\033[01;34m\]\w $ \[\033[0m\]"
else
    PS1="\[\033[01;32m\]\u@\h:\[\033[01;34m\]\w $ \[\033[0m\]"
fi

export LS_COLORS='di=1;34:ow=1;34:'
export VISUAL=vim
export EDITOR="$VISUAL"
export HISTSIZE=50

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
alias cfg='/usr/bin/git --git-dir=$HOME/.cfg --work-tree=$HOME'
cfg config --local status.showUntrackedFiles no

alias ls="ls --color=auto"
alias lsa="ls -A"
alias dir="dir --color=auto"
alias grep="grep --color=auto"
alias version="uname -a && lsb_release -a"
alias extip="dig +short myip.opendns.com @resolver1.opendns.com"
alias gitaddx="git update-index --chmod +x"
alias cdg='cd `git rev-parse --show-toplevel`' # single quotes to prevent expansion
alias newb="/mnt/c/Windows/System32/cmd.exe /c 'start bash'"
alias ssh-nk="ssh -o PreferredAuthentications=keyboard-interactive,password -o PubkeyAuthentication=no"

# Start a Windows program
win() {
    /mnt/c/Windows/System32/cmd.exe /c "start $@"
}

# Print the result of a simple equation
calc() {
    echo "$1" | bc
}

# Compile with required flags for CS240
gcccs() {
    gcc -std=gnu99 -g -Wall -Werror -o "$1" "$2"
}

# Compile to assembly
asm() {
    gcc -std=gnu99 -S -o "$1" "$2"
}

# Move to CS251 Project directory
cdp() {
    cd $HOME/OneDrive\ -\ purdue.edu/CS\ 252/Lab\ "$1"/lab"$1"-src/
}


# Prep ssh-agent for WSL
start-ssh-agent() {
    if [ ! -z "$(ls ~/.ssh/*.key 2>/dev/null)" ]; then
        if [ -z "$(pgrep ssh-agent -u $USER)" ]; then

            rm -rf /tmp/ssh-* 2>/dev/null
            echo "Starting ssh-agent..."

            eval $(ssh-agent)
            ssh-add ~/.ssh/*.key

        else
            export SSH_AGENT_PID=$(pgrep ssh-agent -u $USER)
            export SSH_AUTH_SOCK=$(find /tmp/ssh-* -user $USER -name "agent.*" 2>/dev/null)
        fi
    fi
}

start-gpg-agent() {
    export GPG_AGENT_INFO=$HOME/.gnupg/S.gpg-agent:0:1
    export GPG_TTY=$(tty)
    gpg-connect-agent /bye || gpg-agent --daemon #&>/dev/null
}

# data git via ssh
gitp() {
    git "$1" ssh://jmckern@data.cs.purdue.edu:/homes/cs252/sourcecontrol/work/jmckern/"$2"
}

# Start php in interactive mode if no arguments are passed
php() {
    if [ "$#" -eq 0 ]; then
        /usr/bin/php -a
    else
        /usr/bin/php "$@" # Pass on all arguments
    fi
}

phpserv() {
    php -S localhost:${1:-8080}
}

pyserv() {
    python -m SimpleHTTPServer ${1:-8080}
}

py3serv() {
    python3 -m SimpleHTTPServer ${1:-8080}
}

export PATH="$HOME/bin/:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="/home/$USER/bin/:$PATH"
export PATH="/opt/qt5.9.2/5.9.2/gcc_64/bin:$PATH" # Qt on data.cs
export PATH="$PATH:/p/xinu/bin" # XINU on xinu.cs
export JAVA8_HOME=/usr/lib/jvm/java-8-oracle/

# Load  operating system specific files
unamestr=`uname`
if [[ "$unamestr" == 'Darwin' ]]; then                  # OSX
    [[ -f "$HOME/.osx_bashrc" ]] && source $HOME/.osx_bashrc
elif [[ "$unamestr" == 'Linux' ]]; then                 # Linux
    [[ -f "$HOME/.linux_bashrc"  ]] && source $HOME/.linux_bashrc
fi

# Configure SSH and GPG agents
start-ssh-agent
start-gpg-agent
