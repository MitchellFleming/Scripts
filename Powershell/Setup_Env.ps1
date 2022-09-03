Write-Output "Starting environment setup"

function CleanupDesktopShortcuts
{
	$CurrentUserDesktopPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)
	$DesktopPaths = @('C:\Users\Public\Desktop', $CurrentUserDesktopPath)
    foreach ($DesktopPath in $DesktopPaths)
	{
		Write-Host "Deleting Shortcuts At Path: $DesktopPath"
		$shortcuts = (Get-ChildItem $DesktopPath | Where-Object Name -like "*.lnk")

		Write-Host "Found $($shortcuts.Length) shortcuts: $([string]::Join(", ", $shortcuts.Name))"

		$shortcuts.FullName | ForEach-Object {
			Remove-Item $_
		}
	}
}

function UpdateEnvironmentPath
{
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") `
          + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}

# Install Chocolatey Package Manager. It's not apt-get, but we are on Windows.. ¯\_(ツ)_/¯
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator"))
{
    # Start-Process powershell.exe -ExecutionPolicy Bypass -File
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit
}
Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing | iex
UpdateEnvironmentPath

choco feature enable -n allowGlobalConfirmation 

# PREQs For Ideal WSL/DockerDesktop
# Make sure you have virtualization enabled in bios
# AMD  -> AMD-V
# Intel-> IntelVT
# ARM  -> If you're trying to run Windows on ARM don't bother with this script go install an OS that actually runs on ARM
# Or don't if you're into that, I'm not here to tell you which hill you're allowed to die on
# Enable WSL, then install distro, defaulted ubuntu. If upgrading WSL 1->2 uninstall currently installed distros and reinstall to avoid bugs
wsl --install
choco uninstall wsl-ubuntu-2004  
choco install wsl-ubuntu-2004

choco install 7zip
choco install authy-desktop
choco install bitwarden
choco install docker-desktop
choco install edgedeflector
choco install ffmpeg
choco install filezilla
choco install gimp
choco install inkscape
choco install jetbrainsmono
choco install jetbrainstoolbox
choco install mediainfo
choco install microsoft-windows-terminal
choco install notepadplusplus
choco install nvm
choco install picard
choco install postman
choco install qbittorrent
# RustDesk is like TeamViewer if TeamViewer wasn't buggy malware
choco install rustdesk
choco install signal
choco install smplayer
choco install veracrypt

# Instal Git with Git and Unix tools added to PATH
choco install git --params "/GitAndUnixToolsOnPath"
UpdateEnvironmentPath
# Instal GitHub CLI
choco install gh
UpdateEnvironmentPath

# Install Major Browsers
#choco install brave
choco install firefox --yes
choco install googlechrome --yes

UpdateEnvironmentPath
# If you're into clutter comment out the next line

# Clean Chocolatey cache in free version
choco install choco-cleaner
C:\tools\BCURRAN3\choco-cleaner.ps1

CleanupDesktopShortcuts

PAUSE