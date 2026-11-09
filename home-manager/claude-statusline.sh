# Status line styled after ~/.config/starship.toml (gruvbox_dark palette)
input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Directory: home -> ~, keep last 3 components (truncation_length = 3)
dir="${cwd/#"$HOME"/\~}"
IFS='/' read -ra parts <<< "$dir"
if [ "${#parts[@]}" -gt 3 ]; then
  dir="…/${parts[*]: -3:1}/${parts[*]: -2:1}/${parts[*]: -1:1}"
fi

# Git branch, or short hash when detached. Skips optional locks so it never
# contends with a git command running in the same repo. `|| true` because
# writeShellApplication runs under errexit and most dirs aren't repos.
branch=""
if [ -n "$cwd" ]; then
  branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short -q HEAD 2>/dev/null \
    || git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null) || true
fi

# Gruvbox colors: bright-blue #83a598, bg3 #665c54, purple #b16286, yellow #d79921
c() { printf '\033[38;2;%sm' "$1"; }
reset='\033[0m'

printf "$(c '131;165;152')%s$reset" "$dir"
[ -n "$branch" ] && printf " $(c '168;153;132') %s$reset" "$branch"
[ -n "$model" ] && printf " $(c '177;98;134')[%s]$reset" "$model"
if [ -n "$used" ]; then
  printf " $(c '215;153;33')ctx %.0f%%$reset" "$used"
fi
printf '\n'
