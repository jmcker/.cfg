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
    cd $HOME/OneDrive\ -\ purdue.edu/CS\ 251/Projects/P"$1"/P"$1"-src/
}

# Start php in interactive mode if no arguments are passed
php() {
    if [ "$#" -eq 0 ]; then
        /usr/bin/php -a
    else
        /usr/bin/php "$@" # Pass on all arguments
    fi
}

pyserv() {
    python -m SimpleHTTPServer ${1:-8080}
}

py3serv() {
    python3 -m SimpleHTTPServer ${1:-8080}
}

export PATH="$HOME/bin/:$PATH"
export PATH="/home/$USER/bin/:$PATH"
export PATH="/opt/qt5.9.2/5.9.2/gcc_64/bin:$PATH" # Qt on data.cs
export JAVA8_HOME=/usr/lib/jvm/java-8-oracle/

# Load  operating system specific files
unamestr=`uname`
if [[ "$unamestr" == 'Darwin' ]]; then                  # OSX
    [[ -f ".osx_bashrc" ]] && source .osx_bashrc
elif [[ "$unamestr" == 'Linux' ]]; then                 # Linux
    [[ -f ".linux_bashrc"  ]] && source .linux_bashrc
fi
