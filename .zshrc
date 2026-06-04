# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/home/hagom/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME=""

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
 export UPDATE_ZSH_DAYS=30

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
 ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# Caution: this setting can cause issues with multiline prompts (zsh 5.7.1 and newer seem to work)
# See https://github.com/ohmyzsh/ohmyzsh/issues/5765
 COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(command-not-found compleat cp debian dirhistory docker docker-compose gcloud git git-extras  gitignore history node ng nmap npm pip postgres python rust sudo systemd tig tmux zoxide zsh-interactive-cd zsh-autosuggestions zsh-completions zsh-syntax-highlighting )

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
 if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='vim'
 else
   export EDITOR='nvim'
 fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

export EDITOR='nvim'
# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

source <(fzf --zsh)

#alias zs="source ~/.zshrc"
alias sp="speedtest"
alias actualizar="sudo apt update ; sudo apt upgrade -y ; sudo apt install -f ; sudo apt autoremove -y ; sudo apt autoclean ; sudo apt clean ; pip3 install -U --user --compile --break-system-packages glances noteshrink yt-dlp classifier meson ; sudo flatpak upgrade -y"

# sccache - compilación C/C++ y Rust
export SCCACHE_DIR="/baul/sccache"              # Directorio donde sccache almacena los objetos compilados en cache
export SCCACHE_CACHE_SIZE="20G"                 # Tamaño maximo del cache (20 GiB)
export CC="sccache gcc"                         # Wrapper para compilacion C (cachea via sccache)
export CXX="sccache g++"                        # Wrapper para compilacion C++ (cachea via sccache)
export RUSTC_WRAPPER="$(which sccache)"          # Wrapper para compilacion Rust via cargo (cachea via sccache)
export PAGER="less"
export MANPAGER="less -R"
export GROFF_NO_SGR=1
export LESS_TERMCAP_mb=$'\E[1;31m'      # Inicio parpadeo (rojo)
export LESS_TERMCAP_md=$'\E[1;36m'      # Inicio negrita (cian)
export LESS_TERMCAP_me=$'\E[0m'         # Fin de modo
export LESS_TERMCAP_so=$'\E[01;33m'     # Inicio modo destacado (amarillo)
export LESS_TERMCAP_se=$'\E[0m'         # Fin modo destacado
export LESS_TERMCAP_us=$'\E[1;32m'      # Inicio subrayado (verde)
export LESS_TERMCAP_ue=$'\E[0m'         # Fin subrayado


export PATH=/home/hagom/.local/bin:$PATH
export PATH=/home/linuxbrew/.linuxbrew/bin:$PATH
export PATH="$PATH:$HOME/flutter/bin"
export FZF_DEFAULT_OPTS='--info=inline'
export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix'
export FZF_ALT_C_OPTS="--preview 'tree -C {}'"

export FZF_CTRL_T_OPTS="
  --preview 'bat -n --color=always {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"

export FZF_CTRL_R_OPTS="
  --preview 'echo {}' --preview-window up:3:hidden:wrap
  --bind 'ctrl-/:toggle-preview'
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --color header:italic
  --header 'Press CTRL-Y to copy command into clipboard'"

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

#Historial de ZSH
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=10000000
export SAVEHIST=10000000
setopt BANG_HIST                 # Treat the '!' character specially during expansion.
HISTDUP=erase                    # Treat the '!' character specially during expansion.
setopt appendhistory             # Treat the '!' character specially during expansion.
setopt sharehistory              # Treat the '!' character specially during expansion.
setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.
setopt HIST_VERIFY               # Don't execute immediately upon history expansion.
setopt HIST_BEEP                 # Beep when accessing nonexistent history.
#source /home/hagom/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

eval "$(oh-my-posh init zsh --config $HOME/.cache/oh-my-posh/themes/quick-term.omp.json)"
eval "$(atuin init zsh)"
export PATH="$PATH:/opt/mssql-tools/bin"

#source /home/hagom/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
#source /home/hagom/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# pnpm
export PNPM_HOME="/home/hagom/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end

# bun completions
[ -s "/home/hagom/.bun/_bun" ] && source "/home/hagom/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"

[[ -s "/etc/grc.zsh" ]] && source /etc/grc.zsh

# opencode
export PATH=/home/hagom/.opencode/bin:$PATH

export PATH=/usr/lib/:$PATH
export PATH="$HOME/.local/share/yabridge:$PATH"

# Added by GitButler installer
eval "$(but completions zsh)"

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi
export WINENTSYNC=1
fpath=(~/.zsh/completions $fpath)
autoload -U compinit && compinit

[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/hagom/.lmstudio/bin"
# End of LM Studio CLI section



# Added by Antigravity CLI installer
export PATH="/home/hagom/.local/bin:$PATH"

