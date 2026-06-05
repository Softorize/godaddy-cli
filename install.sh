#!/usr/bin/env bash
# Install script for godaddy-cli.
# Usage:  curl -fsSL https://raw.githubusercontent.com/softorize/godaddy-cli/main/install.sh | bash
set -euo pipefail

REPO_RAW="${GODADDY_CLI_RAW:-https://raw.githubusercontent.com/softorize/godaddy-cli/main}"
BIN_DIR="${GODADDY_CLI_BIN_DIR:-$HOME/.local/bin}"
DEST="$BIN_DIR/godaddy"

mkdir -p "$BIN_DIR" "$HOME/.godaddy"

echo "Downloading godaddy -> $DEST"
curl -fsSL "$REPO_RAW/godaddy" -o "$DEST"
chmod 0755 "$DEST"

if [[ ! -f "$HOME/.godaddy/credentials" ]]; then
  cat > "$HOME/.godaddy/credentials" <<'EOF'
# GoDaddy API credentials - keep mode 600
# Get keys at https://developer.godaddy.com/keys
# After pasting, run: godaddy auth-check
GODADDY_KEY=
GODADDY_SECRET=
GODADDY_ENV=prod
EOF
  chmod 0600 "$HOME/.godaddy/credentials"
  echo "Created $HOME/.godaddy/credentials (mode 600). Paste your key + secret there."
else
  echo "Existing $HOME/.godaddy/credentials left untouched."
fi

case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *) echo
     echo "WARNING: $BIN_DIR is not on your PATH."
     echo "Add this to your shell rc (~/.zshrc or ~/.bashrc):"
     echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
     ;;
esac

echo
echo "Installed. Try: godaddy whoami"
