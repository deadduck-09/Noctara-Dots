#!/usr/bin/env bash
set -euo pipefail

# Path definitions
NIRI_BIN="${HOME}/.config/niri/bin"
FOCUS_RULES="${NIRI_BIN}/focus-rules.kdl"
ACTIVE_FOCUS="${NIRI_BIN}/focus.kdl"
STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/niri-focus-mode"
PREV_WALLPAPER_FILE="${XDG_RUNTIME_DIR:-/tmp}/niri-prev-wallpaper"
PREV_WALLPAPER_AUTOMATION_FILE="${XDG_RUNTIME_DIR:-/tmp}/niri-prev-wallpaper-automation"

KITTY_CONF_DIR="${HOME}/.config/kitty"
KITTY_FOCUS="${KITTY_CONF_DIR}/focus.conf"

FOCUS_WALLPAPER="${HOME}/Pictures/Wallpapers/focus.jpg"
SETTINGS_TOML="${HOME}/.local/state/noctalia/settings.toml"

# Helper function to modify [shell.animation] directly in TOML
set_noctalia_animations() {
    local enable_bool="$1"

    if [[ -f "$SETTINGS_TOML" ]]; then
        python3 -c "
import re

try:
    with open('$SETTINGS_TOML', 'r') as f:
        content = f.read()

    if '[shell.animation]' in content:
        content = re.sub(
            r'(\[shell\.animation\][^\[]*?enabled\s*=\s*)(true|false)',
            r'\g<1>$enable_bool',
            content,
            flags=re.DOTALL
        )
    else:
        content += '\n[shell.animation]\nenabled = $enable_bool\n'

    with open('$SETTINGS_TOML', 'w') as f:
        f.write(content)

except Exception:
    pass
" 2>/dev/null || true
    fi
}

# Helper function to modify [wallpaper.automation] directly in TOML
set_wallpaper_automation() {
    local enable_bool="$1"

    if [[ -f "$SETTINGS_TOML" ]]; then
        python3 -c "
import re

try:
    with open('$SETTINGS_TOML', 'r') as f:
        content = f.read()

    pattern = r'(\[wallpaper\.automation\][^\[]*?enabled\s*=\s*)(true|false)'

    if re.search(pattern, content, flags=re.DOTALL):
        content = re.sub(
            pattern,
            r'\g<1>$enable_bool',
            content,
            flags=re.DOTALL
        )
    else:
        content += '\n[wallpaper.automation]\nenabled = $enable_bool\n'

    with open('$SETTINGS_TOML', 'w') as f:
        f.write(content)

except Exception:
    pass
" 2>/dev/null || true
    fi
}

# Handle boot reset flag
if [[ "${1:-}" == "--reset" ]]; then
    echo "// Focus Mode Inactive" > "$ACTIVE_FOCUS"
    echo "# Focus Mode Inactive" > "$KITTY_FOCUS"

    rm -f "$STATE_FILE"

    # Restore Noctalia animations
    set_noctalia_animations "true"

    # Restore previous wallpaper automation state
    if [[ -f "$PREV_WALLPAPER_AUTOMATION_FILE" ]]; then
        PREV_AUTOMATION=$(cat "$PREV_WALLPAPER_AUTOMATION_FILE")
        set_wallpaper_automation "$PREV_AUTOMATION"
        rm -f "$PREV_WALLPAPER_AUTOMATION_FILE"
    fi

    sleep 1

    if command -v noctalia &>/dev/null; then
        # Reload Noctalia configuration
        noctalia msg config-reload || true

        # Restore the bar and its normal reserved layout space
        noctalia msg bar-show || true

        # Restore desktop widgets and visualizers
        noctalia msg desktop-widgets-show || true

        # Restore the previous wallpaper if available
        if [[ -f "$PREV_WALLPAPER_FILE" ]]; then
            PREV_WALL=$(cat "$PREV_WALLPAPER_FILE")

            if [[ -n "$PREV_WALL" && -f "$PREV_WALL" ]]; then
                noctalia msg wallpaper-set "$PREV_WALL" || true
            else
                noctalia msg wallpaper-next || true
            fi

            rm -f "$PREV_WALLPAPER_FILE"
        else
            noctalia msg wallpaper-next || true
        fi
    fi

    # Reload Niri configuration
    if command -v niri &>/dev/null; then
        niri msg action load-config-file || true
    fi

    # Reload Kitty configuration
    if pgrep -x kitty &>/dev/null; then
        killall -SIGUSR1 kitty || true
    fi

    exit 0
