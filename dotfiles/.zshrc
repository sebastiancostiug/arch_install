# Example .zshrc for Arch Linux
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-autosuggestions F-Sy-H)
source $ZSH/oh-my-zsh.sh

# Custom prompt config (if using powerlevel10k)
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# Source user aliases if present
[ -f "$HOME/.zsh_aliases" ] && source "$HOME/.zsh_aliases"
