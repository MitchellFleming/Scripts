Write-Output "Starting environment setup"

function CleanupDesktopShortcuts
{
	$CurrentUserDesktopPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)
	$DesktopPaths = @('C:\Users\Public\Desktop', $CurrentUserDesktopPath)
    foreach ($DesktopPath in $DesktopPaths)
	{
		Write-Host "Checking For Shortcuts At Path: $DesktopPath"
		$shortcuts = (Get-ChildItem $DesktopPath | Where-Object Name -like "*.lnk")

		if($shortcuts.Length > 0){
			Write-Host "Found $($shortcuts.Length) shortcuts: $([string]::Join(", ", $shortcuts.Name))"

			$shortcuts.FullName | ForEach-Object {
				Remove-Item $_
			}
		}
		else{
			Write-Host "No Shortcuts Found At Path: $DesktopPath"
		}
	}
}

function UpdateEnvironmentPath
{
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") `
          + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}

function CreateScheduledUpdateTaskWithServiceUser
{
	# Credit Brian Hull w slight adjustments
	# https://www.hull1.com/software_deployment/2020/08/10/scheduled-choco-updates.html
	#
	# This script will create chocoUpdater Account with a random password 
	# and use this account to schedule software upadates with choco.
	#

	#Generate Random Password
	$minLength = 20
	$maxLength = 30
	$length = Get-Random -Minimum $minLength -Maximum $maxLength
	$letters = "abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ".ToCharArray()
	$uppers = "ABCDEFGHJKLMNPQRSTUVWXYZ".ToCharArray()
	$lowers = "abcdefghijkmnopqrstuvwxyz".ToCharArray()
	$digits = "23456789".ToCharArray()
	$symbols = "_-+=@$%".ToCharArray()
	$chars = "abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789_-+=@$%".ToCharArray()

	do {
		$pwdChars = "".ToCharArray()
		$goodPassword = $false
		$hasDigit = $false
		$hasSymbol = $false
		$pwdChars += (Get-Random -InputObject $uppers -Count 1)
		for ($i=1; $i -lt $length; $i++) {
			$char = Get-Random -InputObject $chars -Count 1
			if ($digits -contains $char) { $hasDigit = $true }
			if ($symbols -contains $char) { $hasSymbol = $true }
			$pwdChars += $char
		}
		$pwdChars += (Get-Random -InputObject $lowers -Count 1)
		$password = $pwdChars -join ""
		$goodPassword = $hasDigit -and $hasSymbol
	} until ($goodPassword)

	#Create Account
	$SecurePassword = ConvertTo-SecureString $password -AsPlainText -Force
	$user = "chocoUpdater"

	Remove-LocalUser -InputObject $user -Confirm:$false
	New-LocalUser -Name $user -Password $SecurePassword -Confirm:$false
	Set-LocalUser -Name $user -PasswordNeverExpires:$true
	Add-LocalGroupMember -Group Administrators -Member $user -Confirm:$false

	#Create scheduled task
	Unregister-ScheduledTask -TaskName "choco_software_update" -Confirm:$false

	$action = New-ScheduledTaskAction -Execute 'choco' -Argument 'upgrade all -a'

	$days = @("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")
	$rand_day = (Get-Random -InputObject $days -Count 1)

	$hours = @("1am", "2am", "3am", "4am", "5am", "6am", "7am", "8am", "9am", "10am", "11am", "1pm", "2pm", "3pm", "4pm", "5pm", "6pm", "7pm", "8pm","9pm", "10pm", "11pm")
	$rand_hour = (Get-Random -InputObject $hours -Count 1)

	$trigger = @(
		$(New-ScheduledTaskTrigger  -Weekly -WeeksInterval 1 -DaysOfWeek $rand_day -At $rand_hour)
	)

	New-ScheduledTaskPrincipal -UserId chocoUpdater -RunLevel Highest
	Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "chocoUpdate" -Description "Daily checks for software updates." -user $user -password $password -RunLevel Highest

	Remove-Variable password
}

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Install Chocolatey Package Manager. It's not apt-get, but we are on Windows.. ¯\_(?)_/¯
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator"))
{
    # Start-Process powershell.exe -ExecutionPolicy Bypass -File
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit
}
Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing | iex
UpdateEnvironmentPath

