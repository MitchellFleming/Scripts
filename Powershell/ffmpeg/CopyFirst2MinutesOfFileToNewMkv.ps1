$toFileAddString = "-2Minutes";
$toFormat = "mkv";

foreach ($file in Get-ChildItem -Path ".\*.mkv") 
{
        $fileName = [System.IO.Path]::GetFileNameWithoutExtension("$file");
		$newname = ([String]$fileName).Replace("264","265");
		$newFileName = "$fileName$toFileAddString.$toFormat"
		ffmpeg -i "$file" -map 0 -c:v copy -c:s copy -c:a copy -ss 00:00:00 -t 120 "$newFileName"
		#ffmpeg -ss 00:00:03 -i inputVideo.mp4 -to 00:00:08 -c:v copy -c:a copy trim_ipseek_copy.mp4
}
PAUSE