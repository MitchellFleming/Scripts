$toFormat = "mkv";

foreach ($file in Get-ChildItem -Path ".\*.mkv")# -Recurse)
{
        $fileName = [System.IO.Path]::GetFileNameWithoutExtension("$file");
		$newname = ([String]$fileName).Replace("264","265");
		$newFileName = "$newname.$toFormat";
		ffmpeg -i "$file" -map 0 -c:v libx265 -vtag hvc1 -c:s copy -c:a copy "$newFileName"
}
PAUSE