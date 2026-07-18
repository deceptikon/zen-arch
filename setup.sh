#!/usr/bin/env bash
# Dotfiles Install/Uninstall Manager
set -uo pipefail

DOT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"
LOG_FILE="$DOT_ROOT/dotfiles.log"

log() {
    local msg="$(date '+%Y-%m-%d %H:%M:%S') | $*"
    echo "$msg"
    echo "$msg" >> "$LOG_FILE"
}

log_err() {
    local msg="$(date '+%Y-%m-%d %H:%M:%S') | ERROR | $*"
    echo -e "\033[31m$msg\033[0m" >&2
    echo "$msg" >> "$LOG_FILE"
}

# --- PREREQUISITES ---
check_prereqs() {
    log "Checking prerequisites..."
    local deps=(
        "sway" "waybar" "rofi" "dunst" "wezterm" "micro" "ranger" "mc" "zsh" "jq"
        "swayidle" "swaynag" "wob" "yad" "nm-applet:network-manager-applet" 
        "nm-connection-editor" "udiskie" "pamixer" "pactl:pulseaudio-utils" 
        "playerctl" "pavucontrol" "brightnessctl" "ddcutil" "grim" "slurp" 
        "wl-copy:wl-clipboard" "thunar" "Telegram:telegram-desktop" "firefox" "galculator" "qt5ct"
    )
    local missing=()
    for dep in "${deps[@]}"; do
        local cmd="${dep%%:*}"
        local pkg="${dep##*:}"
        if ! command -v "$cmd" >/tmp/check_$cmd.out 2>>"$LOG_FILE"; then
            missing+=("$pkg")
        fi
    done
    if [[ ${#missing[@]} -gt 0 ]]; then
        log_err "Missing packages: ${missing[*]}"
        return 1
    fi
    log "All Arch prerequisites met."
    return 0
}

# --- LINKING ENGINE ---
link_item() {
    local src_path="$1"
    local dest_dir="$2"
    local item_name="$(basename "$src_path")"
    local dest_path="$dest_dir/$item_name"

    mkdir -p "$dest_dir"

    if [[ -L "$dest_path" && "$(readlink "$dest_path")" == "$src_path" ]]; then
        log "Already linked: $dest_path"
        return 0
    fi

    if [[ -e "$dest_path" || -L "$dest_path" ]]; then
        mkdir -p "$BACKUP_DIR"
        log "Backing up $dest_path to $BACKUP_DIR/"
        mv "$dest_path" "$BACKUP_DIR/" >> "$LOG_FILE" 2>&1 || log_err "Failed backup: $dest_path"
    fi

    log "Linking: $dest_path -> $src_path"
    ln -sn "$src_path" "$dest_path" >> "$LOG_FILE" 2>&1 || log_err "Failed linking: $dest_path"
}

unlink_item() {
    local src_path="$1"
    local dest_dir="$2"
    local item_name="$(basename "$src_path")"
    local dest_path="$dest_dir/$item_name"

    if [[ -L "$dest_path" && "$(readlink "$dest_path")" == "$src_path" ]]; then
        log "Unlinking: $dest_path"
        rm "$dest_path" >> "$LOG_FILE" 2>&1
        
        # Basic restore logic
        local latest_bkp=$(ls -td "$HOME/.dotfiles_backup"/*/"$item_name" 2>>"$LOG_FILE" | head -n 1 || true)
        if [[ -n "$latest_bkp" && -e "$latest_bkp" ]]; then
            log "Restoring: $latest_bkp -> $dest_path"
            mv "$latest_bkp" "$dest_path" >> "$LOG_FILE" 2>&1
        fi
    fi
}

process_all() {
    local action="$1" # "link" or "unlink"
    
    # 1. Process dynamic directories (dot_*)
    for src_dir in "$DOT_ROOT"/dot_*; do
        [[ -d "$src_dir" ]] || continue
        
        # Translate 'dot_local_bin' -> '.local/bin'
        local rel_path="$(basename "$src_dir" | sed 's/^dot_/./; s/_/\//g')"
        local dest_dir="$HOME/$rel_path"
        
        for src_path in "$src_dir"/*; do
            [[ -e "$src_path" ]] || continue
            if [[ "$action" == "link" ]]; then
                link_item "$src_path" "$dest_dir"
            else
                unlink_item "$src_path" "$dest_dir"
            fi
        done
    done

    # 2. Process root files starting with a dot (e.g., .zshenv, .zshenv.secrets)
    for src_path in "$DOT_ROOT"/.*; do
        [[ -f "$src_path" ]] || continue
        local item_name="$(basename "$src_path")"
        # Skip git config & current/parent dir references
        if [[ "$item_name" =~ ^\.git || "$item_name" == "." || "$item_name" == ".." ]]; then
            continue
        fi
        
        if [[ "$action" == "link" ]]; then
            link_item "$src_path" "$HOME"
        else
            unlink_item "$src_path" "$HOME"
        fi
    done
}

# --- LIFECYCLE ---
reload_services() {
    log "Reloading services..."
    if pgrep -x sway >> "$LOG_FILE" 2>&1; then
        log "Issuing Sway reload..."
        swaymsg reload >> "$LOG_FILE" 2>&1 || log_err "Sway reload failed"
    else
        log "Sway is not running right now."
    fi
}

# --- MAIN ---
case "${1:-help}" in
    check)
        check_prereqs
        ;;
    install)
        log "=== STARTING INSTALL ==="
        check_prereqs || log_err "Prereqs missing, installing anyway..."
        process_all "link"
        reload_services
        log "=== INSTALL COMPLETE ==="
        ;;
    uninstall)
        log "=== STARTING UNINSTALL ==="
        process_all "unlink"
        log "=== UNINSTALL COMPLETE ==="
        ;;
    *)
        echo "Usage: $0 [check|install|uninstall]"
        exit 1
        ;;
esac
