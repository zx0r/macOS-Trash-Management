# Trash & Trash-CLI for macOS


- [trash](https://hasseg.org/trash) This is a small command-line program for OS X that moves files or folders to the trash.
- [trash-cli](https://github.com/andreafrancia/trash-cli) Command line interface to the freedesktop.org trashcan.

## Overview

This repository provides a setup guide for installing and configuring trash and trash-cli on macOS. These tools enhance file deletion safety by moving files to the system Trash instead of permanently removing them.

### ⚠️ Understanding `rm` vs `trash-cli`

Why Not Use rm?

- rm permanently deletes files, making recovery difficult.

- trash-cli allows undoing deletions if files were removed by mistake.

- trash-empty gives you control over when to permanently delete files.

### 🚨 Comparison: `rm` vs `trash` vs `trash-cli` 

| Feature            | `rm`   | `trash`         | `trash-cli`     |
| ------------------ | ------ | --------------- | --------------- |
| Permanent Deletion | ❌ Yes | ✅ No (movable) | ✅ No (movable) |
|Uses Finder Trash (~/.Trash****)?|❌ No|✅ Yes | ✅ Yes (with hook 🥷)|
| Recovery Possible  | ❌ No  | ❌ No           | ✅ Yes          |
| Moves to Trash     | ❌ No  | ✅ Yes          | ✅ Yes          |
| CLI Interface      | ✅ Yes | ✅ Yes          | ✅ Yes          |
| Shell Integration  | ✅ Yes | ✅ Yes          | ✅ Yes          |
| Supports Restore?  |	❌ No  |   ❌ No         | ✅ Yes (trash-restore)|
| Supports Empty Trash?| ❌ No  | ❌ No.        | ✅ Yes (trash-empty)|
| Requires Python?   | ❌ No  | ❌ No.          | ✅ Yes (Python 3.13)|
|  Command Used		   rm file| trash file	      | trash-put file  |


## 🚀 Installation

🕹 Automated installation
```sh
bash <(curl -fsSL https://raw.githubusercontent.com/zx0r/macOS-Trash-Management/refs/heads/main/bin/trash_manager.sh) --install
```
```sh
# 📌 trash-manager.sh Installs and configures Trash-CLI for macOS
# - Ensures Trash-CLI is installed
# - Adds useful aliases for easier usage
# - Configures the correct PATH for the shell
# - Sets up shell completions (Bash, Zsh, Fish)
# - Integrates Trash-CLI with Finder's Trash
# - Reloads the shell configuration to apply changes
```
🤸 Manual installation

1️⃣ Install via Homebrew

```sh
brew install trash-cli
```

2️⃣ Add to PATH 

```sh
# Trash-CLI Aliases
alias rm='trash-put'
alias trlist='trash-list'
alias trempty='trash-empty'
alias trrestore='trash-restore'
alias trrm='trash-rm'

# Integrates Trash-CLI with Finder's Trash
export TRASHDIR=$HOME/.Trash
echo 'export PATH="$(brew --prefix)/opt/trash/libexec/bin:$PATH"' >> ~/.bashrc  # For Bash
echo 'export PATH="$(brew --prefix)/opt/trash/libexec/bin:$PATH"' >> ~/.zshrc   # For Zsh

# Reload config
source ~/.zshrc

set -gx TRASHDIR "$HOME/.Trash"
echo 'fish_add_path (brew --prefix)/opt/trash/libexec/bin' >> ~/.config/fish/config.fish  # For Fish

# Reload config
source ~/.config/fish/config.fish

# Optional
alias trash="trash-put --trash-dir=$HOME/.Trash"

function trash
    command trash-put --trash-dir=$HOME/.Trash $argv
end

```
💊 Fixing Trash Path on macOS 🗑

```sh
# This is an important point

mkdir -p $HOME/.local/share/Trash
rm -rfi $HOME/.local/share/Trash/files
ln -s $HOME/.Trash ~/.local/share/Trash/files

# Now `trash-cli` will move deleted files to Finder’s Trash
```
3️⃣ Verify Installation
```sh
user $ which trash
/usr/local/opt/trash-cli/libexec/bin/trash

user $ which trash-put
/usr/local/opt/trash-cli/libexec/bin/trash-put


user $ ls -l ~/.local/share/Trash/files
lrwx------  1 x0r  staff  17 Feb  2 20:05 /Users/x0r/.local/share/Trash/files -> /Users/zx0r/.Trash

user $ ls (brew --prefix)/opt/trash-cli/libexec/bin

python
python3
python3.13
trash
trash-empty
trash-list
trash-put
trash-restore
trash-rm
```

🏗️ Shell Completion Setup

```sh
# for bash/zsh
cmds=(trash-empty trash-list trash-restore trash-put trash)
for cmd in ${cmds[@]}; do
  $cmd --print-completion bash | sudo tee /usr/share/bash-completion/completions/$cmd
  $cmd --print-completion zsh | sudo tee /usr/share/zsh/site-functions/_$cmd
  $cmd --print-completion tcsh | sudo tee /etc/profile.d/$cmd.completion.csh
done

autoload -U compinit && compinit
ln -s /usr/local/share/zsh/site-functions/_trash ~/.zsh/completions/_trash

# Fish Shell
ln -s /usr/local/share/fish/completions/trash.fish ~/.config/fish/completions/
```

⚡ Usage

🖥️ trash (macOS-native Trash Management)
```sh
trash-put </parh/to/file>          # Moves file.txt to Finder Trash (~/.Trash)
```
🗃️ trash-cli (Advanced Trash Management)
```sh
trash-put <file>        # Move file to ~/.local/share/Trash/files
trash-list              # List trashed files
trash-restore <file>    # Restore a trashed file
trash-empty             # Permanently delete trashed files
```

## 🛠️ Debugging.     

If `trash-cli` isn’t working correctly, check the installation paths:
```sh

# 🛠 Fix: Make trash-cli Use Finder's Trash (~/.Trash/)
# Since trash-cli does not natively use Finder’s Trash, you can redirect it with a symlink.

# Force trash-cli to use Finder’s Trash
mkdir -p $HOME/.local/share/Trash
rm -rf $HOME/.local/share/Trash/files
ln -s $HOME/.Trash ~/.local/share/Trash/files

user $ which trash
/usr/local/opt/trash-cli/libexec/bin/trash

user $ touch testfile
user $ trash-put testfile
user $ trash-list
2025-02-02 21:00:03 /Users/zx0r/macOS-Trash-Management/bin/testfile

user $ ll $HOME/.local/share/Trash/files
  inode Permissions  Size User Group Date Modified Date Accessed Name 
5056816 .rw-r--r--      0 x0r  staff  2 Feb 16:27   2 Feb 16:27  testfile
5094130 lrwx------      - x0r  staff  2 Feb 20:07   2 Feb 20:07   trash-cli.fish -> /usr/local/share/fish/completions/trash-cli.fish

user $ ls -l $HOME/.Trash/
total 160
-rw-r--r--  1 zx0r   staff   0 Feb  2 16:27 testfile

user $ ls -la /usr/local/opt/trash-cli/libexec/bin/
total 48
drwx------  11 x0r  admin  352 Feb  2 20:01 .
drwx------   9 x0r  admin  288 Feb  2 20:01 ..
lrwx------   1 x0r  admin   10 May 26  2024 python -> python3.13
lrwx------   1 x0r  admin   10 May 26  2024 python3 -> python3.13
lrwx------   1 x0r  admin   45 May 26  2024 python3.13 -> ../../../../../opt/python@3.13/bin/python3.13
-rwx------   1 x0r  admin  169 Feb  2 20:01 trash
-rwx------   1 x0r  admin  171 Feb  2 20:01 trash-empty
-rwx------   1 x0r  admin  170 Feb  2 20:01 trash-list
-rwx------   1 x0r  admin  169 Feb  2 20:01 trash-put
-rwx------   1 x0r  admin  173 Feb  2 20:01 trash-restore
-rwx------   1 x0r  admin  168 Feb  2 20:01 trash-rm
```


## 🏁 Conclusion

Using trash-cli ensures safer file deletion by allowing users to restore accidentally deleted files, unlike the irreversible rm command. Whether you're a beginner or an advanced user, integrating trash-cli into your workflow can prevent accidental data loss while maintaining the convenience of command-line file management.

---



### 💡 Stay safe. Use `trash-cli`, not `rm`! Happy cleaning! 🧹
