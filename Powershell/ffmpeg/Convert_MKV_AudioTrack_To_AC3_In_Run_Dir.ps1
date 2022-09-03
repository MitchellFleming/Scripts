$fromFomat = "mkv";
$converted = "-Converted";
$toFormat = "mkv";

foreach ($file in Get-ChildItem -Path ".\*.mkv")# -Recurse)
{
        $fileName = [System.IO.Path]::GetFileNameWithoutExtension("$file");
		$newFileName = "$fileName$converted.$toFormat"
		ffmpeg -i "$file" -map 0 -c:v copy -c:s copy -c:a eac3 -b:a 224k "$newFileName";
}
PAUSE