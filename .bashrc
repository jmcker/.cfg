# this file is processed on each interactive invocation of bash

# avoid problems with scp -- don't process the rest of the file if non-interactive
[[ $- != *i* ]] && return

PS1="\[\033[01;32m\]\u@\h:\[\033[01;34m\]\w $ \[\033[0m\]"
HISTSIZE=50

export VISUAL=vim
export EDITOR="$VISUAL"

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

calc() {
    echo "$1" | bc
}

alias ls="ls --color=auto"
alias lsa="ls -A"
alias dir="dir --color=auto"
alias grep="grep --color=auto"
alias version="lsb_release -a"

gcccs() {
    gcc -std=gnu99 -g -Wall -Werror -o "$1" "$2"
}

asm() {
    gcc -std=gnu99 -S -o "$1" "$2"
}

kommit() {
    git commit -m "$1" >> .local.git.out
    #git commit .local.git.out -m "Update .local.git.out"
}

export PATH=$PATH:$HOME/bin/
export PATH=$PATH:/home/$USER/bin/
export PATH=$PATH:$HOME/bin/sublime_text_3
export PATH=$PATH:/opt/qt5.9.2/5.9.2/gcc_64/bin/
export PATH=$PATH:/opt/qt5.9.2/Tools/QtCreator/bin/
export JAVA8_HOME=/usr/lib/jvm/java-8-oracle/
