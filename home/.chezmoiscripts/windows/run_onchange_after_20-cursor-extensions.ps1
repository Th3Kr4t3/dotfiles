# Re-runs only when this list changes, so editing it is how you add an extension.
$extensions = @(
    'anysphere.remote-ssh'
    'anysphere.remote-wsl'
    'anysphere.remote-containers'
)

if (-not (Get-Command cursor -ErrorAction SilentlyContinue)) {
    Write-Warning 'Cursor CLI not found; skipping extensions.'
    return
}
$installed = cursor --list-extensions
foreach ($ext in $extensions) {
    if ($installed -notcontains $ext) { cursor --install-extension $ext }
}
