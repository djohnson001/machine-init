REM Chocolatey
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

cinst boxstarter -y

BoxStarterShell

#box starter options
Set-TaskbarOptions -Combine Never -Size Small
Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -DisableShowProtectedOSFiles -EnableShowFileExtensions -EnableShowFullPathInTitleBar -DisableOpenFileExplorerToQuickAccess -DisableShowRecentFilesInQuickAccess -DisableShowFrequentFoldersInQuickAccess 
Disable-InternetExplorerESC
Disable-GameBarTips
Disable-BingSearch

#browsers
cinst firefox -y
cinst chrome -y

#dev stuff
cinst git -y
refreshenv
cinst docker -y
cinst visualstudiocode -y
cinst visualstudio2017community -y






