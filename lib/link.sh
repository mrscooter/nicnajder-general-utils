# Helpers for the component installers; source it with the installer's arguments:
#   source "$SRC/../lib/link.sh" "$@"
# A --check argument switches to report-only mode: nothing is changed, every difference from the
# repo is printed, and finish exits 1 if there was any.

REPO=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
STAMP=$(date +%Y%m%d-%H%M%S)
CHECK=0
[[ ${1:-} == --check ]] && CHECK=1
DRIFT=0
CHANGED=0

problem() { echo "  $*"; DRIFT=1; }
changed() { echo "  $*"; CHANGED=1; }

# link FROM TO [confirm]: make TO a symlink to FROM. A regular file or directory in the way is moved
# to TO.bak-<stamp>, never overwritten. With "confirm", anything already at TO (even a symlink) is
# only replaced after the user types YES.
link() {
    local from=$1 to=$2 confirm=${3:-}
    [[ -L $to && $(readlink "$to") == "$from" ]] && return 0
    if (( CHECK )); then
        if [[ -L $to ]]; then problem "$to: links to $(readlink "$to"), expected $from"
        elif [[ -e $to ]]; then problem "$to: regular file, expected a link to $from"
        else problem "$to: missing, expected a link to $from"; fi
        return 0
    fi
    if [[ -n $confirm && ( -e $to || -L $to ) ]]; then
        if ! confirmed "$to"; then
            changed "$to: left as is"
            return 0
        fi
        mv "$to" "$to.bak-$STAMP"
        changed "backed up $to -> $to.bak-$STAMP"
    elif [[ -e $to && ! -L $to ]]; then
        mv "$to" "$to.bak-$STAMP"
        changed "backed up $to -> $to.bak-$STAMP"
    fi
    mkdir -p "$(dirname "$to")"
    ln -sfn "$from" "$to"
    changed "$to -> $from"
}

confirmed() {
    local answer=
    echo "  WARNING: $1 already exists and would be replaced by a link into this repo." >&2
    echo "  The current one would be kept as $1.bak-$STAMP." >&2
    printf '  Type YES to replace it: ' >&2
    read -r answer 2>/dev/null < /dev/tty || echo >&2
    [[ $answer == YES ]]
}

# prune DIR: remove symlinks in DIR that point into this repo at files that no longer exist
# (deleted or renamed in the repo).
prune() {
    local l
    for l in "$1"/*; do
        [[ -L $l && ! -e $l && $(readlink "$l") == "$REPO"/* ]] || continue
        if (( CHECK )); then problem "$l: stale link to $(readlink "$l")"
        else rm "$l"; changed "removed stale link $l"; fi
    done
}

finish() {
    if (( CHECK )); then
        (( DRIFT )) && exit 1
        echo "  ok"
    elif (( ! CHANGED )); then
        echo "  up to date"
    fi
}
