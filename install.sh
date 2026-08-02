#!/usr/bin/env bash

# ==============================================================================
# Noctara-Dots Installer 
# Target: Arch Linux (Noctalia Rice)
# Repo: https://github.com/deadduck-09/Noctara-Dots
# ==============================================================================

# Paranoia mode: Fail fast on errors, unset variables, and pipeline breaks
set -euo pipefail
IFS=$'\n\t'

# --- Stopwatch start ---
START_TIME=$(date +%s)
readonly START_TIME

# --- The constants we don't want to mess up ---
readonly VERSION="3.2.0"
readonly AUTHOR="Gigi"
readonly LOG_DIR="$HOME/.cache/noctara-dots"
readonly LOG_FILE="$LOG_DIR/install.log"
TIMESTAMP=$(date +%Y-%m-%d-%H%M%S)
readonly TIMESTAMP
readonly BACKUP_DIR="$HOME/.config-backup-$TIMESTAMP"

# --- Pretty terminal colors ---
readonly NC='\033[0m'
readonly BOLD='\033[1m'
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'

# --- Order matters for these guys ---
readonly PREFERRED_ORDER=(
    "niri"
    "noctalia"
    "kitty"
    "waybar"
    "mpd"
    "mpv"
    "fastfetch"
    "yazi"
    "rmpc"
)

# --- Mapping commands to their actual package names ---
declare -A BINARY_MAP=(
    ["nvim"]="nvim"
    ["kitty"]="kitty"
    ["waybar"]="waybar"
    ["fastfetch"]="fastfetch"
    ["mpv"]="mpv"
    ["mpd"]="mpd"
    ["niri"]="niri"
    ["noctalia"]="noctalia"
    ["rmpc"]="rmpc"
    ["yazi"]="yazi"
)

declare -A PACKAGE_MAP=(
    ["nvim"]="neovim"
    ["kitty"]="kitty"
    ["waybar"]="waybar"
    ["fastfetch"]="fastfetch"
    ["mpv"]="mpv"
    ["mpd"]="mpd"
    ["niri"]="niri"
    ["noctalia"]="noctalia-git"
    ["rmpc"]="rmpc"
    ["yazi"]="yazi"
)

# --- Keep track of what actually happened ---
CURRENT_STEP=0
TOTAL_STEPS=10

INSTALLED_CONFIGS=()
SKIPPED_CONFIGS=()
FAILED_CONFIGS=()
INSTALLED_PACKAGES=()
ALREADY_PRESENT_PACKAGES=()
FAILED_PACKAGES=()

DRY_RUN=false
HAS_INTERNET=true

# ==============================================================================
# 1. Boring setup stuff (Logs & error handling)
# ==============================================================================

mkdir -p "$LOG_DIR"
echo "=== Noctara Installer woke up at $(date) ===" > "$LOG_FILE"

log_to_file() {
    local level="$1"
    local msg="$2"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [$level] $msg" >> "$LOG_FILE"
}

cleanup_handler() {
    local exit_code=$?
    if [ "$exit_code" -ne 0 ]; then
        echo -e "\n\n${RED}${BOLD}❌ Whoops! Script died a horrible death. Autopsy report here: $LOG_FILE${NC}" >&2
        log_to_file "FATAL" "Script crashed and burned."
    fi
    exit "$exit_code"
}
trap cleanup_handler EXIT
trap 'exit 130' SIGINT SIGTERM

# ==============================================================================
# 2. UI / Making things look nice
# ==============================================================================

