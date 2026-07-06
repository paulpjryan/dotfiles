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

function meach() {
  for d in *(/); do
    (
      cd "$d" || exit
      colorize 13 pwd && eval "$@"
    )
  done
}

function mgit() { meach "git $*"; }

function rprune() { meach prune; }

function rmain() { meach 'git checkout "$(git_main_branch)" && git pull'; }

### Git Aliases ###
alias rebase="git pull origin main --rebase"
alias {fpush,gpf}="git push --force-with-lease"
alias gcmp="git checkout \$(git_main_branch) && git pull"
