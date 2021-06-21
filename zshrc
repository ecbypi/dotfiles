export LANG=en_US.UTF-8
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

# FIXME: This drastically slows down shell initialization. Putting up with it for now because
# it's better than relying on Homebrew to install node.
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# load rbenv if available
if [ -d "$HOME/.rbenv" ]; then
  PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init - --no-rehash)"
fi

if [ -d "$HOME/.pyenv" ]; then
  PATH="$HOME/.pyenv/bin:$PATH"

  export PYENV_ROOT="$HOME/.pyenv"
  export PYENV_VIRTUALENV_DISABLE_PROMPT=1

  if command -v pyenv 1> /dev/null 2>&1; then
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
  fi
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

# The `m` gem doesn't work with Rails when parallel tests are enabled. When `m`'s argument
# is a file path, a duplicate `at_exit` hook is registered causing the parallel tests runner to
# fork again after all the tests have run. This causes an error because the DRb server is no
# longer running at this point.
#
# This function is a convenience since I've learned to use `m` and want to avoid context
# switching between `m` in non-Rails projects and `rails test` (or an alias for it) in Rails
# projects.
function m {
  # TODO: Is it possible to make this work from directories within the Rails app?
  if [ -f config/environment.rb ]; then
    # `rails test` defaults to excluding system tests unless they are specified explicitly
    #
    # If the arguments are empty or equal to "test", (from habit of running `m test`), use
    # "test/*" so all tests are run
    if [[ -z "$@" || "test" -eq "$@" ]]; then
      rails test test/*
    else
      rails test $@
    fi

  # If not in a Rails app, assume `m` is installed in through bundler
  #
  # TODO: Detect if `m` is in the bundle; then check if it's installed globally; then exit if
  # nothing was found
  else
    bundle exec m $@
  fi
}

typeset -U PATH

export PATH

export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_AUTO_UPGRADE=1