print_banner() {
    clear
    echo -e "${PURPLE}"
    echo '███╗   ██╗ ██████╗  ██████╗████████╗ █████╗ ██████╗  █████╗ '
    echo '████╗  ██║██╔═══██╗██╔════╝╚══██╔══╝██╔══██╗██╔══██╗██╔══██╗'
    echo '██╔██╗ ██║██║   ██║██║        ██║   ███████║██████╔╝███████║'
    echo '██║╚██╗██║██║   ██║██║        ██║   ██╔══██║██╔══██╗██╔══██║'
    echo '██║ ╚████║╚██████╔╝╚██████╗   ██║   ██║  ██║██║  ██║██║  ██║'
    echo '╚═╝  ╚═══╝ ╚═════╝  ╚═════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝'
    echo -e "${NC}"
    echo -e "  ${BOLD}Version:${NC} ${YELLOW}$VERSION${NC} | ${BOLD}Chef:${NC} ${YELLOW}$AUTHOR${NC} | ${BOLD}Log:${NC} ${BLUE}$LOG_FILE${NC}"
    echo -e "───────────────────────────────────────────────────────────────────\n"
}

render_progress() {
    local percent=$1
    local width=30
    local filled=$(( percent * width / 100 ))
    local empty=$(( width - filled ))
    
    printf "  Progress: [" >&2
    if [ "$filled" -gt 0 ]; then
        printf "%${filled}s" "" | tr ' ' '█' >&2
    fi
    if [ "$empty" -gt 0 ]; then
        printf "%${empty}s" "" | tr ' ' '░' >&2
    fi
    printf "] %d%%\n\n" "$percent" >&2
}

log_step() {
    ((++CURRENT_STEP))
    local title="$1"
    local pct=$(( (CURRENT_STEP * 100) / TOTAL_STEPS ))
    
    echo -e "\n${BLUE}${BOLD}───────────────────────────────────────────────────────────────────${NC}" >&2
    echo -e "${BLUE}${BOLD}[$CURRENT_STEP/$TOTAL_STEPS] $title${NC}" >&2
    echo -e "${BLUE}${BOLD}───────────────────────────────────────────────────────────────────${NC}" >&2
    render_progress "$pct"
    log_to_file "STEP" "Now doing: $title"
}

log_success() { echo -e "  ${GREEN}✔${NC} $1" >&2; log_to_file "SUCCESS" "$1"; }
log_fail()    { echo -e "  ${RED}❌${NC} $1" >&2; log_to_file "ERROR" "$1"; }
log_info()    { echo -e "  ${CYAN}ℹ${NC} $1" >&2; log_to_file "INFO" "$1"; }
log_warn()    { echo -e "  ${YELLOW}⚠${NC} $1" >&2; log_to_file "WARN" "$1"; }

# ==============================================================================
# 3. Environment & Sanity Checks
# ==============================================================================

verify_environment() {
    if [ ! -d "configs" ]; then
        log_fail "Where are you? Run this script from inside the git repository."
        exit 1
    fi
    if [ ! -f /etc/arch-release ]; then
        log_fail "No Arch? No rice. We need Arch Linux for this to work."
        exit 1
    fi
}

probe_network() {
    log_to_file "NETWORK" "Pinging the outside world..."
    if { true > "/dev/tcp/1.1.1.1/53"; } &>/dev/null || \
       { true > "/dev/tcp/8.8.8.8/53"; } &>/dev/null; then
        HAS_INTERNET=true
        log_to_file "NETWORK" "We have internet!"
    else
        HAS_INTERNET=false
        log_to_file "NETWORK" "You're offline. Some stuff is gonna fail."
    fi
}

get_discovered_modules() {
    local dynamic_modules=()
    local ordered_item
    
    for ordered_item in "${PREFERRED_ORDER[@]}"; do
        if [ -d "configs/$ordered_item" ]; then
            dynamic_modules+=("$ordered_item")
        fi
    done
    
    if [ -d "configs" ]; then
        local entry
        for entry in configs/*; do
            if [ -d "$entry" ]; then
                local base_entry="${entry##*/}"
                local is_known=false
                local known_item
                for known_item in "${dynamic_modules[@]}"; do
                    if [[ "$known_item" == "$base_entry" ]]; then
                        is_known=true
                        break
                    fi
                done
                if ! $is_known; then
                    dynamic_modules+=("$base_entry")
                fi
            fi
        done
    fi
    printf '%s\n' "${dynamic_modules[@]}"
}

