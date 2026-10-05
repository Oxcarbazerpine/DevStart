#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != Darwin ]]; then
    echo "This script requires macOS." >&2
    exit 1
fi

notes_path="${1:-$HOME/Notes/DevStart}"
installer="$(mktemp)"
trap 'rm -f "$installer"' EXIT

if ! command -v brew >/dev/null 2>&1; then
    if [[ -x /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    else
        curl --fail --show-error --silent --location \
            https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o "$installer"
        /bin/bash "$installer"
        if [[ -x /opt/homebrew/bin/brew ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    fi
fi

brew update
for package in git python; do
    if brew list --formula "$package" >/dev/null 2>&1; then
        brew upgrade "$package"
    else
        brew install "$package"
    fi
done
if brew list --cask visual-studio-code >/dev/null 2>&1; then
    brew upgrade --cask visual-studio-code
else
    brew install --cask visual-studio-code
fi

curl --fail --show-error --silent --location https://claude.ai/install.sh -o "$installer"
/bin/bash "$installer"

brew_path="$(command -v brew)"
python_bin="$(brew --prefix python)/libexec/bin"
export PATH="$HOME/.local/bin:$python_bin:$PATH"
printf -v brew_line "eval \"\$(%q shellenv)\"" "$brew_path"
printf -v path_line "export PATH=\"\$HOME/.local/bin\":%q:\"\$PATH\"" "$python_bin"
for profile in "$HOME/.zprofile" "$HOME/.zshrc"; do
    touch "$profile"
    for line in "$brew_line" "$path_line"; do
        if ! grep -Fqx "$line" "$profile"; then
            printf '\n%s\n' "$line" >> "$profile"
        fi
    done
done

mkdir -p "$notes_path"/{inbox,projects,reference,archive}
if [[ ! -e "$notes_path/README.md" ]]; then
    cat > "$notes_path/README.md" <<'NOTES'
# Developer notes

- inbox/: quick captures and ideas
- projects/: one Markdown file or folder per project
- reference/: reusable commands and knowledge
- archive/: completed or inactive notes

Use Markdown (.md) files. Move notes from inbox into projects or reference.
NOTES
fi

git --version
python3 --version
code --version
claude --version
printf '\nSetup complete. Open a new terminal, then open your notes with:\n'
printf 'code %q\n' "$notes_path"
