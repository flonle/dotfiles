#!/usr/bin/env bash
# meta scripts

set -euo pipefail

# This is the directory in which you can commit changes to the default release,
# pull updates from upstream, resolve conflicts, etc.
DEV_DIR="${HOME}/dotfiles"

if [[ ! -d "$DEV_DIR" ]]; then
    echo "Could not find directory ${DEV_DIR}, aborting." >&2    
    exit 1
fi

if [[ ! -d "${DEV_DIR}/.git" ]]; then
    echo "${DEV_DIR} is not a Git repository, cowardly refusing." >&2
    exit 1
fi

# All symlinks should point into this directory.
# It can itself be a symlink to DEV_DIR, or a copy of it.
# This is used to 'freeze' the current configuration while working
# in DEV_DIR.
MIRROR_DIR="${HOME}/.dotfiles"

SYMLINKS=(
  "${HOME}/.zshrc:${MIRROR_DIR}/home/.zshrc"
  "${HOME}/.gitconfig:${MIRROR_DIR}/home/.gitconfig"
  "${HOME}/bin:${MIRROR_DIR}/home/bin"
  "${HOME}/wallpapers:${MIRROR_DIR}/home/wallpapers"
  "${HOME}/.config:${MIRROR_DIR}/home/.config"
)


# install/update. SHOULD BE IDEMPOTENT.
bootstrap() {
    if [[ "$EUID" -eq 0 ]]; then
        echo 'Do not run this script as root.' >&2
        return 1
    fi

    thaw  # makes sure $MIRROR_DIR exists first

    set_symlinks "${SYMLINKS[@]}"
    ensure_yay
    echo 'installing packages from pkglist.txt...'
    grep -v -E '^\s*(#.*|$)' "${MIRROR_DIR}/meta/pkglist.txt" | xargs yay -S --needed --noconfirm  # assert all packages
    enable_systemd_services
    set_default_shell
}


# Install yay if not already installed
ensure_yay() {
    echo 'Ensuring yay is installed...'
    command -v yay > /dev/null && return 0  # early exit if yay already installed

    local tmp_dir
    tmp_dir=$(mktemp -d)
    pushd "$tmp_dir" > /dev/null

    sudo pacman -S --needed --noconfirm git base-devel
    git clone https://aur.archlinux.org/yay.git
    pushd yay > /dev/null
    makepkg -si --noconfirm

    popd > /dev/null
    popd > /dev/null
    rm -rf "$tmp_dir"
    echo 'Installed yay'
}


# Set all symlinks in argv. Each arg is a symlink in the form of src:dir.
# If src already exists and is a file, it will be backed up using backup_file().
set_symlinks() {
    echo 'Setting symlinks...'
    local symlinks=("$@")
    for pair in "${symlinks[@]}"; do
        IFS=':' read -r dest src <<< "$pair"

        if [[ -e "$dest" && ! -L "$dest" ]]; then
            # Back up regular file or directory, not symlinks
            backup_file "$dest"
        fi

        ln -sf -- "$src" "$dest"
        echo "Symlinked ${dest} → ${src}"
    done
}


# Backup file/directory by renaming it with an incremental suffix
backup_file() {
    local file="$1"
    local suffix=".backup"
    local dest="${file}${suffix}"
    local n=1

    # Increment suffix if target exists
    while [[ -e "$dest" ]]; do
        dest="${file}${suffix}${n}"
        ((n++))
    done

    mv -- "$file" "$dest"
    echo "Backed up $file → $dest"
}


enable_systemd_services() {
    echo 'Enabling systemd services...'

    sudo systemctl enable --now bluetooth.service
    echo 'Enabled systemd unit bluetooth.service'

    sudo systemctl enable --now reflector.timer
    echo 'Enabled systemd unit reflector.time'

    sudo systemctl enable --now irqbalance.service
    echo 'Enabled systemd unit irqbalance.service'

    sudo systemctl enable --now fstrim.timer
    echo 'Enabled systemd unit fstrim.timer'

    systemctl --user enable --now hypr-watcher.service
    echo 'Enable systemd unit hypr-watcher.service'
}

configure_sysctl() {
    if [[ ! -f '/etc/sysctl.d/99-swappiness.conf' ]]; then
        echo 'vm.swappiness=10' | sudo tee '/etc/sysctl.d/99-swappiness.conf'
        echo 'Set /etc/sysctl.d/99-swappiness.conf'
    else
        echo 'Skipping: /etc/sysctl.d/99-swappiness.conf already exists'
    fi

    if [[ ! -f '/etc/sysctl.d/99-desktop-optimization.conf' ]]; then
        echo 'vm.vfs_cache_pressure=50\nvm.dirty_ratio=10\nvm.dirty_background_ratio=5' | sudo tee '/etc/sysctl.d/99-desktop-optimization.conf'
        echo 'Set /etc/sysctl.d/99-desktop-optimization.conf'
    else
        echo 'Skipping: /etc/sysctl.d/99-desktop-optimization.conf already exists'
    fi
        
    echo 'Reloading systctl settings'
    sudo sysctl --system
}


set_default_shell() {
    chsh -s /bin/zsh "$USER"
    echo "Set default shell for ${USER} to /bin/zsh"
}


# Write a copy of $DEV_DIR to $MIRROR_DIR.
# This allows work in the former to not affect the current system, until thawed.
freeze() {
    sudo rm -rf "$MIRROR_DIR"
    rsync -av --progress --exclude='.git/' "${DEV_DIR}/" "$MIRROR_DIR" --mkpath
}


# Make $MIRROR_DIR a symlink to $DEV_DIR.
# This undoes freeze() and completely overrides $MIRROR_DIR.
thaw() {
    sudo rm -rf "$MIRROR_DIR"
    set_symlinks "${MIRROR_DIR}:${DEV_DIR}"
}


state() {
    if [ -L "$MIRROR_DIR" ]; then
        echo 'Thawed'
    else
        echo 'Frozen'
    fi
}


help() {
  cat <<EOF
Usage: $0 <function> [args...]

Available functions:
$(declare -F | awk '{ printf "  - %s\n", $3 }')
EOF
}


# ----- Dispatcher -----
if [ $# -lt 1 ]; then
  help
  exit 1
fi

cmd="$1"; shift  # shifts position arguments

if declare -F "$cmd" > /dev/null; then
  "$cmd" "$@"
else
  echo "Error: function '${cmd}' not found" >&2
  help
  exit 1
fi
# ------
