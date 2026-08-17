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
  if [[ $1 == (-h|--help) ]]; then
    print -l -- \
      'usage: prune' \
      '  fetch --prune, then delete local branches whose upstream is gone' \
      '  skips the current branch and branches checked out in a worktree'
    return 0
  fi
  # fetch prints one line per stale remote-tracking ref; the monolith drops
  # thousands at once, which reads as if local branches were deleted.
  print -n 'fetching… '
  local fetched; fetched=$(git fetch --prune 2>&1); local exit_code=$?
  if (( exit_code )); then
    print; print -u2 -- $fetched; return $exit_code
  fi
  print "pruned $(print -r -- $fetched | grep -c '\[deleted\]') stale remote-tracking refs"

  # '*' marks the current branch and '+' one checked out in a worktree; neither
  # can be deleted, and the marker would otherwise be read as the branch name.
  local listing=$(git branch -vv)
  local -a gone skipped
  gone=(${(f)"$(print -r -- $listing | awk '/: gone\]/ && $1 != "*" && $1 != "+" {print $1}')"})
  skipped=(${(f)"$(print -r -- $listing | awk '/: gone\]/ && ($1 == "*" || $1 == "+") {print $2}')"})

  (( ${#skipped} )) && print -u2 "skipping checked-out branch: ${(j:, :)skipped}"
  (( ${#gone} )) || { print 'nothing to prune'; return 0 }
  git branch -D "${gone[@]}"
}

function colorize() {
  if [[ $1 == (-h|--help) ]]; then
    print -l -- \
      'usage: colorize <color> <command> [args…]' \
      '  run <command>, wrapping its output in the given zsh prompt color'
    return 0
  fi
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
  if [[ $1 == (-h|--help) ]]; then
    print -l -- \
      'usage: meach <command> [-- repo…]' \
      '  run <command> in each subdirectory (default) or only the named ones' \
      "  chain steps with ' + ' (becomes ' && '), e.g. meach pwd + ls -- dirA"
    return 0
  fi
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
  if [[ $1 == (-h|--help) ]]; then
    print -l -- \
      'usage: mgit <git args> [-- repo…]' \
      "  run 'git <git args>' in each repo (default) or only the named ones" \
      "  chain steps with ' + ', e.g. mgit checkout main + pull -- repoA"
    return 0
  fi
  local -a reply MEACH_DIRS extra
  _meach_split "$@"                     # reply = git words, MEACH_DIRS = repos
  local joined="${(j: :)reply}"         # "checkout main + pull"
  (( ${#MEACH_DIRS} )) && extra=(-- "${MEACH_DIRS[@]}")
  meach "git ${joined// + / + git }" "${extra[@]}"  # prefix git onto each + segment
}

function rprune() {
  if [[ $1 == (-h|--help) ]]; then
    print -l -- \
      'usage: rprune [repo…]' \
      '  delete local branches whose upstream is gone, in each repo or only the named ones'
    return 0
  fi
  local -a extra; (( $# )) && extra=(-- "$@")
  meach prune "${extra[@]}"
}

function rmain() {
  if [[ $1 == (-h|--help) ]]; then
    print -l -- \
      'usage: rmain [repo…]' \
      '  check out the main branch and pull in each repo (default) or only the named ones'
    return 0
  fi
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
