### POWERLEVEL10K ###
if [[ -r '${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh' ]]; then
  source '${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh'
fi

# You may need to manually set your language environment
export LANG=en_GB.UTF-8

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

### OH MY ZSH ###
# Path to your oh-my-zsh installation.
export ZSH='/home/edward/.oh-my-zsh'
ZSH_THEME='powerlevel10k/powerlevel10k'

# Uncomment the following line to automatically update without prompting.
DISABLE_UPDATE_PROMPT='true'

plugins=(git
         zsh-autosuggestions
         zsh-syntax-highlighting
         zsh-nvm
         zsh-yarn-completions
         git-flow-completion)

# Sourcing oh-my-zsh
source $ZSH/oh-my-zsh.sh

### ALIASES ###
alias doas='doas --'                                        # root privileges
alias ls='exa -al --color=always --group-directories-first' # my preferred listing
alias la='exa -a --color=always --group-directories-first'  # all files and dirs
alias ll='exa -l --color=always --group-directories-first'  # long format
alias lt='exa -aT --color=always --group-directories-first' # tree listing
alias yaysyu='yay -Syu --noconfirm'                         # update standard pkgs and AUR pkgs (yay)
alias cleanup='sudo pacman -Rns (pacman -Qtdq)'             # remove orphaned packages
# grep
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
# confirmations
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias df='df -h'
alias jctl='journalctl -p 3 -xb'                            # get error messages from journalctl
# dotfiles alias
alias dotfiles='/usr/bin/git --git-dir=$HOME/dotfiles/ --work-tree=$HOME'
# youtube-dl
alias yta-aac='youtube-dl --extract-audio --audio-format aac'
alias yta-best='youtube-dl --extract-audio --audio-format best'
alias yta-flac='youtube-dl --extract-audio --audio-format flac'
alias yta-m4a='youtube-dl --extract-audio --audio-format m4a'
alias yta-mp3='youtube-dl --extract-audio --audio-format mp3'
alias yta-wav='youtube-dl --extract-audio --audio-format wav'
alias ytv-best='youtube-dl -f bestvideo+bestaudio'
# get fastest mirrors
alias mirror='sudo reflector -f 30 -l 30 --number 10 --verbose --save /etc/pacman.d/mirrorlist'
alias mirrord='sudo reflector --latest 50 --number 20 --sort delay --save /etc/pacman.d/mirrorlist'
alias mirrors='sudo reflector --latest 50 --number 20 --sort score --save /etc/pacman.d/mirrorlist'
alias mirrora='sudo reflector --latest 50 --number 20 --sort age --save /etc/pacman.d/mirrorlist'
# nvim
alias vim='nvim'
alias vi='nvim'
alias v='nvim'

### KEY BINDINGS ###
bindkey -s '^o' 'ranger^M'
bindkey -s '^v' 'nvim\n'
bindkey '^p' up-line-or-beginning-search # Up
bindkey '^n' down-line-or-beginning-search # Down
bindkey '^k' up-line-or-beginning-search # Up
bindkey '^j' down-line-or-beginning-search # Down

### RANDOM COLOR SCRIPT ###
colorscript random

# Environment variables set everywhere
export EDITOR='code'
export TERMINAL='alacritty'
export BROWSER='brave'
export PATH=/home/edward/Android/Sdk/platform-tools:$PATH
