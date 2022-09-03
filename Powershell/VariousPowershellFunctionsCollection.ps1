#---------------------------------------------------------------------------------------------------------------------------
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
# Implementation Example 
<#
	CleanupDesktopShortcuts
#>
#---------------------------------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------------------
function CreateFoldersRecursivelyIfNotExist($path) {
    $global:foldPath = $null
    foreach($foldername in $path.split("\")) {
        $global:foldPath += ($foldername+"\")
        if (!(Test-Path $global:foldPath)){
            New-Item -ItemType Directory -Path $global:foldPath
        }
    }
}
# Implementation Example 
<#
	$SourcePath = "C:\Temp\TestFolderOne\*"
	$DestinationPath = "C:\Temp\TestFolderTwo\$((Get-Date).ToString('yyyy-MM-dd'))"
	CreateFoldersRecursivelyIfNotExist($SourcePath);
	CreateFoldersRecursivelyIfNotExist($DestinationPath);
	Move-Item -Path $SourcePath -Destination $DestinationPath
#>
#---------------------------------------------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------------------------------------------
function UpdateEnvironmentPath
{
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") `
          + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}
# Implementation Example 
<#
	UpdateEnvironmentPath
#>
#---------------------------------------------------------------------------------------------------------------------------