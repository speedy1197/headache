#!/bin/zsh
# --- Locale ---
if [ -z "$LANG" ]; then
  if [ -n "$XDG_CONFIG_HOME" ] && [ -r "$XDG_CONFIG_HOME/locale.conf" ]; then
    . "$XDG_CONFIG_HOME/locale.conf"
  elif [ -n "$HOME" ] && [ -r "$HOME/.config/locale.conf" ]; then
    . "$HOME/.config/locale.conf"
  elif [ -r /etc/locale.conf ]; then
    . /etc/locale.conf
  fi
fi

LANG=${LANG:-en_US.UTF-8}
export LANG LANGUAGE LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE \
       LC_MESSAGES LC_MEASUREMENT LC_IDENTIFICATION \
# --- Uwsm Wrapper ---
if uwsm check may-start && uwsm select; then
	exec uwsm start default
fi
# --- YAZI (Terminal File Manager Integration) ---
function y() {
    local tmpfile
    tmpfile="$(mktemp -t "yazi-cwd.XXXXXX")"
    if [[ -z "$tmpfile" ]]; then
        print -u2 -r -- "y: mktemp failed to create temporary file."
        return 1
    fi

    yazi "$@" --cwd-file="$tmpfile"
    local yazi_status=$?
    if [[ "$yazi_status" -eq 0 ]] && [[ -s "$tmpfile" ]]; then
        local cwd
        IFS= read -r -d $'\0' cwd < "$tmpfile"
        if [[ -n "$cwd" ]] && [[ "$cwd" != "$PWD" ]]; then
            builtin cd -- "$cwd" 
        fi
    fi
    rm -f -- "$tmpfile" 
    return $yazi_status
}
# --- Paths ---
export PATH=$HOME:/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin:/opt/cuda/bin:$PATH
export CUDA_PATH=/opt/cuda:/opt/cuda/bin:/opt/cuda/nsight_compute:/opt/cuda/nsight_systems/bin
export NVCC_CCBIN=/usr/bin/g++-14
export EDITOR=micro
export SYSTEMD_EDITOR=micro
export GIT_EDITOR=micro 
export VISUAL=micro
# --- Prompt ---
autoload -Uz promptinit vcs_info
promptinit
setopt PROMPT_SUBST
# --- Color-Shceme ---
local CB_PRIMARY='#79002B'
local CB_DARK='#7C0028' 
local CB_TEXT_NEUTRAL='#79002B' 
local CB_PARAM_NEUTRAL='#7C0028'  
local CB_GIT_STAGED='#7C0028'
local CB_GIT_UNSTAGED='#7C0028' 
#-------
PROMPT="%F{$CB_PRIMARY}%n@%m%f\${vcs_info_msg_0_} %F{$CB_PRIMARY}\$ %f"
RPROMPT="%F{$CB_DARK}%~%f"
# --- GitHub ---
precmd() {
  vcs_info
  print -Pn "\e]0;%~\a"
}
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "%F{$CB_GIT_STAGED}●%f"
zstyle ':vcs_info:git:*' unstagedstr "%F{$CB_GIT_UNSTAGED}●%f"
zstyle ':vcs_info:git:*' formats " %F{$CB_LIGHT}(%b)%f%c%u"
zstyle ':vcs_info:git:*' actionformats " %F{$CB_LIGHT}(%b|%a)%f%c%u"
# --- Aliases ---
alias zshcfg="micro ${ZDOTDIR:-$HOME}/.zshrc"
alias zshpf="micro ${ZDOTDIR:-$HOME}/.zprofile"
alias zshenv="micro ${ZDOTDIR:-$HOME}/.zshenv"
alias hypr="${EDITOR} ~/.config/hypr/hyprland.conf"
alias m="${EDITOR}"
alias nf="neofetch"
alias szsh="source ~/.zshrc"
alias fetch="fastfetch"
alias bt="bluetuith"
alias s="sudo"
alias pman="pacman"
# --- History ---
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
# --- F Path ---
fpath=(/home/earlyman/github/zsh-completions/src $fpath)
# --- Completions ---
autoload -Uz compinit
compinit

zstyle ':completion:*' menu select
zstyle ':completion::complete:*' gain-privileges 1
# --- Zoxide ---
eval "$(zoxide init zsh)"
# --- Custom Syntax Highlighting Colors ---
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh
ZSH_HIGHLIGHT_MAXLENGTH=512
ZSH_HIGHLIGHT_HIGHLIGHTERS+=(brackets pattern cursor)
if typeset -gA ZSH_HIGHLIGHT_STYLES &>/dev/null; then
    ZSH_HIGHLIGHT_STYLES[default]="fg=$CB_TEXT_NEUTRAL"
    ZSH_HIGHLIGHT_STYLES[command]="fg=$CB_PRIMARY"
    ZSH_HIGHLIGHT_STYLES[hashed-command]="fg=$CB_PRIMARY"
    ZSH_HIGHLIGHT_STYLES[builtin]="fg=$CB_DARK"
    ZSH_HIGHLIGHT_STYLES[alias]="fg=$CB_PRIMARY,bold"
    ZSH_HIGHLIGHT_STYLES[function]="fg=$CB_LIGHT,bold"
    ZSH_HIGHLIGHT_STYLES[keyword]="fg=$CB_PRIMARY"
    ZSH_HIGHLIGHT_STYLES[option]="fg=$CB_LIGHT"
    ZSH_HIGHLIGHT_STYLES[parameter]="fg=$CB_PARAM_NEUTRAL"
    ZSH_HIGHLIGHT_STYLES[string]="fg=$CB_DARK"
    ZSH_HIGHLIGHT_STYLES[numeric]="fg=$CB_LIGHT"
    ZSH_HIGHLIGHT_STYLES[redirection]="fg=$CB_PRIMARY"
    ZSH_HIGHLIGHT_STYLES[comment]="fg=$CB_COMMENT_NEUTRAL"
    ZSH_HIGHLIGHT_STYLES[unknown-token]="fg=$CB_GIT_UNSTAGED,bold"
    ZSH_HIGHLIGHT_STYLES[command_error]="fg=$CB_GIT_UNSTAGED,bold" # Added for consistency
else
    print -u2 -r -- "Warning: ZSH_HIGHLIGHT_STYLES not available. Syntax highlighting colors not applied."
fi
