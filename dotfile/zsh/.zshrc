# License : MIT
# http://mollifier.mit-license.org/
########################################
#export LANG=ja_JP.UTF-8

autoload -Uz colors
colors

autoload -U compinit
compinit

# emacs key bind
bindkey -e

# history
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000

#export LSCOLORS=exfxcxdxbxegedabagacad
export LS_COLORS='di=37;01;04:fi=33;01:ln=35;01:so=32;01:pi=33;01:ex=31;01:bd=46;34;01:cd=43;01;34;01:su=41;30;01:sg=46;30;01:tw=42;30;01:ow=43;30;01'

#PROMPT='%n%~'
#PROMPT='%{${fg[red]}%} $n %{${reset_color}%}'

PROMPT="%{$fg[red]%}%n:/%~%(!.#.$) %{$reset_color%}"

#PROMPT2="%{$fg[green]%}%_> %{$reset_color%}"
#SPROMPT="%{$fg[red]%}correct: %R -> %r [nyae]? %{$reset_color%}"
#RPROMPT="%{$fg[cyan]%}[%~]%{$reset_color%}"

alias ls="ls -ltr --color=auto"
alias l='ls -ltr --color=auto'
alias gls="gls --color"

alias mkdir='mkdir -p'

alias emacs="emacs -nw"
alias e="emacs -nw"

zstyle ':completion:*' list-colors 'di=37' 'ln=35' 'so=32' 'ex=31' 'bd=46;34' 'cd=43;34'

setopt auto_cd
setopt correct
setopt auto_pushd
setopt pushd_ignore_dups

#global alias

alias -g L='| less'
alias -g G='| grep'

