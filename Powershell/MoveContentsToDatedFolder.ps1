param (
    [string]$SourcePath = "",
    [string]$DestinationPath = ""
)

function CreateFoldersRecursivelyIfNotExist($path) {
    $global:foldPath = $null
    foreach($foldername in $path.split("\")) {
        $global:foldPath += ($foldername+"\")
        if (!(Test-Path $global:foldPath)){
            New-Item -ItemType Directory -Path $global:foldPath
        }
    }
}

$SourcePath = "$SourcePath\*"
$DestinationPath = "$DestinationPath\$((Get-Date).ToString('yyyy-MM-dd'))"

#Write-Host $SourcePath;
#Write-Host $DestinationPath;
#PAUSE

CreateFoldersRecursivelyIfNotExist($DestinationPath);
Move-Item -Path $SourcePath -Destination $DestinationPath