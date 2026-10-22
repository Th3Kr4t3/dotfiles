# Pins the WSL projects folder to File Explorer's Quick Access.
$path = '\\wsl.localhost\Ubuntu-26.04\home\user\projects'
$shell = New-Object -ComObject Shell.Application
$quickAccess = $shell.Namespace('shell:::{679f85cb-0220-4080-b29b-5540cc05aab6}')
if (-not ($quickAccess.Items() | Where-Object { $_.Path -eq $path })) {
    $shell.Namespace($path).Self.InvokeVerb('pintohome')
}
