# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'

# ---------------------------------------------------------
# ⌨️  Shell behavior
# ---------------------------------------------------------

# Disable history expansion. Bash otherwise treats a leading `!` as "rerun the
# last command starting with ...", which silently rewrites pasted commands and
# also mangles `!` inside double quotes (git commit -m "fixed!").
# Trade-off: `!!` and `!$` stop working. Use Alt+. for the previous argument
# (readline, unaffected) and `sudo $(fc -ln -1)` to re-run the last command.
set +H

# ---------------------------------------------------------
# ☁️  AWS
# ---------------------------------------------------------

export AWS_PROFILE=shiptrac-austin
export AWS_SDK_LOAD_CONFIG=1

# ---------------------------------------------------------
# 🔧  direnv
# ---------------------------------------------------------

# Guarded so the shell still works on a machine without direnv installed
command -v direnv &>/dev/null && eval "$(direnv hook bash)"

# ---------------------------------------------------------
# 💻  Functions
# ---------------------------------------------------------

# Delete local branches whose remote tracking branch is gone
git-unload() {
  echo -e "\e[33m\e[0m Unloading dead branches..."
  git fetch -p && git branch -vv | grep ": gone]" | awk '{print $1}' | xargs -r git branch -D
}

# Refresh the git index so .gitignore updates take effect on tracked files
git-reindex() {
  git rm -r --cached . >/dev/null 2>&1
  git add -A
  git status --short
  echo "📋 Manifest updated. Ignored files have been offloaded!"
}

secret() {
  echo -e "\e[33m\e[0m Generating secret..."
  openssl rand -base64 32
}
