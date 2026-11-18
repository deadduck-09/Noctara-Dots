#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-disable}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BLOCKLIST="${SCRIPT_DIR}/blocklist.txt"
TEMPLATE="${SCRIPT_DIR}/hosts.template"
HOSTS_FILE="/etc/hosts"

TMP_HOSTS="$(mktemp)"

if [[ "$MODE" == "enable" ]]; then
    # Start with the clean template
    cp "$TEMPLATE" "$TMP_HOSTS"
    
    echo "" >> "$TMP_HOSTS"
    echo "# --- Niri Focus Mode Blocklist ---" >> "$TMP_HOSTS"
    
    # Process blocklist (skipping comments and blank lines)
    if [[ -f "$BLOCKLIST" ]]; then
        while IFS= read -r line || [[ -n "$line" ]]; do
            # Trim whitespace and extract domain
            domain="$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
            
            # Skip empty lines or comments
            [[ -z "$domain" || "$domain" =~ ^# ]] && continue
            
            # Map domain to 0.0.0.0 (IPv4) and :: (IPv6)
            echo "0.0.0.0 ${domain}" >> "$TMP_HOSTS"
            echo ":: ${domain}" >> "$TMP_HOSTS"
        done < "$BLOCKLIST"
    fi
    
    cp "$TMP_HOSTS" "$HOSTS_FILE"
else
    # Restore template hosts file
    cp "$TEMPLATE" "$HOSTS_FILE"
fi

rm -f "$TMP_HOSTS"
