## Prerequisites

### Java + JDTLS
Requires Java 21 for the JDTLS runtime. Check `ftplugin/java.lua`:
`local java21 = "/opt/homebrew/opt/openjdk@21/bin/java"`

Install Java 21 on a new machine and update that path if needed.

## Create Files Quickly

### Primary flow (Neo-tree)
- `<leader>e`: toggle Explorer sidebar at project root (Neo-tree)
- `<leader>er`: reveal current file in Explorer (Neo-tree)
- `a` (inside Neo-tree): create file
- `A` (inside Neo-tree): create directory

Use Neo-tree for navigation and file operations.

### Fast path create (best for Java)
- `<leader>nf`: prompt for a file path and create missing directories automatically
- Path is resolved from the detected project root

Example input:
`src/main/java/com/example/orders/OrderService.java`

### Search/open flow (Telescope)
- `<leader>ff`: find files
- `<leader>fg`: live grep
- `<leader><leader>`: recent files

Use Telescope to jump to files and Neo-tree for file operations.

## Java New File Template

When creating a new `*.java` file:
- If path is under `src/main/java` or `src/test/java`, package is inferred from path.
- A class skeleton is inserted automatically using the filename.

Example:
```java
package com.example.app;

public class UserService {

}
```
## Agent Workflow
Hot reload has been added so code changes made by the agent are picked up automatically while working.

## Pre-commit hook for syncing (alacritty, tmux and zshrc):
```bash
#!/bin/bash
set -e
echo "Syncing external configs..."

ALACRITTY_SRC="$HOME/.config/alacritty/alacritty.yaml"
ZSHRC_SRC="$HOME/.zshrc"
TMUX_SRC="$HOME/.tmux.conf"

ALACRITTY_DEST="configs/alacritty.yaml"
ZSHRC_DEST="configs/.zshrc"
TMUX_DEST="$HOME/.tmux.conf"

cp "$ALACRITTY_SRC" "$ALACRITTY_DEST"
cp "$ZSHRC_SRC" "$ZSHRC_DEST"
cp "$TMUX_SRC" "$TMUX_DEST"

git add "$ALACRITTY_DEST"
git add "$ZSHRC_DEST"
git add "$TMUX_DEST"

echo "Configs synced and staged ✅"

```
