#BWPP:reprogram-pettiness-throbbing-refold-gutless
#KN4oq3g5!qZPiTbxu%U9vW&t&@3@#98#Ce*76wj8teR9u58@gQDM

# $HOME/.zshrc
# --- UWSM WRAPPER ---
if uwsm check may-start && uwsm select; then
	exec uwsm start default
fi
# --- Path and Environment Variables ---
export PATH=$HOME/bin:/usr/bin:/usr/local/bin:/opt/cuda/bin:$PATH

export CUDA_PATH='/opt/cuda:/opt/cuda/bin:/opt/cuda/nsight_compute:/opt/cuda/nsight_systems/bin'
export NVCC_CCBIN='/usr/bin/g++-14'

export EDITOR='micro'
export SYSTEMD_EDITOR='micro'
export GIT_EDITOR='micro'
export VISUAL='micro'

export XDG_FILE_CHOOSER='yazi'
# --- Zsh Prompt ---
autoload -Uz promptinit vcs_info 
promptinit
setopt PROMPT_SUBST
#--------
#[#Color-Shceme#]#
local CB_PRIMARY='#4B9CD3' 
local CB_LIGHT='#7BAFD4'  
local CB_DARK='#3A7CAC'    
local CB_TEXT_NEUTRAL='#E0E0E0'   
local CB_PARAM_NEUTRAL='#B0BEC5'  
local CB_GIT_STAGED='#B0BEC5' 
local CB_GIT_UNSTAGED='#EF5350' 
#-------
PROMPT="%F{$CB_PRIMARY}%n@%m%f\${vcs_info_msg_0_} %F{$CB_LIGHT}\$ %f"
RPROMPT="%F{$CB_PRIMARY}%~%f"
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
alias fastfetch-theme-selector="bash ~/.config/fastfetch-theme-selector/FastCat/fastcat.sh -s"
alias szsh="source ~/.zshrc"
alias fetch="fastfetch"
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
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000

fpath+=~/.zfunc
fpath=(~/.local/zsh/zsh-completions/src $fpath)
fpath=(/home/earlyman/.zfunc/VCS_Info $fpath)
fpath=(/home/earlyman/.zfunc/VCS_Info/Backends $fpath)
fpath=(/home/earlyman/.zfunc/site-functions $fpath)
fpath=(/home/earlyman/.zfunc/Base $fpath)
fpath=(/home/earlyman/.zfunc/Linux $fpath)
fpath=(/home/earlyman/.zfunc/Unix $fpath)
fpath=(/home/earlyman/.zfunc/X $fpath)
fpath=(/home/earlyman/.zfunc/Zsh $fpath)

autoload -Uz compinit
compinit

eval "$(zoxide init zsh)"
source /home/earlyman/.local/zsh/zsh-completions/zsh-completions.plugin.zsh
zstyle ':completion:*' menu select
zstyle ':completion::complete:*' gain-privileges 1

source /home/earlyman/.local/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# --- Custom Syntax Highlighting Colors ---
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

