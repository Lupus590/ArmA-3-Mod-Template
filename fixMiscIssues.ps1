param (
	[switch]$SkipPause = $false,
	[switch]$SkipPrompt = $false
)

if (-not $SkipPrompt)
{
	Write-Output "It is recommended to commit your existing work before running this script"
	$response = Read-Host "Are you sure that you want to run this script? (Y/N)"
	if ($response -ne "y" -or $response -ne "Y")
	{
		Write-Output "exiting without running fixes"
		exit
	}
}

Write-Output "Tidying up files"
if(Test-Path "./meta/tools/hemtt/hemtt.exe")
{
	./meta/tools/hemtt/hemtt.exe utils bom
	./meta/tools/hemtt/hemtt.exe ln sort
	./meta/tools/hemtt/hemtt.exe utils fnl
}
else
{
	hemtt utils bom
	hemtt ln sort
	hemtt utils fnl
}

Write-Output "Attempting to fix possible git lfs issues"
git lfs fsck
git lfs fetch --all
git lfs pull

if(-not $SkipPause)
{
	Pause
}
