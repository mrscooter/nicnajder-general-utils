# shellcheck shell=bash
# Helpers for the component installers; source it with the installer's arguments:
#   source "$SRC/../lib/link.sh" "$@"
# A --check argument switches to report-only mode: nothing is changed, every difference from the
# repo is printed, and finish exits 1 if there was any.

REPO=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)
# Anything in the way goes to backups/<stamp>/ in this checkout (gitignored), under its path relative
# to $HOME. ./install.sh passes one stamp to every component, so a run makes one directory.
BACKUP=$REPO/backups/${INSTALL_STAMP:-$(date +%Y-%m-%d_%H-%M-%S)}
CHECK=0
for a; do
    case $a in
        --check) CHECK=1 ;;
        *) echo "unknown argument: $a (only --check)" >&2; exit 2 ;;
    esac
done
DRIFT=0
CHANGED=0
BACKED_UP=0

problem() { echo "  $*"; DRIFT=1; }
changed() { echo "  $*"; CHANGED=1; }

# real PATH: PATH with its symlinks resolved; a trailing part that doesn't exist is kept as given.
real() {
    local p=$1 tail=
    while [[ ! -d $p ]]; do tail=/$(basename "$p")$tail; p=$(dirname "$p"); done
    echo "$(cd "$p" && pwd -P)$tail"
}

# outside DIR...: stop if any DIR resolves into this checkout (it, or a parent, links to a directory of
# it); installing through it would write among the tracked files. Components call it first with every
# directory they write to.
outside() {
    local d
    for d; do
        [[ $(real "$d")/ == "$REPO"/* ]] && problem "$d: links into this checkout, not touching it"
    done
    (( ! DRIFT )) || finish
}

backup() {
    local dest=$BACKUP/${1#"$HOME"/}
    mkdir -p "$(dirname "$dest")"
    mv "$1" "$dest"
    BACKED_UP=1
    changed "backed up $1 -> $dest"
}

# link FROM TO [confirm]: make TO a symlink to FROM. Anything else at TO (a file, a directory, a link
# elsewhere) is moved to $BACKUP first, never overwritten; with "confirm", only after the user types
# YES.
link() {
    local from=$1 to=$2 confirm=${3:-}
    # -ef also matches a link made through another path to this checkout.
    [[ $to -ef $from ]] && return 0
    if (( CHECK )); then
        if [[ -L $to ]]; then problem "$to: links to $(readlink "$to"), expected $from"
        elif [[ -e $to ]]; then problem "$to: not a link, expected a link to $from"
        else problem "$to: missing, expected a link to $from"; fi
        return 0
    fi
    if [[ -e $to || -L $to ]]; then
        if [[ -n $confirm ]] && ! confirmed "$to" "$from"; then
            problem "$to: left as is; re-run once you have dealt with it"
            return 0
        fi
        backup "$to"
    fi
    mkdir -p "$(dirname "$to")"
    ln -s "$from" "$to"
    changed "$to -> $from"
}

confirmed() {
    local to=$1 from=$2 what answer=
    if [[ -L $to ]]; then what="a link to $(readlink "$to")"
    elif [[ -d $to ]]; then what="a directory"
    else what="a regular file"; fi
    {
        echo
        echo "  ################################################################################"
        echo "  #"
        echo "  #  WARNING: $to already exists, $what."
        echo "  #"
        echo "  #  Replacing it makes it a link to $from."
        echo "  #  Whatever it holds now stops applying. It would be moved to"
        echo "  #  $BACKUP/${to#"$HOME"/}"
        echo "  #"
        echo "  ################################################################################"
        printf '  Type YES to replace it, anything else to leave it as is: '
    } >&2
    read -r answer 2>/dev/null < /dev/tty || echo >&2
    [[ $answer == YES ]]
}

# prune DIR [WHY]: remove links in DIR that point into this checkout at files that no longer exist
# (deleted or renamed in the repo). With WHY, remove every link in DIR that points into the checkout.
prune() {
    local l why=${2:-}
    for l in "$1"/*; do
        [[ -L $l && ( -n $why || ! -e $l ) && $(real "$(readlink "$l")")/ == "$REPO"/* ]] || continue
        if (( CHECK )); then problem "$l: ${why:-stale link}, remove it"
        else rm "$l"; changed "removed $l (${why:-stale link})"; fi
    done
}

finish() {
    (( BACKED_UP )) && echo "  backups in $BACKUP"
    (( DRIFT )) && exit 1
    if (( CHECK )); then echo "  ok"
    elif (( ! CHANGED )); then echo "  up to date"; fi
}
