# Start Menu shortcut "Ubuntu Dev" that opens Ubuntu in Windows Terminal (Ctrl+Alt+T).
$lnk = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\Ubuntu Dev.lnk'
$shortcut = (New-Object -ComObject WScript.Shell).CreateShortcut($lnk)
$shortcut.TargetPath = Join-Path $env:LOCALAPPDATA 'Microsoft\WindowsApps\wt.exe'
$shortcut.Arguments = '-p "Ubuntu-26.04"'
$shortcut.Hotkey = 'CTRL+ALT+T'
$shortcut.Save()
