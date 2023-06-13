#requires -version 5.1

<# .SYNOPSIS A script to extract images from a video file using ffmpeg

.DESCRIPTION This script extracts images (keyframes) from a video file, with
	options to specify the start time and duration of the video clip as well as
	the output file prefix.

.PARAMETER VideoPath The mandatory path to the video file to be processed.
	Must be a valid file path. Aliased as "Path".

.PARAMETER StartTime The optional start time of the video clip from which to
	extract images.
	Must be in the format of hh:mm:ss, mm:ss, or ss. Aliased as "Start".

.PARAMETER Duration The optional duration of the video clip from which to
	extract images.
	Must be in the format of hh:mm:ss, mm:ss, or ss. Aliased as "Dur".

.PARAMETER OutputPrefix The optional prefix for the extracted image files.
	Aliased as "Prefix".

.EXAMPLE PS C:> .\ExtractImages.ps1 -VideoPath "myVideo.mp4"
	-StartTime "0:00:30" -Duration "0:00:10" -OutputPrefix "frame"

	This command will extract images from the video myVideo.mp4 starting at
	0:00:30 for a duration of 0:00:10 using the prefix "frame".
#>

[CmdletBinding()]
param (
	[Parameter(Mandatory = $true, HelpMessage = "Path to the video file.")]
	[ValidateScript({ Test-Path $_ -PathType Leaf })]
	[Alias("Path")]
	[string]$VideoPath,

	[Parameter(HelpMessage = "Start time of the video clip.")]
	[Alias("Start")]
	[ValidatePattern("^([0-9]+:){0,2}[0-9]+$")]
	[string]$StartTime,

	[Parameter(HelpMessage = "Duration of the video clip.")]
	[Alias("Dur")]
	[ValidatePattern("^([0-9]+:){0,2}[0-9]+$")]
	[string]$Duration,

	[Parameter(HelpMessage = "Prefix for the image files.")]
	[Alias("Prefix")]
	[string]$OutputPrefix
)


try {
	# PowerShell script to force the language to English (en-US)
	$CurrentThread = [System.Threading.Thread]::CurrentThread
	$GetCultureInfo = [System.Globalization.CultureInfo]::GetCultureInfo
	$CurrentThread.CurrentCulture = $GetCultureInfo.Invoke("en-US")
	$CurrentThread.CurrentUICulture = $GetCultureInfo.Invoke("en-US")

	$ffmpegParams = @()

	$ffmpegParams += "-loglevel"
	$ffmpegParams += "level+verbose"
	$ffmpegParams += "-hwaccel"
	$ffmpegParams += "auto"

	if ($StartTime) {
		$ffmpegParams += "-ss"
		$ffmpegParams += $StartTime
		$ffmpegParams += "-i"
		$ffmpegParams += "`"$VideoPath`""
		$ffmpegParams += "-ss"
		$ffmpegParams += "0:00:01"
	} else {
		$ffmpegParams += "-i"
		$ffmpegParams += "`"$VideoPath`""
	}

	if ($Duration) {
		$ffmpegParams += "-t"
		$ffmpegParams += $Duration
	}

	$ffmpegParams += "-vf"
	$ffmpegParams += "`"select=eq(pict_type\,I)`""
	$ffmpegParams += "-vsync"
	$ffmpegParams += "vfr"

	$OutputPrefix = $OutputPrefix.TrimEnd('\')

	$OutputPattern = Join-Path -Path $PWD -ChildPath ("$OutputPrefix%06d.png")

	$ffmpegParams += "`"$OutputPattern`""

	$ffmpeg = "$env:SystemDrive\bin\ffmpeg.exe"

	& $ffmpeg @ffmpegParams
} catch {
	##output all error information
	$_.Exception | Format-List -Force
	$_.InvocationInfo | Format-List -Force
}


<#
## References

- [ffmpeg Documentation](https://ffmpeg.org/documentation.html)
- [ffmpeg Wiki](https://trac.ffmpeg.org/wiki)
- [ffmpeg Protocols Documentation](https://ffmpeg.org/ffmpeg-protocols.html)
- [ffmpeg Formats Documentation](https://ffmpeg.org/ffmpeg-formats.html)
- [ffmpeg Codecs Documentation](https://ffmpeg.org/ffmpeg-codecs.html)
- [ffmpeg Filters Documentation](https://ffmpeg.org/ffmpeg-filters.html)
- [ffmpeg Utilities Documentation](https://ffmpeg.org/ffmpeg-utils.html)
- [ffmpeg Wiki: H.264 Encoding Guide](https://trac.ffmpeg.org/wiki/Encode/H.264)
- [ffmpeg Wiki: H.264 Decoding Guide](https://trac.ffmpeg.org/wiki/Decode/H.264)
- [ffmpeg Wiki: HEVC Encoding Guide](https://trac.ffmpeg.org/wiki/Encode/H.265)
- [ffmpeg Wiki: HEVC Decoding Guide](https://trac.ffmpeg.org/wiki/Decode/H.265)
- [ffmpeg Wiki: AAC Encoding Guide](https://trac.ffmpeg.org/wiki/Encode/AAC)
- [ffmpeg Wiki: AAC Decoding Guide](https://trac.ffmpeg.org/wiki/Decode/AAC)
- [ffmpeg Wiki: AAC - Advanced Audio Coding](https://trac.ffmpeg.org/wiki/Encode/AAC#AdvancedAudioCoding)
- [ffmpeg Wiki: MP3 Encoding Guide](https://trac.ffmpeg.org/wiki/Encode/MP3)
- [ffmpeg Wiki: MP3 Decoding Guide](https://trac.ffmpeg.org/wiki/Decode/MP3)
- [ffmpeg Wiki: MP3 - MPEG Layer III Audio](https://trac.ffmpeg.org/wiki/Encode/MP3#MPEGLayerIIIAudio)
- [ffmpeg Wiki: MP2 Encoding Guide](https://trac.ffmpeg.org/wiki/Encode/MP2)
- [ffmpeg Wiki: MP2 Decoding Guide](https://trac.ffmpeg.org/wiki/Decode/MP2)
- [ffmpeg Wiki: MP2 - MPEG Layer II Audio](https://trac.ffmpeg.org/wiki/Encode/MP2#MPEGLayerIIAudio)
- [ffmpeg Wiki: AC3 Encoding Guide](https://trac.ffmpeg.org/wiki/Encode/AC3)
- [ffmpeg Wiki: AC3 Decoding Guide](https://trac.ffmpeg.org/wiki/Decode/AC
#>
# End of script ################################################################