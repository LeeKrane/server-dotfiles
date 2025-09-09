# Determine OS type
OS_TYPE=$(grep -w "ID" /etc/os-release | cut -d "=" -f 2 | tr -d '"')
if [[ "$OS_TYPE" == "nobara" ]]; then
	OS_TYPE="fedora"
fi

alias c='clear'
alias nv='nvim'
alias htop='btop'
alias top='btop'

# fedora specific
if [[ "$OS_TYPE" == "fedora" ]]; then
	alias ls='eza -h'
	alias ll='eza -lh'
	alias la='eza -ah'
	alias lla='eza -lah'
	alias tree='eza --tree'
	alias cat='bat --color=always'
	alias cd='z'
	alias zz='z -'
	alias lg='lazygit'
# debian specific
elif [[ "$OS_TYPE" == "debian" ]]; then
	alias ls='exa -h'
	alias ll='exa -lh'
	alias la='exa -ah'
	alias lla='exa -lah'
	alias tree='exa --tree'
fi

# fzf
alias fzfp='fzf --preview="bat --color=always {}" --preview-window "~4,+{2}+4/3,<80(up)"'
alias fnv='fzfp --bind "enter:become:nvim {1}"'

alias rf='fzf --disabled --ansi --bind "start:reload:rg --hidden --no-ignore --column --color=always --smart-case {q}" --bind "change:reload:rg --hidden --no-ignore --column --color=always --smart-case {q}" --delimiter : --preview="bat --style=full --color=always --highlight-line {2} {1}" --preview-window "~4,+{2}+4/3,<80(up)" --query "$*"'
alias rfnv='rf --bind "enter:become:nvim {1} +{2}"'
