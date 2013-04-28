export PATH=$PATH:/usr/local/sbin:/usr/local/bin/coffee
export PATH=/usr/local/Cellar/postgresql/9.1.3/bin:$PATH

source ~/.git-completion.bash

export CLICOLOR=1
export LSCOLORS=dxxxxxxxxxxxxxxxxxdxdx
export LC_CTYPE="en_US.UTF-8"

function prompt
{
local WHITE="\[\033[1;37m\]"
local GREEN="\[\033[0;92m\]"
local CYAN="\[\033[0;36m\]"
local GRAY="\[\033[0;37m\]"
local BLUE="\[\033[0;34m\]"
local YELLOW="\[\033[0;93m\]"
export PS1="
${GRAY}michael@\h ${YELLOW}[\W"'$(__git_ps1 "(%s)")'"]\$ ${GREEN}"
}
prompt

[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"