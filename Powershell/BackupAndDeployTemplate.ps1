# If you have been told that you're NOT ALLOWED to put a deployment pipeline in place for a deployment.. 
$testMode = 1

if($testMode -ne 0)
{
	$appFolderName = ""
	$backupAndDeployPath = ""
	$destination = ""
}
else
{
	$appFolderName = ""
	$backupAndDeployPath = ""
	$destination = ""
}
$source = ""

$dateString = Get-Date -Format "yyyy-MM-dd"
$dateFolderString = $dateString
$thisBackupAndDeployPath = $backupAndDeployPath + "\" + $dateFolderString
$bdBackupDestination = $thisBackupAndDeployPath + "\Backup"
$bdDeployDestination = $thisBackupAndDeployPath + "\Deploy"

$folderCreated = 0

while ($folderCreated -ne1) 
{
	if(!(Test-Path -LitteralPath $thisBackupAndDeployPath))
	{
		New-Item -ItemType Directory -Path $backupAndDeployPath -Name $dateFolderString
		
		$bdBackupDestination = $thisBackupAndDeployPath + "\Backup"
		$bdDeployDestination = $thisBackupAndDeployPath + "\Deploy"
		
		New-Item -ItemType Directory -Path $thisBackupAndDeployPath -Name "Backup"
		New-Item -ItemType Directory -Path $thisBackupAndDeployPath -Name "Deploy"
		New-Item -ItemType Directory -Path $bdDeployDestination -Name $appFolderName
		$bdDeployDestination = $bdDeployDestination + "\" + $appFolderName
		
		$folderCreated = 1
	}
	else
	{
		$incrementForFolder++
		$dateFolderString = $dateString + "_" + $incrementForFolder
		$thisBackupAndDeployPath = $backupAndDeployPath + "\" + $dateFolderString
	}
}

# Copy all items from the destination folder to b&d backup
Copy-Item -LitteralPath $destination -Recurse -Destination $bdBackupDestination
# Clean the destination folder
Get-ChildItem -LitteralPath $destination -Recurse -Force | Remove-Item -Force -Recurse
# Copy all items from the source folder to b&d deploy
Get-ChildItem -LitteralPath $source -Recurse | Copy-Item -Recurse -Destination $bdDeployDestination
# Copy all items from the source folder to destination
Get-ChildItem -LitteralPath $source -Recurse | Copy-Item -Recurse -Destination $destination





