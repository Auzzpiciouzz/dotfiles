#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

# Run nitch on interactive terminals only
#[[ $- == *i* ]] && nitch

# Starship prompt (must be last)
eval "$(starship init bash)"
export EDITOR=nvim
export PATH="$HOME/.local/bin:$PATH"
alias htbvpn='sudo openvpn ~/htb/academy-regular.ovpn'
