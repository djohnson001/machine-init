function machineInit() {
    function DownloadFile($uri, $fileName) {
        #$downloadsFolder = [Environment]::GetFolderPath("Desktop")
        $destinationFolder = $env:temp
        $destinationFullFileName = [System.IO.Path]::Combine($destinationFolder, $fileName)
        (New-Object System.Net.WebClient).DownloadFile($uri, $destinationFullFileName)

        return $destinationFullFileName
    }

    function DownloadAndInstallZip($uri, $fileName, $installedName) {
        $downloadedFileName = DownloadFile -uri $uri -fileName $fileName
        $downloadedFileNameInfo = New-Object System.IO.FileInfo($downloadedFileName)
        $downloadedFileNameWithoutExtension = $downloadedFileNameInfo.Name.SubString(0, $downloadedFileNameInfo.Name.Length - $downloadedFileNameInfo.Extension.Length)

        $destinationPath = [System.IO.Path]::Combine($env:ProgramFiles, $installedName)
        if (-not [System.IO.File]::Exists($destinationPath)) {
            mkdir $destinationPath
        }

        $tempDestinationPath = [System.IO.Path]::Combine($env:temp, $installedName)
        if ([System.IO.File]::Exists($tempDestinationPath))  {
            Remove-Item -Recurse -Force $tempDestinationPath
        }

        mkdir $tempDestinationPath
    
        Expand-Archive -Path $downloadedFileName -DestinationPath $tempDestinationPath
        Copy-Item ([System.IO.Path]::Combine($tempDestinationPath, $downloadedFileNameWithoutExtension) + "\*") $destinationPath

        Remove-Item -Recurse -Force $tempDestinationPath
        Remove-Item -Force $downloadedFileName
    }

    function installChocolatey() {
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
        SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin
    }

    function boxStarterStuff() {
        cinst boxstarter -y

        BoxStarterShell

        Set-TaskbarOptions -Combine Never -Size Small -UnLock
        Set-WindowsExplorerOptions `
            -EnableShowHiddenFilesFoldersDrives `
            -DisableShowProtectedOSFiles `
            -EnableShowFileExtensions `
            -EnableShowFullPathInTitleBar `
            -DisableOpenFileExplorerToQuickAccess `
            -DisableShowRecentFilesInQuickAccess `
            -DisableShowFrequentFoldersInQuickAccess

        Disable-InternetExplorerESC
        Disable-GameBarTips
        Disable-BingSearch

        exit
        refreshenv
    }

    # for things that get bundled 
    function removeCrapWare() {
        $grooveMusic = Get-AppxPackage –AllUsers | Where-Object { $_.Name -eq "Microsoft.ZuneMusic" }
        if ($grooveMusic -ne $null) {
            Write-Host "Bite me, GrooveMusic"
            Remove-AppXPackage -Package $grooveMusic.PackageFullName
        }
    }

    function installBrowsers() {
        cinst adblockplusie -y

        cinst firefox -y
        cinst adblockplus-firefox -y

        cinst googlechrome -y
        cinst adblockpluschrome  -y
    }

    function installMediaTools() {
        cinst vlc -y
        cinst paint.net -y
    }

    function installRoslynPad() {
        $uri = "https://github.com/aelij/RoslynPad/releases/download/13.2/RoslynPad.zip"
        $downloadedFullFileName = DownloadFile -uri $uri -fileName "RoslynPad.zip"

        $destinationPath = [System.IO.Path]::Combine($env:ProgramFiles, "RoslynPad")
        mkdir $destinationPath

        Expand-Archive -Path $downloadedFullFileName -DestinationPath $destinationPath
    }

    function installUtilities() {
        cinst cmder -y


        Install-ChocolateyShortcut `
            -ShortcutFilePath "C:\notepad.lnk" `
            -TargetPath "C:\tools\cmder\cmder.exe" `
            -WindowStyle 3 `
            -RunAsAdmin `
            -PinToTaskbar

        cinst 7zip -y
        cinst unetbootin - y
        cinst sysinternals -y
        cinst windirstat -y
        cinst fiddler -y
        cinst etcher -y
        cinst win32diskimager -y
    }

    function installDevTools() {
        cinst dotnet4.7 -y
        cinst dotnet4.7.1 -y
        cinst dotnetcore -y
        cinst git -y
        cinst jdk8 -y
        cinst android-sdk -y
        cinst androidstudio -y
        cinst nodejs -y
        cinst npm -y
        cinst putty -y
        cinst python2 -y
        cinst notepadplusplus -y
        cinst visualstudiocode -y
        cinst visualstudio2017enterprise -y
        cinst arduino -y
        cinst windowsazurepowershell -y
        cinst dotPeek -y

        installRoslynPad
    }

    function installWindowsFeatures() {
	    #IIS
	    Dism /Online /Enable-Feature /FeatureName:IIS-DefaultDocument /All
	    Dism /Online /Enable-Feature /FeatureName:IIS-ASPNET45 /All
        Dism /Online /Enable-Feature /FeatureName:IIS-ManagementConsole /All
        Dism /Online /Enable-Feature /FeatureName:IIS-WebServerRole /All
        Dism /Online /Enable-Feature /FeatureName:IIS-WebServerManagementTools /All
        Dism /Online /Enable-Feature /FeatureName:IIS-Metabase /All
        Dism /Online /Enable-Feature /FeatureName:IIS-WebServer /All
    }

    # makes it easier to restart the explorer process for when it gets hung up.
    # just run "e" and it restarts it.
    function installEBat() {
	    $contents = "taskkill /f /im explorer.exe" + [System.Environment]::NewLine `
		    + "explorer.exe"
	
	    $sys32 = "C:\Windows\System32\"
	    $fileName = [System.IO.Path]::Combine($sys32, "e.bat")
	    [System.IO.File]::WriteAllText($fileName, $contents)
    }

    # still working on this one.
    # it's intended to automatically install the ESP8266 boards to Arduino Studio.
    <#
    function arduinoSetup() {
        $arduinoPreferencesFolder = [System.IO.Path]::Combine($env:LOCALAPPDATA, "Arduino15")    
        $preferencesFileName = [System.IO.Path]::Combine($arduinoPreferencesFolder, "preferences.txt")
        $contents = [System.IO.File]::ReadAllText($preferencesFileName)
        $lines = [System.Linq.Enumerable]::Select(`
            $contents.Replace("'r'n", "'r").Replace("'n", "'r").Split("`r"), 
            [Func[string, string]]{param([string]$line) return $line.Trim()})

        [Func[string, bool]]$func = {param([string]$line) return $true}

        #$query = [System.Linq.Enumerable]::Where($lines, [Func[string, bool]]{param([string]$line) return $line.StartsWith("boardsmanager.additional.urls")})
        $query = [System.Linq.Enumerable]::Where($lines, `
            [Func[string, bool]]{param([string]$line) return $line.Trim().StartsWith("boardsmanager.additional.urls")})

        $matchingLine = [System.Linq.Enumerable]::First($query)

        $esp8266Json = "http://arduino.esp8266.com/stable/package_esp8266com_index.json"
    }#>

    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned

    installChocolatey
    boxStarterStuff
    getRidOfBadStuff
    installRoslynPad
    installGrub
    installUtilities
    installDevTools
    installEBat
}