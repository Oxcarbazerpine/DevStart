# DevStart
get ready to develop when entering a new environment with one command.

## Windows (PowerShell)

Use Windows 10/11 with [App Installer (WinGet)](https://aka.ms/getwinget)
installed. Run as your normal user; package installers may request elevation.
From your local copy of this repository:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\setup-windows.ps1
```

The execution-policy override applies only to this process. If an organizational
policy blocks scripts, follow your administrator's policy instead.
To choose a notes location, append `-NotesPath "D:\My Notes"`.

## macOS

Use a macOS version supported by [Homebrew](https://docs.brew.sh/Installation)
and [Claude Code](https://code.claude.com/docs/en/setup). From your local copy:

```bash
bash ./setup-macos.sh
```

Homebrew is installed if missing; its installer may prompt for your password
and install Apple's Command Line Tools. Do not run the script with `sudo`.
To choose a notes location, use `bash ./setup-macos.sh "$HOME/My Notes"`.

## What both scripts do

- Install or update Git, Visual Studio Code, and the latest stable Python
  available through Python Install Manager (Windows) or Homebrew (macOS).
- Install [Claude Code CLI](https://code.claude.com/docs/en/setup) using its
  official native installer. Windows also configures its Git Bash prerequisite.
- Configure terminal PATH: Windows user PATH and macOS Zsh's `.zprofile` and
  `.zshrc`, preserving existing settings. macOS exposes both `python` and
  `python3`; Windows uses the manager's `py`/`python` aliases. If Windows aliases
  conflict with an older Python installation, enable the Python Install Manager
  aliases in **Settings > Apps > Advanced app settings > App execution aliases**.
  macOS users of other shells must configure their shell's PATH separately.
- Create `~/Notes/DevStart` with `inbox`, `projects`, `reference`, and `archive`
  folders, plus a Markdown guide. Existing notes and the guide are not replaced.
- Print installed tool versions and the command to open the notes in VS Code.

An internet connection and permission to install software are required. These
scripts download and execute official Homebrew/Claude installers; review the
scripts and upstream installers before running them. Reruns update tools without
duplicating terminal configuration or overwriting notes.

Open a new terminal after setup. Run `claude` to sign in (an account is required);
no credentials are configured or stored by these scripts. VS Code is also the
Markdown editor: open the notes folder and use its built-in Markdown preview.