choco feature enable -n allowGlobalConfirmation 
choco feature enable -n useRememberedArgumentsForUpgrades
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# General
choco install 7zip
choco install authy-desktop
choco install autohotkey
choco install bitwarden
choco install chocolatey-font-helpers.extension
#choco install chocolateygui --params "/DefaultToDarkMode"
choco install docker-desktop
#choco install edgedeflector
choco install exoduswallet
choco install ffmpeg
#choco install filezilla
choco install gimp
choco install gpu-z
choco install inkscape
choco install jetbrainsmono
choco install jetbrainstoolbox
choco install joplin
choco install mediainfo
choco install microsoft-windows-terminal
#choco install mkvtoolnix
#choco install msiafterburner
choco install notepadplusplus
choco install nvm
choco install obs-studio
choco install picard
choco install postman
#choco install powershell-core
#choco install putty
choco install qbittorrent
# RustDesk is like TeamViewer if TeamViewer wasn't buggy malware
#choco install rustdesk
# OSS alternative to Snagit
choco install sharex
choco install signal --params "/NoAutoUpdate /NoShortcut"
choco install smplayer
#choco install thunderbird --params "/NoTaskbarShortcut /NoDesktopShortcut /NoAutoUpdate"
choco install veracrypt
#Virtualbox installs using choco are extremely buggy when trying to upgrade, better off installing manually
#choco install virtualbox --params="/NoDesktopShortcut"
#choco install virtualbox-guest-additions-guest.install
choco install visualstudio2022community
choco install vlc
choco install vscode
choco install winscp
#choco install yarn
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# .Net SDK Setup & Disable Telemetry
choco install dotnet-sdk
[System.Environment]::SetEnvironmentVariable('DOTNET_CLI_TELEMETRY_OPTOUT', '1', 'Machine')

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# WSL Dev Environment Setup
# PREQs For Ideal WSL/DockerDesktop
# Make sure you have virtualization enabled in bios
# AMD  -> AMD-V
# Intel-> IntelVT
# ARM  -> If you're trying to run Windows on ARM don't bother with this script go install an OS that actually runs on ARM
# Or don't if you're into that, I'm not here to tell you which hill you're allowed to die on
# Enable WSL, then install distro, defaulted ubuntu. If upgrading WSL 1->2 uninstall currently installed distros and reinstall to avoid bugs
wsl --install
#choco uninstall wsl-ubuntu-2004
choco install wsl-ubuntu-2004

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Instal Git with Git and Unix tools added to PATH
choco install git.install --params "/GitAndUnixToolsOnPath /NoAutoCrlf /WindowsTerminalProfile /PseudoConsoleSupport"
UpdateEnvironmentPath
# Automatically create upstream branch for new locally created feature branches https://git-scm.com/docs/git-config#Documentation/git-config.txt-pushautoSetupRemote
git config --global push.autoSetupRemote true
# Have Linux line endings in text files
git config --global core.autocrlf input
# Allow support for paths more than 260 characters on Windows
git config --global core.longpaths true
# Install GitHub CLI
choco install gh
#choco install sourcetree
UpdateEnvironmentPath

# Install Azure Artifacts Credential Provider
# iex "& { $(irm https://aka.ms/install-artifacts-credprovider.ps1) } -AddNetfx"
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Install Major Browsers
#choco install brave
choco install Firefox --params "/NoAutoUpdate /NoDesktopShortcut /NoMaintenanceService /RemoveDistributionDir" 
choco install googlechrome
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Clean Chocolatey cache in free version
choco install choco-cleaner
C:\tools\BCURRAN3\choco-cleaner.ps1

# If you're into clutter comment out the next line
CleanupDesktopShortcuts

# If you want to schedule a regular update task to run at startup
#CreateScheduledUpdateTaskWithServiceUser

# Pause to look at all the damage you've done before reformating, joking. 
PAUSE