fi

# State check and configuration swap
if [[ -f "$STATE_FILE" ]]; then
    # ==========================================
    # DISABLE FOCUS MODE
    # ==========================================

    echo "// Focus Mode Inactive" > "$ACTIVE_FOCUS"
    echo "# Focus Mode Inactive" > "$KITTY_FOCUS"

    rm -f "$STATE_FILE"

    # Re-enable Noctalia animations
    set_noctalia_animations "true"

    # Restore previous wallpaper automation state
    if [[ -f "$PREV_WALLPAPER_AUTOMATION_FILE" ]]; then
        PREV_AUTOMATION=$(cat "$PREV_WALLPAPER_AUTOMATION_FILE")
        set_wallpaper_automation "$PREV_AUTOMATION"
        rm -f "$PREV_WALLPAPER_AUTOMATION_FILE"
    fi

    if command -v noctalia &>/dev/null; then
        # Reload config to apply animation and wallpaper automation settings
        noctalia msg config-reload || true

        # Restore all Noctalia bars and normal layout gaps
        noctalia msg bar-show || true

        # Restore desktop widgets and visualizers
        noctalia msg desktop-widgets-show || true

        # Restore the exact previous wallpaper if saved
        if [[ -f "$PREV_WALLPAPER_FILE" ]]; then
            PREV_WALL=$(cat "$PREV_WALLPAPER_FILE")

            if [[ -n "$PREV_WALL" && -f "$PREV_WALL" ]]; then
                noctalia msg wallpaper-set "$PREV_WALL" || true
            else
                noctalia msg wallpaper-next || true
            fi

            rm -f "$PREV_WALLPAPER_FILE"
        else
            noctalia msg wallpaper-next || true
        fi
    fi

    MSG="Focus Mode Disabled"

else
    # ==========================================
    # ENABLE FOCUS MODE
    # ==========================================

    cp "$FOCUS_RULES" "$ACTIVE_FOCUS"
    echo "background_opacity 1.0" > "$KITTY_FOCUS"

    # Disable Noctalia animations
    set_noctalia_animations "false"

    # Save current wallpaper automation state
    CURRENT_AUTOMATION=$(python3 -c "
import re

try:
    with open('$SETTINGS_TOML', 'r') as f:
        content = f.read()

    match = re.search(
        r'\[wallpaper\.automation\][^\[]*?enabled\s*=\s*(true|false)',
        content,
        flags=re.DOTALL
    )

    print(match.group(1) if match else 'true')

except Exception:
    print('true')
" 2>/dev/null || echo "true")

    echo "$CURRENT_AUTOMATION" > "$PREV_WALLPAPER_AUTOMATION_FILE"

    # Disable wallpaper automation during Focus Mode
    set_wallpaper_automation "false"

    if command -v noctalia &>/dev/null; then
        # Save current wallpaper path before switching
        CURRENT_WALL=$(noctalia msg wallpaper-get 2>/dev/null || true)

        if [[ -n "$CURRENT_WALL" ]]; then
            echo "$CURRENT_WALL" > "$PREV_WALLPAPER_FILE"
        fi

        # Reload config to apply animation and wallpaper automation settings
        noctalia msg config-reload || true

        # Hide all Noctalia bars and release their layout gaps
        noctalia msg bar-hide || true

        # Hide desktop widgets and visualizers
        noctalia msg desktop-widgets-hide || true

        # Set Focus Wallpaper
        if [[ -f "$FOCUS_WALLPAPER" ]]; then
            noctalia msg wallpaper-set "$FOCUS_WALLPAPER" || true
        fi
    fi

    # Mark Focus Mode active only after setup
    touch "$STATE_FILE"

    MSG="Focus Mode Enabled"
fi

# Live reload Niri compositor
if command -v niri &>/dev/null; then
    niri msg action load-config-file
fi

# Live reload Kitty windows
if pgrep -x kitty &>/dev/null; then
    killall -SIGUSR1 kitty
fi

# Send desktop notification
if command -v notify-send &>/dev/null; then
    notify-send \
        -a "Niri" \
        -h string:x-canonical-private-synchronous:niri-focus \
        "$MSG"
fi
