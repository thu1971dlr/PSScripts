#requires -version 5.1
<#
.Synopsis
	Index the contents of a directory to a text file

.Description
	Index the contents of a directory to a text file. The output is tab delimited
	and contains the following columns:
	- LastWriteTime
	- Length
	- FullName

	By default, the current drive is indexed. Use the DriveLetter parameter to
	specify a different drive.

	By default, the index file is written to the current directory. Use the
	TargetDirectory parameter to specify a different directory.

	Note: The index file is encoded using UTF8 without BOM.

.Author
	Thomas Urlings

.Parameter DriveLetter
	The drive letter of the drive to index. If not specified, the current drive is
	used.

.Parameter TargetDirectory
	The directory to write the index file to.

.Example
	Index-Directory -DriveLetter "D:" -TargetDirectory "C:\Temp"

.Version 1.0
#>

[CmdletBinding()]
param(
	[Parameter(Mandatory = $false)]
	[string]$DriveLetter,

	[Parameter(Mandatory = $true)]
	[string]$TargetDirectory
)

$UICulture = "en-US"
Write-Verbose "Selcted UI Culture: $UICulture"

# If no drive letter specified, use the current drive
if (-not $DriveLetter) {
	$DriveLetter = (Get-Location).Drive.Name + ":"
}

# Get the volume details
$volume = Get-Volume -DriveLetter $DriveLetter[0]

# Get the serial number using dir command
$dirOutput = cmd /c dir $DriveLetter
$serial = ($dirOutput -split "`n")[1].Trim().Split(" ")[-1]

# Combine label and serial to form filename
$filename = "{0}_{1}" -f $volume.FileSystemLabel, $serial

$IndexDir=Join-Path -Path $TargetDirectory -ChildPath "index"

# Create full file path
$filePath = Join-Path -Path $IndexDir -ChildPath ($filename + '.txt')

Write-Host "$filePath"

# Get directory structure and output to file
$directoryStructure = Get-ChildItem -Path $DriveLetter -Recurse |
	ForEach-Object {
	"{0}`t{1}`t{2}" -f $_.LastWriteTime, $_.Length, $_.FullName
}

# Convert output to UTF8 without BOM and write to file
[System.IO.File]::WriteAllLines(
	$filePath, $directoryStructure, [System.Text.Encoding]::UTF8
)

# if the directory contrains a folder VIDEO_TS, create a directory in
# r"w:\FilmsDVDs\#\" with the name from the label and the serial number and copy
# all files from the device into that directory
if (Test-Path -Path "$DriveLetter\VIDEO_TS") {
	$targetPath = Join-Path -Path $TargetDirectory -ChildPath "#"
	$targetPath = Join-Path -Path $targetPath -ChildPath $volume.FileSystemLabel
	$targetPath = Join-Path -Path $targetPath -ChildPath $serial

	# Create target directory if it doesn't exist
	if (-not (Test-Path -Path $targetPath)) {
		New-Item -Path $targetPath -ItemType Directory
	}

	# Copy files, without overwrite existing files
	Copy-Item -Path "$DriveLetter\*" -Destination $targetPath -Recurse `
		-ErrorAction SilentlyContinue -Verbose

}
