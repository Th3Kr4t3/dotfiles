# Re-runs only when this list changes, so editing it is how you add an app.
# Dev tools only; personal apps (games, hardware utilities) stay out on purpose.
$apps = @(
    'Microsoft.WSL'
    'Microsoft.WindowsTerminal'
    'twpayne.chezmoi'
    'Anysphere.Cursor'
    'Docker.DockerDesktop'
    'Bitwarden.Bitwarden'
    'Anthropic.Claude'
)

foreach ($id in $apps) {
    winget list --id $id --exact --accept-source-agreements --disable-interactivity *> $null
    if ($LASTEXITCODE -eq 0) { Write-Host "ok          $id"; continue }

    Write-Host "installing  $id"
    winget install --id $id --exact --accept-package-agreements --accept-source-agreements --disable-interactivity
    if ($LASTEXITCODE -ne 0) { throw "winget install $id failed with exit code $LASTEXITCODE" }
}
