$fromFomat = "mp4";
$toFormat = "m4a";
foreach ($file in Get-ChildItem -Path ".\*.$fromFomat")# -Recurse)
{
        $fileName = [System.IO.Path]::GetFileNameWithoutExtension("$file");
		ffmpeg -i "$file" -vn -c:a copy "$fileName.$toFormat";
}
PAUSE