install_aur_helper() {
    log_info "No AUR helper found. Attempting to install 'yay' automatically..."
    
    if $DRY_RUN; then
        log_info "Dry Run: Would install git, base-devel, and build yay."
        return 0
    fi

    if ! $HAS_INTERNET; then
        log_fail "No internet connection. Cannot install an AUR helper."
        return 1
    fi

    log_info "Installing build dependencies (git, base-devel)..."
    if ! sudo pacman -S --needed --noconfirm git base-devel 2>>"$LOG_FILE"; then
        log_fail "Failed to install base-devel and git via pacman."
        return 1
    fi

    local build_dir
    build_dir=$(mktemp -d)
    log_info "Cloning yay-bin into temporary directory..."

    if git clone https://aur.archlinux.org/yay-bin.git "$build_dir" >>"$LOG_FILE" 2>&1; then
        log_info "Building and installing yay..."
        
        if (cd "$build_dir" && makepkg -si --noconfirm) >>"$LOG_FILE" 2>&1; then
            rm -rf "$build_dir"
            log_success "'yay' installed successfully!"
            INSTALLED_PACKAGES+=("yay")
            return 0
        else
            rm -rf "$build_dir"
            log_fail "Failed to build 'yay' from source."
            return 1
        fi
    else
        rm -rf "$build_dir"
        log_fail "Failed to clone yay-bin repository from AUR."
        return 1
    fi
}

get_system_aur_helper() {
    if command -v yay &>/dev/null; then
        echo "yay"
    elif command -v paru &>/dev/null; then
        echo "paru"
    else
        if install_aur_helper; then
            echo "yay"
        else
            echo ""
        fi
    fi
}

# ==============================================================================
# 4. The actual heavy lifting
# ==============================================================================

phase_validate_env() {
    log_step "Checking Window Manager"
    if ! command -v niri &>/dev/null && ! command -v hyprland &>/dev/null; then
        log_warn "Neither Niri nor Hyprland was detected on your system. You sure about this?"
    elif command -v hyprland &>/dev/null && command -v niri &>/dev/null; then
        log_success "Both Hyprland and Niri detected! We are good to go."
    elif command -v hyprland &>/dev/null; then
        log_success "Hyprland detected. We are good to go."
    else
        log_success "Niri detected. We are good to go."
    fi
}

phase_build_noctalia() {
    log_step "Checking for Noctalia Shell"
    if command -v noctalia &>/dev/null; then
        log_success "Noctalia is already chilling on your system."
        ALREADY_PRESENT_PACKAGES+=("noctalia-git")
        return
    fi

    log_warn "Noctalia shell is missing. Time to bother the AUR..."
    if $DRY_RUN; then log_info "Dry Run: Skipping the Noctalia build."; return; fi
    if ! $HAS_INTERNET; then
        log_fail "No internet? Can't build Noctalia then. Aborting."
        exit 1
    fi

    local helper
    helper=$(get_system_aur_helper)
    if [ -z "$helper" ]; then
        log_fail "Failed to find or install an AUR helper (yay/paru). Aborting."
        exit 1
    fi

    log_info "Telling $helper to go fetch noctalia-git..."
    if "$helper" -S --needed --noconfirm noctalia-git 2>>"$LOG_FILE"; then
        log_success "Noctalia installed perfectly."
        INSTALLED_PACKAGES+=("noctalia-git")
    else
        log_fail "The AUR hated that. Noctalia install failed."
        exit 1
    fi
}

phase_system_refresh() {
    log_step "Updating Your System"
    if $DRY_RUN; then log_info "Dry Run: Skipping system updates."; return; fi
    if ! $HAS_INTERNET; then
        log_warn "You're offline. Skipping pacman updates."
        return
    fi

    read -rp "  Wanna run a quick pacman upgrade first? [Y/n]: " choice
    choice=${choice:-Y}
    if [[ "$choice" =~ ^[Yy]$ ]]; then
        log_info "Unleashing pacman..."
        if sudo pacman -Syu --noconfirm; then
            log_success "System is fresh and clean."
        else
            log_fail "Pacman tripped over something. Fix your mirrors maybe?"
            exit 1
        fi
    else
        log_info "Living dangerously. Skipping system update."
    fi
}

