[CmdletBinding()]
param(
    [string]$NotesPath = (Join-Path $HOME 'Notes\DevStart')
)

$ErrorActionPreference = 'Stop'
if ($env:OS -ne 'Windows_NT') {
    throw 'This script requires Windows.'
}
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw 'Install or update App Installer (WinGet) from the Microsoft Store, then rerun this script.'
}

function Install-WinGetPackage {
    param([string]$Id)
    & winget install --exact --id $Id --source winget --accept-package-agreements --accept-source-agreements --disable-interactivity
    # WinGet reports this code when the latest version is already installed.
    if ($LASTEXITCODE -ne 0 -and $LASTEXITCODE -ne -1978335189) {
        throw "WinGet failed to install $Id (exit code $LASTEXITCODE)."
    }
}

function Update-SessionPath {
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
        [Environment]::GetEnvironmentVariable('Path', 'User')
}

Install-WinGetPackage 'Git.Git'
Install-WinGetPackage 'Microsoft.VisualStudioCode'
Install-WinGetPackage 'Python.PythonInstallManager'
Update-SessionPath

$bashCandidates = @(
    $env:CLAUDE_CODE_GIT_BASH_PATH
    "${env:ProgramFiles}\Git\bin\bash.exe"
    "${env:LOCALAPPDATA}\Programs\Git\bin\bash.exe"
)
$git = Get-Command git -ErrorAction SilentlyContinue
if ($git) {
    $bashCandidates += Join-Path (Split-Path (Split-Path $git.Source)) 'bin\bash.exe'
}
$gitBash = $bashCandidates | Where-Object { $_ -and (Test-Path -LiteralPath $_ -PathType Leaf) } |
    Select-Object -First 1
if (-not $gitBash) {
    throw 'Git Bash was not found. Set CLAUDE_CODE_GIT_BASH_PATH to your Git bash.exe and rerun.'
}
$env:CLAUDE_CODE_GIT_BASH_PATH = $gitBash
[Environment]::SetEnvironmentVariable('CLAUDE_CODE_GIT_BASH_PATH', $gitBash, 'User')

if (-not (Get-Command pymanager -ErrorAction SilentlyContinue)) {
    throw 'Python Install Manager is not on PATH. Enable its app execution alias in Windows Settings and rerun.'
}
& pymanager install --update 3
if ($LASTEXITCODE -ne 0) {
    throw "Python installation failed (exit code $LASTEXITCODE)."
}

$installer = Join-Path ([IO.Path]::GetTempPath()) ("devstart-" + [guid]::NewGuid() + '.ps1')
try {
    Invoke-WebRequest -Uri 'https://claude.ai/install.ps1' -OutFile $installer
    & $installer
    if (-not $?) {
        throw 'Claude Code installation failed.'
    }
}
finally {
    Remove-Item -LiteralPath $installer -Force -ErrorAction SilentlyContinue
}

$claudeBin = Join-Path $HOME '.local\bin'
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if ($claudeBin -notin ($userPath -split ';')) {
    [Environment]::SetEnvironmentVariable('Path', "$claudeBin;$userPath", 'User')
}
Update-SessionPath

foreach ($folder in @('inbox', 'projects', 'reference', 'archive')) {
    New-Item -ItemType Directory -Path (Join-Path $NotesPath $folder) -Force | Out-Null
}
$notesIndex = Join-Path $NotesPath 'README.md'
if (-not (Test-Path -LiteralPath $notesIndex)) {
    @'
# Developer notes

- inbox/: quick captures and ideas
- projects/: one Markdown file or folder per project
- reference/: reusable commands and knowledge
- archive/: completed or inactive notes

Use Markdown (.md) files. Move notes from inbox into projects or reference.
'@ | Set-Content -LiteralPath $notesIndex -Encoding UTF8
}

foreach ($tool in @('git', 'pymanager', 'code', 'claude')) {
    & $tool --version
    if ($LASTEXITCODE -ne 0) {
        throw "$tool verification failed (exit code $LASTEXITCODE)."
    }
}
& pymanager exec '-V:3' --version
if ($LASTEXITCODE -ne 0) {
    throw 'Python runtime verification failed.'
}
Write-Host "`nSetup complete. Open a new terminal, then open your notes with:"
Write-Host ('code "{0}"' -f $NotesPath)
