#!/usr/bin/env bash

set -e  # Exit on errors

# trash-manager.sh - Comprehensive trash-cli management script for macOS
# Maintainer: zx0r
# Version: 1.0.0
# License: MIT

# 📌 trash-manager.sh Installs and configures Trash-CLI for macOS
# - Ensures Trash-CLI is installed
# - Adds useful aliases for easier usage
# - Configures the correct PATH for the shell
# - Sets up shell completions (Bash, Zsh, Fish)
# - Integrates Trash-CLI with Finder's Trash
# - Reloads the shell configuration to apply changes

# 🎨 Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

# 🔹 Validate macOS environment
is_macos() {
  if [[ "$OSTYPE" != "darwin"* ]]; then
    error "❌ This script only supports macOS. Exiting..."
  fi
}

success() { echo -e "\n✅ ${GREEN} $1 ${NC}"; }
warn() { echo -e "🚧 ${YELLOW} $1 ${NC}"; }
log() { echo -e "📌 ${BLUE} $1 ${NC}"; }
error() {
  echo -e "❌ ${RED}$1${NC}" >&2
  exit 1
}

# 🚀 Ensure Homebrew is installed
is_installed() {
  if ! command -v brew &>/dev/null; then
    warn "Homebrew not found! Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || error "Failed to install Homebrew!"
    success "Homebrew installed!"
  fi
}

# 📦 Install trash-cli
install_trash_cli() {
  log "Installing trash-cli..."
  brew install trash-cli || error "Failed to install trash-cli!"
  success "trash-cli installed!"
}

# 🛠 Detect shell & get config file
detect_shell() {
  SHELL_NAME=$(basename "$SHELL")
  case "$SHELL_NAME" in
  "bash") CONFIG_FILE="$HOME/.bashrc" ;;
  "zsh") CONFIG_FILE="$HOME/.zshrc" ;;
  "fish") CONFIG_FILE="$HOME/.config/fish/config.fish" ;;
  *) error "Unsupported shell: $SHELL_NAME. Please configure manually." ;;
  esac
}

# 🚨 Optional: Alias `rm` to `trash-put`
add_aliases() {
  detect_shell # Ensure correct shell is detected

  local alias_block="
# Trash-CLI Aliases
alias rm='trash-put'
alias trlist='trash-list'
alias trempty='trash-empty'
alias trrestore='trash-restore'
alias trrm='trash-rm'
"
  read -rp "Do you want add aliases 'rm' for safety? (y/N): " choice
  if [[ "$choice" =~ ^[Yy]$ ]]; then

    # Check if aliases already exist in config file before adding
    if ! grep -q "alias rm='trash-put'" "$CONFIG_FILE"; then
      log "Adding Trash-CLI aliases to $CONFIG_FILE..."
      echo "$alias_block" >>"$CONFIG_FILE"
      success "Aliases added for safer file deletion!"
    else
      log "Aliases already set up."
    fi
  fi
}

# 🔗 Ensure trash-cli is in PATH
add_to_path() {
  detect_shell # Detect user shell and set CONFIG_FILE

  local trash_path="/usr/local/opt/trash-cli/libexec/bin"

  # Check if trash-cli is already in PATH
  if command -v trash &>/dev/null; then
    log "Adding trash-cli to PATH..."

    # Add to the shell's configuration file
    case "$SHELL_NAME" in
    "fish")
      echo "fish_add_path $trash_path" >>"$CONFIG_FILE"
      echo "set -gx TRASHDIR ~/.Trash" >>"$CONFIG_FILE"
      ;;
    *)
      echo "export PATH='$trash_path:\$PATH'" >>"$CONFIG_FILE"
      echo "export TRASHDIR=~/.Trash" >>"$CONFIG_FILE"
      ;;
    esac

    # Export for the current session
    export PATH="$trash_path:$PATH"
    export TRASHDIR=~/.Trash

    success "trash-cli added to PATH and configured for $SHELL_NAME!"
  else
    log "trash-cli is already in PATH."
  fi
}

# 🔄 Redirect trash-cli to Finder’s Trash
configure_finder_trash() {
  log "Configuring trash-cli to use Finder’s Trash..."
  mkdir -p ~/.local/share/Trash
  rm -rf ~/.local/share/Trash/files
  ln -s ~/.Trash ~/.local/share/Trash/files
  success "Trash-cli now moves files to Finder's Trash!"
}

# 🔄 Reload shell configuration
reload_shell_config() {
  detect_shell
  log "Reloading shell configuration..."
  source "$CONFIG_FILE"
  success "Shell configuration reloaded!"
}

# 🗑️ Permanently delete all trash files
empty_trash() {
  log "Permanently deleting all files from trash..."
  if trash-list | grep -q '.'; then
    trash-empty || error "Failed to empty trash!"
    success "🗑️ Trash has been emptied!"
  else
    warn "Trash is already empty!"
  fi
}

# 🧹 Cleanup Workflow
uninstall_trash_cli() {
  log "🗑️ Uninstalling trash-cli..."

  trash_dir="$HOME/.local/share/Trash/files"

  if command -v trash &>/dev/null; then
    brew uninstall trash-cli || {
      log error "Failed to uninstall trash-cli"
      exit 1
    }
  else
    log "🏁 trash-cli is not installed."
  fi

  # Safely remove trash directory if empty
  if [[ -d "$trash_dir" ]]; then
    (
      shopt -s nullglob
      files=("$trash_dir"/*)

      if [[ ${#files[@]} -eq 0 ]]; then
        log "🧹 Removing empty ~/.Trash folder..."
        if rm -rf "$trash_dir"; then
          success "$trash_dir removed successfully!"
        else
          warn "Failed to remove $trash_dir" >&2
          exit 1
        fi
      else
        warn "$trash_dir contains ${#files[@]} items - preserving contents"
      fi
    )
  else
    warn "$trash_dir directory not found"
  fi
  success "Uninstallation completed successfully"
}

# 📌 Show help instructions
show_help() {
  # Restore cursor position
  tput clear
  echo -ne "\033[H"

  echo -e "${GREEN}Trash-CLI Setup Script${NC}"
  echo -e "\n${YELLOW}[Options:]${NC}"
  echo -e "${YELLOW}--install    Install and configure trash-cli${NC}"
  echo -e "${YELLOW}--empty      Permanently delete files from trash${NC}"
  echo -e "${YELLOW}--uninstall  Uinstall trash-cli${NC}"
  echo -e "${YELLOW}--help       Show this help message${NC}"
  echo -e "\n${BLUE} Usage: ./trash_manager.sh --help${NC}"
}

# 🚀 Full setup function
setup_trash() {
  log "🚀 Starting Trash-CLI setup..."

  is_macos               # Validate macOS environment
  is_installed           # Check if Trash-CLI is already installed
  install_trash_cli      # Install Trash-CLI using Homebrew
  add_aliases            # Add common aliases (rm -> trash-put, etc.)
  add_to_path            # Ensure Trash-CLI is in the user's PATH
  configure_finder_trash # Redirect Trash-CLI to Finder’s Trash
  reload_shell_config    # Reload shell configuration for changes to take effect

  success "\n🎉 Trash-CLI setup complete! Try using: 'trash-put <file>' and 'trash-list'"
}

# 🏁 Argument Handling
case "$1" in
--install) setup_trash ;;
--empty) empty_trash ;;
--uninstall) uninstall_trash_cli ;;
--help) show_help ;;
*)
  warn "Invalid option! Use '--help' for usage instructions."
  exit 1
  ;;
esac
