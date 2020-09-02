# modify the prompt to contain git branch name if applicable
git_prompt_info() {
  current_branch=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
  if [[ -n $current_branch ]]; then
    echo " %{$fg_bold[green]%}%{$current_branch%}%{$reset_color%}"
  fi
}
setopt promptsubst
export PS1='${SSH_CONNECTION+"%{$fg_bold[green]%}%n@%m:"}%{$fg_bold[blue]%}%c%{$reset_color%}$(git_prompt_info) %# '

# completion
autoload -U compinit
compinit

# makes color constants available
autoload -U colors
colors

# enable colored output from ls, etc
export CLICOLOR=1

# history settings
setopt hist_ignore_all_dups inc_append_history
HISTFILE=~/.zhistory
HISTSIZE=4096
SAVEHIST=4096

# awesome cd movements from zshkit
setopt autocd autopushd pushdminus pushdsilent pushdtohome cdablevars
DIRSTACKSIZE=5

# Enable extended globbing
setopt extendedglob

# Allow [ or ] whereever you want
unsetopt nomatch

# vi mode
bindkey -v
bindkey "^F" vi-cmd-mode
bindkey jj vi-cmd-mode
bindkey jk vi-cmd-mode

# handy keybindings
bindkey "^A" beginning-of-line
bindkey "^E" end-of-line
bindkey "^R" history-incremental-search-backward
bindkey "^P" history-search-backward
bindkey "^Y" accept-and-hold
bindkey "^N" insert-last-word

# aliases
source ~/.aliases

# Put homebrew as early as possible in the path
PATH="/usr/local/bin:$PATH"

# load rbenv if available
if [ -d "$HOME/.rbenv" ]; then
  PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init - --no-rehash)"
fi

if [ -d "$HOME/.pyenv" ]; then
  PATH="$HOME/.pyenv/bin:$PATH"

  export PYENV_ROOT="$HOME/.pyenv"
  export PYENV_VIRTUALENV_DISABLE_PROMPT=1
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
fi

if [ -d "$HOME/.pgvm" ]; then
  source $HOME/.pgvm/pgvm_env
fi

# mkdir .git/safe in the root of repositories you trust
PATH=".git/safe/../../bin:$PATH"

function tmux-init {
  if [ $TMUX ]; then
    echo "Already in a tmux session"
  fi

  projects_root="${HOME}/Work"
  project_name="$1"
  project_directory="${projects_root}/${project_name}"

  if [ -d "$project_directory" ]; then

    cd "$project_directory"

    tmux start-server

    tmux new-session -d -n vim -s "$project_name"
    tmux send-keys -t "${project_name}:1" 'vim' C-m
    tmux new-window -t "${project_name}:2" -n git

    cd -

    tmux select-window -t "${project_name}:1"
    tmux attach-session -d -t "${project_name}"
  else
    echo "${project_directory} does not exist!"
  fi
}

typeset -U PATH

export PATH
