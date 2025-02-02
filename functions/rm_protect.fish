# ===================================
# 🛡️ Safe rm Configuration for Fish
# ===================================

# Ensure the trash directory exists (if using a custom location)
set -q TRASH_DIR || set -gx TRASH_DIR "$HOME/.Trash"
test -d $TRASH_DIR; or mkdir -p $TRASH_DIR

# 🚨 1. Use 'trash' if installed (safe deletion)
if command -v trash >/dev/null
    abbr -a rm trash-put # Move files to Trash instead of deleting
else
    # 🚨 2. Make rm interactive by default to prevent accidental deletion
    alias rm="rm -I" # Prompts when deleting multiple files
end

# 🚨 3. Secure "rm" function: Moves files to trash instead of deleting
function rmf
    for file in $argv
        mv "$file" "$TRASH_DIR/" && echo "🗑️ Moved $file to Trash."
    end
end

# 🚨 4. Restore files from the trash
function restore
    for file in $argv
        mv "$TRASH_DIR/$file" "$PWD/" && echo "🔄 Restored $file to $PWD"
    end
end

# 🚨 5. List trashed files
alias trash-list="ls -lh $TRASH_DIR"

# 🚨 6. Empty the trash (asks for confirmation)
function empty-trash
    echo "⚠️ Are you sure you want to empty the trash? (y/n)"
    read -l confirm
    if test "$confirm" = y
        rm -rf "$TRASH_DIR"/* && echo "🗑️ Trash emptied."
    else
        echo "❌ Trash was NOT emptied."
    end
end

# 🚨 7. Protect a file from deletion or modification
function protect-file
    set -l os_name (uname)
    switch "$os_name"
        case Linux
            sudo chattr +i $argv && echo "✅ Protected: $argv"
        case Darwin
            sudo chflags uchg $argv && echo "✅ Protected on macOS: $argv"
        case '*'
            echo "❌ Unsupported OS: $os_name"
    end
end

# 🚨 8. Remove protection from a file
function unprotect-file
    set -l os_name (uname)
    switch "$os_name"
        case Linux
            sudo chattr -i $argv && echo "🔓 Unprotected: $argv"
        case Darwin
            sudo chflags nouchg $argv && echo "🔓 Unprotected on macOS: $argv"
        case '*'
            echo "❌ Unsupported OS: $os_name"
    end
end

# 🚨 9. Double-check before using `rm -rf`
alias rmd="echo '⚠️ Use rmf or trash instead! If you REALLY want to delete, type `rm -rf` manually.'"

echo "✅ 🛡️ Safe rm setup loaded: Trash enabled, protection functions active."
