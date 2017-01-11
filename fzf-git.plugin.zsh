#!/usr/bin/env zsh

# Check if the current working directory is in a git repo
(( $+functions[is_in_git_repo] )) || function is_in_git_repo() {
  git rev-parse HEAD > /dev/null 2>&1
}

(( $+functions[git_files] )) || function git_files() {
  is_in_git_repo || return
  git -c color.status=always status --short |
  fzf-tmux -m --ansi --nth 2..,.. \
    --preview '(git diff --color=always -- {-1} | sed 1,4d; cat {-1}) | head -500' |
  cut -c4- | sed 's/.* -> //'
}

(( $+functions[git_branches] )) || function git_branches() {
  is_in_git_repo || return
  git branch -a --color=always | grep -v '/HEAD\s' | sort |
  fzf-tmux --ansi --multi --tac --preview-window right:70% \
    --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1) | head -'$LINES |
  sed 's/^..//' | cut -d' ' -f1 |
  sed 's#^remotes/##'
}

(( $+functions[git_tags] )) || function git_tags() {
  is_in_git_repo || return
  git tag --sort -version:refname |
  fzf-tmux --multi --preview-window right:70% \
    --preview 'git show --color=always {} | head -'$LINES
}

(( $+functions[git_history] )) || function git_history() {
  is_in_git_repo || return
  git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph --color=always |
  fzf-tmux --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' \
    --header 'Press CTRL-S to toggle sort' \
    --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show --color=always | head -'$LINES |
  grep -o "[a-f0-9]\{7,\}"
}

(( $+functions[git_remotes] )) || function git_remotes() {
  is_in_git_repo || return
  git remote -v | awk '{print $1 "\t" $2}' | uniq |
  fzf-tmux --tac \
    --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" {1} | head -200' |
  cut -d$'\t' -f1
}

# A helper function to join multi-line output from fzf
(( $+functions[join-lines] )) || function join-lines() {
  local item
  while read item; do
    echo -n "${(q)item} "
  done
}

(( $+functions[bind-git-helper] )) || function bind-git-helper() {
  local char
  typeset -A widgets; widgets=( \
    f 'files' \
    t 'tags' \
    b 'branches' \
    h 'history' \
    r 'remotes' \
  )
  for key command in ${(@kv)widgets}; do
    eval "fzf-git-$command-widget() { local result=\$(git_$command | join-lines); zle reset-prompt; LBUFFER+=\$result }"
    eval "zle -N fzf-git-$command-widget"
    eval "bindkey '^g^$key' fzf-git-$command-widget"
  done
}

bind-git-helper