phase_inspect_dependencies() {
    log_step "Checking Your Installed Toys"
    local modules
    mapfile -t modules < <(get_discovered_modules)
    
    local mod
    for mod in "${modules[@]}"; do
        local check_cmd="${BINARY_MAP[$mod]:-"$mod"}"
        local target_pkg="${PACKAGE_MAP[$mod]:-"$mod"}"
        
        if command -v "$check_cmd" &>/dev/null; then
            log_success "Found: $mod"
            ALREADY_PRESENT_PACKAGES+=("$target_pkg")
        else
            log_warn "Missing: $mod (Needs package: $target_pkg)"
        fi
    done
}

phase_resolve_dependencies() {
    log_step "Installing The Missing Stuff"
    if $DRY_RUN; then log_info "Dry Run: Not installing anything today."; return; fi
    if ! $HAS_INTERNET; then
        log_warn "No internet, no packages. Skipping."
        return
    fi

    local modules
    mapfile -t modules < <(get_discovered_modules)
    local missing_pkgs=()

    local mod
    for mod in "${modules[@]}"; do
        local check_cmd="${BINARY_MAP[$mod]:-"$mod"}"
        local target_pkg="${PACKAGE_MAP[$mod]:-"$mod"}"
        
        if ! command -v "$check_cmd" &>/dev/null; then
            missing_pkgs+=("$target_pkg")
        fi
    done

    if [ ${#missing_pkgs[@]} -eq 0 ]; then
        log_success "You already have everything installed. Nice."
        return
    fi

    echo -e "  You're missing these packages: ${YELLOW}${missing_pkgs[*]}${NC}"
    read -rp "  Install them now? [Y/n]: " choice
    choice=${choice:-Y}

    if [[ ! "$choice" =~ ^[Yy]$ ]]; then
        log_warn "Skipped package installs. Stuff might look broken later."
        return
    fi

    local helper
    helper=$(get_system_aur_helper)

    local pkg
    for pkg in "${missing_pkgs[@]}"; do
        log_info "Grabbin': $pkg"
        if sudo pacman -S --needed --noconfirm "$pkg" 2>>"$LOG_FILE"; then
            log_success "Got it from official repos: $pkg"
            INSTALLED_PACKAGES+=("$pkg")
        else
            if [ -n "$helper" ]; then
                log_info "Not in pacman. Let's ask $helper to find it..."
                if "$helper" -S --needed --noconfirm "$pkg" 2>>"$LOG_FILE"; then
                    log_success "Got it from AUR: $pkg"
                    INSTALLED_PACKAGES+=("$pkg")
                    continue
                fi
            fi
            log_fail "Could not install $pkg. You might have to do it yourself."
            FAILED_PACKAGES+=("$pkg")
        fi
    done
}

phase_execute_backup() {
    log_step "Backing Up Your Old Junk"
    if $DRY_RUN; then log_info "Dry Run: Not touching your files."; return; fi

    local modules
    mapfile -t modules < <(get_discovered_modules)
    local verified_backups=()

    local mod
    for mod in "${modules[@]}"; do
        if [ -e "$HOME/.config/$mod" ]; then
            verified_backups+=("config/$mod")
        fi
    done

    if [ -d "local" ] && [ -e "$HOME/.local" ]; then
        verified_backups+=("local")
    fi

    if [ -d "Pictures" ] && [ -e "$HOME/Pictures" ]; then
        verified_backups+=("Pictures")
    fi

    if [ ${#verified_backups[@]} -eq 0 ]; then
        log_info "No old configs or assets found to backup. Nothing to do here."
        return
    fi

    if ! mkdir -p "$BACKUP_DIR" 2>>"$LOG_FILE"; then
        log_fail "Failed to create the backup folder. That's not great."
        exit 1
    fi

    local target
    for target in "${verified_backups[@]}"; do
        if [[ "$target" == config/* ]]; then
            local folder="${target#config/}"
            mkdir -p "$BACKUP_DIR/.config"
            if cp -a "$HOME/.config/$folder" "$BACKUP_DIR/.config/" 2>>"$LOG_FILE"; then
                log_success "Stashed your old ~/.config/$folder away safely."
            else
                log_fail "Failed to backup config/$folder. Watch out."
            fi
        elif [ "$target" == "local" ]; then
            if cp -a "$HOME/.local" "$BACKUP_DIR/.local" 2>>"$LOG_FILE"; then
                log_success "Stashed your old ~/.local away safely."
            else
                log_fail "Failed to backup ~/.local."
            fi
        elif [ "$target" == "Pictures" ]; then
            if cp -a "$HOME/Pictures" "$BACKUP_DIR/Pictures" 2>>"$LOG_FILE"; then
                log_success "Stashed your old ~/Pictures away safely."
            else
                log_fail "Failed to backup ~/Pictures."
            fi
        fi
    done
}

phase_deploy_configs() {
    local interactive=$1
    log_step "Deploying The Rice 🍚"
    
    local modules
    mapfile -t modules < <(get_discovered_modules)
    
    if [ ! -d "$HOME/.config" ] && ! $DRY_RUN; then
        mkdir -p "$HOME/.config" 2>>"$LOG_FILE"
    fi

    local mod
    for mod in "${modules[@]}"; do
        if [[ "$mod" == "hypr" ]] && ! command -v hyprland &>/dev/null; then
            log_warn "Hyprland not detected on system. Skipping 'hypr' config."
            SKIPPED_CONFIGS+=("hypr")
            continue
        fi

        if [[ "$mod" == "niri" ]] && ! command -v niri &>/dev/null; then
            log_warn "Niri not detected on system. Skipping 'niri' config."
            SKIPPED_CONFIGS+=("niri")
            continue
        fi

        local action=true
        if $interactive; then
            read -rp "  Install configs for [${mod}]? [Y/n]: " choice
            choice=${choice:-Y}
            [[ ! "$choice" =~ ^[Yy]$ ]] && action=false
        fi

        if $action; then
            if $DRY_RUN; then
                log_info "Dry Run: Would have installed: $mod"
                INSTALLED_CONFIGS+=("$mod")
            else
                local tmp_dest="$HOME/.config/.$mod.tmp.$TIMESTAMP"
                local final_dest="$HOME/.config/$mod"
                
                rm -rf "$tmp_dest"
                if cp -r "configs/$mod" "$tmp_dest" 2>>"$LOG_FILE"; then
                    if [ -e "$final_dest" ]; then
                        rm -rf "$final_dest" 2>>"$LOG_FILE"
                    fi
                    if mv "$tmp_dest" "$final_dest" 2>>"$LOG_FILE"; then
                        log_success "Riced out: $mod"
                        INSTALLED_CONFIGS+=("$mod")
                    else
                        log_fail "Failed moving config folder for: $mod"
                        FAILED_CONFIGS+=("$mod")
                    fi
                else
                    log_fail "Failed copying configs for: $mod"
                    FAILED_CONFIGS+=("$mod")
                    rm -rf "$tmp_dest"
                fi
            fi
        else
            log_warn "Skipped: $mod"
            SKIPPED_CONFIGS+=("$mod")
        fi
    done

    if [ -d "local" ]; then
        log_info "Deploying local folder to ~/.local..."
        if ! $DRY_RUN; then
            mkdir -p "$HOME/.local" 2>>"$LOG_FILE"
            if cp -a local/. "$HOME/.local/" 2>>"$LOG_FILE"; then
                log_success "Copied local/ -> ~/.local/"
            else
                log_fail "Failed to copy local folder contents."
            fi
        else
            log_info "Dry Run: Would copy local/ -> ~/.local/"
        fi
    fi

    if [ -d "Pictures" ]; then
        log_info "Deploying Pictures folder to ~/Pictures..."
        if ! $DRY_RUN; then
            mkdir -p "$HOME/Pictures" 2>>"$LOG_FILE"
            if cp -a Pictures/. "$HOME/Pictures/" 2>>"$LOG_FILE"; then
                log_success "Copied Pictures/ -> ~/Pictures/"
            else
                log_fail "Failed to copy Pictures folder contents."
            fi
        else
            log_info "Dry Run: Would copy Pictures/ -> ~/Pictures/"
        fi
    fi
}

# ==============================================================================
# 5. The Shell Makeover
# ==============================================================================

phase_install_shell_config() {
    log_step "Terminal Makeover Time"
    
    echo -e "  ${BOLD}Pick your poison for the shell:${NC}"
    echo -e "  ${GREEN}[1]${NC} Zsh + Powerlevel10k (The Classic)"
    echo -e "  ${GREEN}[2]${NC} Fish + Starship (The Modern)"
    echo -e "  ${YELLOW}[3]${NC} Nah, leave my shell alone"
    echo -e "───────────────────────────────────────────────────────────────────${NC}"
    read -rp "Selection [1-3]: " shell_choice

    if [[ "$shell_choice" == "3" ]]; then
        log_info "Alright, keeping your shell exactly as it is."
        return
    fi

    if $DRY_RUN; then
        log_info "Dry Run: Not messing with your shell configs today."
        return
    fi

    local helper
    helper=$(get_system_aur_helper)

    if [[ "$shell_choice" == "1" ]]; then
        log_info "Setting up Zsh..."
        local zsh_deps=("zsh" "git" "curl")
        local dep
        for dep in "${zsh_deps[@]}"; do
            if ! command -v "$dep" &>/dev/null; then
                log_info "Installing missing thing: $dep"
                sudo pacman -S --needed --noconfirm "$dep" 2>>"$LOG_FILE" || "$helper" -S --needed --noconfirm "$dep" 2>>"$LOG_FILE"
            fi
        done

        if [ ! -d "$HOME/.oh-my-zsh" ]; then
            log_info "Grabbing Oh My Zsh..."
            if ! $HAS_INTERNET; then log_fail "No internet. Can't download OMZ."; exit 1; fi
            curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh > "$LOG_DIR/omz-install.sh"
            sh "$LOG_DIR/omz-install.sh" --unattended --keep-zshrc >>"$LOG_FILE" 2>&1
        fi

        local p10k_dest="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
        if [ ! -d "$p10k_dest" ]; then
            log_info "Cloning Powerlevel10k..."
            git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dest" >>"$LOG_FILE" 2>&1
        fi

        local plugins=("zsh-autosuggestions" "zsh-syntax-highlighting")
        declare -A urls=(
            ["zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions"
            ["zsh-syntax-highlighting"]="https://github.com/zsh-users/zsh-syntax-highlighting"
        )
        for pl in "${plugins[@]}"; do
            if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/$pl" ]; then
                log_info "Cloning plugin: $pl"
                git clone --depth=1 "${urls[$pl]}" "$HOME/.oh-my-zsh/custom/plugins/$pl" >>"$LOG_FILE" 2>&1
            fi
        done

        local f
        for f in ".zshrc" ".p10k.zsh"; do
            if [ -f "$HOME/$f" ]; then mv "$HOME/$f" "$HOME/$f.backup" 2>>"$LOG_FILE"; fi
            if [ -f "home/$f" ]; then 
                cp -f "home/$f" "$HOME/$f"
                log_success "Applied: ~/$f"
            fi
        done

        local target_shell
        target_shell=$(command -v zsh 2>/dev/null || echo "/usr/bin/zsh")
        log_info "Changing default shell to Zsh..."
        sudo chsh -s "$target_shell" "$USER" </dev/null >>"$LOG_FILE" 2>&1 || true

    elif [[ "$shell_choice" == "2" ]]; then
        log_info "Setting up Fish + Starship..."
        local fish_deps=("fish" "starship")
        local dep
        for dep in "${fish_deps[@]}"; do
            if ! command -v "$dep" &>/dev/null; then
                log_info "Installing missing thing: $dep"
                sudo pacman -S --needed --noconfirm "$dep" 2>>"$LOG_FILE" || "$helper" -S --needed --noconfirm "$dep" 2>>"$LOG_FILE"
            fi
        done

        if [ -d "configs/fish" ]; then
            log_info "Dropping in the Fish configs..."
            rm -rf "$HOME/.config/fish"
            cp -r configs/fish "$HOME/.config/" 2>>"$LOG_FILE"
            log_success "Fish is ready."
        fi

        if [ -f "configs/starship.toml" ]; then
            log_info "Setting up Starship prompt..."
            cp -f configs/starship.toml "$HOME/.config/starship.toml" 2>>"$LOG_FILE"
            log_success "Starship is ready."
        fi

        local target_shell
        target_shell=$(command -v fish 2>/dev/null || echo "/usr/bin/fish")
        log_info "Changing default shell to Fish..."
        sudo chsh -s "$target_shell" "$USER" </dev/null >>"$LOG_FILE" 2>&1 || true
    else
        log_fail "That wasn't one of the options..."
        exit 1
    fi

    log_success "Shell setup is officially done."
}

phase_signal_environments() {
    log_step "Telling Apps to Refresh"
    if $DRY_RUN; then log_info "Dry Run: Skipping live app reloads."; return; fi

    if pgrep -x "kitty" &>/dev/null; then
        killall -USR1 kitty 2>/dev/null && log_success "Told Kitty to reload." || true
    fi
    if pgrep -x "waybar" &>/dev/null; then
        killall -SIGUSR2 waybar 2>/dev/null && log_success "Told Waybar to reload." || true
    fi
}

phase_compile_summary() {
    log_step "How'd We Do?"
    local end_time
    end_time=$(date +%s)
    local elapsed=$((end_time - START_TIME))
    
    echo -e "  ${BOLD}✓ We installed:${NC}        ${GREEN}${INSTALLED_PACKAGES[*]:-Nothing}${NC}"
    echo -e "  ${BOLD}✓ You already had:${NC}     ${CYAN}${ALREADY_PRESENT_PACKAGES[*]:-Nothing}${NC}"
    echo -e "  ${BOLD}✓ Failed Installs:${NC}     ${RED}${FAILED_PACKAGES[*]:-None}${NC}"
    echo -e "  ${BOLD}✓ Riced configs:${NC}       ${GREEN}${INSTALLED_CONFIGS[*]:-None}${NC}"
    echo -e "  ${BOLD}✓ Skipped configs:${NC}     ${YELLOW}${SKIPPED_CONFIGS[*]:-None}${NC}"
    echo -e "  ${BOLD}✓ Broken configs:${NC}      ${RED}${FAILED_CONFIGS[*]:-None}${NC}"
    
    if [ -d "$BACKUP_DIR" ]; then
        echo -e "  ${BOLD}✓ Your old stuff is at:${NC} ${PURPLE}$BACKUP_DIR${NC}"
    fi
    echo -e "  ${BOLD}✓ Error logs are here:${NC}  ${BLUE}$LOG_FILE${NC}"
    echo -e "  ${BOLD}✓ Time wasted:${NC}          ${YELLOW}$elapsed seconds${NC}"
    echo -e "${BLUE}───────────────────────────────────────────────────────────────────${NC}"
}

# ==============================================================================
# 6. Oh no, fix it (Backup/Restore)
# ==============================================================================

execute_restore_operation() {
    TOTAL_STEPS=2
    log_step "Emergency Rollback Mode"
    
    local backups=()
    if [ -d "$HOME" ]; then
        local dir
        for dir in "$HOME"/.config-backup-*; do
            if [ -d "$dir" ]; then
                backups+=("$dir")
            fi
        done
    fi

    if [ ${#backups[@]} -eq 0 ]; then
        log_fail "Uh oh. I didn't find any backups."
        return
    fi

    echo -e "\n  ${BOLD}Here's what you can restore:${NC}"
    local i
    for i in "${!backups[@]}"; do
        echo -e "  ${GREEN}[$((i+1))]${NC} $(basename "${backups[$i]}")"
    done
    echo -e "  ${RED}[c]${NC} Changed my mind, cancel."
    echo -e "${BLUE}───────────────────────────────────────────────────────────────────${NC}"
    
    read -rp "Which backup do you want back? " choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -le "${#backups[@]}" ] && [ "$choice" -gt 0 ]; then
        local target_dir="${backups[$((choice - 1))]}"
        log_info "Putting everything back from: $target_dir"
        
        if [ -d "$target_dir/.config" ]; then
            mkdir -p "$HOME/.config"
            cp -a "$target_dir/.config/." "$HOME/.config/" 2>>"$LOG_FILE"
            log_success "Restored ~/.config items."
        fi

        if [ -d "$target_dir/.local" ]; then
            cp -a "$target_dir/.local/." "$HOME/.local/" 2>>"$LOG_FILE"
            log_success "Restored ~/.local items."
        fi

        if [ -d "$target_dir/Pictures" ]; then
            cp -a "$target_dir/Pictures/." "$HOME/Pictures/" 2>>"$LOG_FILE"
            log_success "Restored ~/Pictures items."
        fi

        log_success "Rollback finished. Hopefully things work again."
    else
        log_info "Aborting. Leaving things as they are."
    fi
}

# ==============================================================================
# 7. The main brain
# ==============================================================================

run_orchestrated_installer() {
    local interactive=$1
    phase_validate_env
    phase_build_noctalia
    phase_system_refresh
    phase_inspect_dependencies
    phase_resolve_dependencies
    phase_execute_backup
    phase_deploy_configs "$interactive"
    phase_install_shell_config
    phase_signal_environments
    phase_compile_summary
    
    echo -e "\n${GREEN}═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}${BOLD}                    All Done! The Rice is Served.                    ${NC}"
    echo -e "${GREEN}                                                                    ${NC}"
    echo -e "${GREEN}          Log out and log back in to see the magic happen.          ${NC}"
    echo -e "${GREEN}                      Enjoy Noctara-Dots 🌿                         ${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════════${NC}\n"
}

main() {
    verify_environment
    probe_network
    print_banner

    echo -e "  ${BOLD}What are we doing today?${NC}"
    echo -e "  ${GREEN}[1]${NC} Just do it (Full Auto-Install)"
    echo -e "  ${GREEN}[2]${NC} Let me pick and choose (Interactive Mode)"
    echo -e "  ${YELLOW}[3]${NC} Go back! (Restore Backup)"
    echo -e "  ${CYAN}[4]${NC} Show me what you'd do (Dry Run)"
    echo -e "  ${RED}[5]${NC} Get me out of here (Exit)"
    echo -e "───────────────────────────────────────────────────────────────────${NC}"
    read -rp "Selection: " menu_choice

    case "$menu_choice" in
        1)
            DRY_RUN=false
            run_orchestrated_installer false
            ;;
        2)
            DRY_RUN=false
            run_orchestrated_installer true
            ;;
        3)
            execute_restore_operation
            ;;
        4)
            DRY_RUN=true
            log_warn "Dry run active. Look, don't touch. We won't actually break anything."
            run_orchestrated_installer false
            ;;
        5)
            echo -e "\nPeace out! 🌿"
            exit 0
            ;;
        *)
            log_fail "I Don't Know What You Did. Quitting."
            exit 1
            ;;
    esac
}

main
