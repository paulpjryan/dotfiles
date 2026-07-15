EDITOR="/usr/bin/vim"

SPACESHIP_PROMPT_ORDER=(
  time          # Time stampts section
  dir           # Current directory section
  git           # Git section (git_branch + git_status)
  # node          # Node.js section
  line_sep      # Line break
  jobs          # Background jobs indicator
  exit_code     # Exit code section
  char          # Prompt character
)

SPACESHIP_TIME_SHOW=true
SPACESHIP_USER_SHOW=false
SPACESHIP_HOST_SHOW=false
SPACESHIP_DIR_TRUNC=0
SPACESHIP_DIR_TRUNC_REPO=false
SPACESHIP_GIT_STATUS_COLOR=green
SPACESHIP_GIT_STATUS_SHOW=false

### General Aliases ###
alias c="clear"
alias ..="cd .."
alias reload="source ~/.zshrc"

### Git Functions ###
function prune() {
  git fetch --prune
  git branch -vv | grep ': gone]' | awk '{print $1}' | xargs git branch -D
}

function colorize() {
  local color=$1
  shift
  print -Pn "%F{$color}"
  "$@"
  local exit_code=$?
  print -Pn "%f"
  return $exit_code
}

# Split ARGS at the first '--': words before it are the command (returned in
# `reply`); words after it are the repo restriction (returned in MEACH_DIRS).
# With no '--', every word is command and no restriction is set.
function _meach_split() {
  reply=(); MEACH_DIRS=()
  local after=0 a
  for a in "$@"; do
    if (( after )); then MEACH_DIRS+=("$a")
    elif [[ $a == -- ]]; then after=1
    else reply+=("$a"); fi
  done
}

function meach() {
  local -a reply MEACH_DIRS
  _meach_split "$@"
  local cmd="${(j: :)reply}"  # join command words into one string
  cmd="${cmd// + / && }"      # translate ' + ' into ' && '
  local dirs=(*(/))           # default: every subdirectory
  (( ${#MEACH_DIRS} )) && dirs=("${MEACH_DIRS[@]}")  # '-- repo…' restricts the set
  for d in $dirs; do
    (
      cd "$d" || exit
      colorize 13 pwd && eval "$cmd"
    )
  done
}

function mgit() {
  local -a reply MEACH_DIRS extra
  _meach_split "$@"                     # reply = git words, MEACH_DIRS = repos
  local joined="${(j: :)reply}"         # "checkout main + pull"
  (( ${#MEACH_DIRS} )) && extra=(-- "${MEACH_DIRS[@]}")
  meach "git ${joined// + / + git }" "${extra[@]}"  # prefix git onto each + segment
}

function rprune() {
  local -a extra; (( $# )) && extra=(-- "$@")
  meach prune "${extra[@]}"
}

function rmain() {
  local -a extra; (( $# )) && extra=(-- "$@")  # no args → all repos; else only these
  meach 'git checkout "$(git_main_branch)" && git pull' "${extra[@]}"
}

# Repo-name generators: git repos (subdirs holding a .git) vs. any subdir.
function _meach_git_repos() { compadd -- */.git(N:h); }
function _meach_all_dirs()  { compadd -- *(/N:t); }

# rmain/rprune take repos positionally; mgit/meach take them only after a '--'.
function _meach_after_sep() {          # $1 = generator to use once past '--'
  local sep=${words[(I)--]}           # index of last '--', 0 if none
  if (( sep > 0 && sep < CURRENT )); then $1; else _default; fi
}
function _mgit_comp()  { _meach_after_sep _meach_git_repos; }
function _meach_comp() { _meach_after_sep _meach_all_dirs; }

compdef _meach_git_repos rmain rprune  # git repos only
compdef _mgit_comp mgit                # git repos, after '--'
compdef _meach_comp meach              # any subdir, after '--'

### Git Aliases ###
alias rebase="git pull origin main --rebase"
alias {fpush,gpf}="git push --force-with-lease"
alias gcmp="git checkout \$(git_main_branch) && git pull"
