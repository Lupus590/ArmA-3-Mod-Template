# Script to convert logo.paa back to a Git LFS object
function Pause-If-FromExplorer {
    try {
        $ppid = (Get-CimInstance Win32_Process -Filter "ProcessId = $PID").ParentProcessId
        $parent = Get-Process -Id $ppid -ErrorAction SilentlyContinue
        if ($parent -and $parent.ProcessName -in @('explorer', 'Explorer')) {
            Write-Host ''
            Read-Host 'Press Enter to close this window'
        }
    } catch { }
}

# Track *.paa files with Git LFS
git lfs track "*.paa"

if($LASTEXITCODE -ne 0)
{
	Write-Error "Failed to track *.paa with Git LFS"
	Pause-If-FromExplorer
	exit $LASTEXITCODE
}

# Re-add logo.paa so it gets converted to LFS
git rm --cached logo.paa

if($LASTEXITCODE -ne 0)
{
	Write-Error "Failed to remove logo.paa from cache"
	Pause-If-FromExplorer
	exit $LASTEXITCODE
}

git add logo.paa

if($LASTEXITCODE -ne 0)
{
	Write-Error "Failed to add logo.paa to Git LFS"
	Pause-If-FromExplorer
	exit $LASTEXITCODE
}

Write-Output "logo.paa has been converted to a Git LFS object"
Write-Output "Don't forget to commit the changes (.gitattributes and logo.paa)"
Pause-If-FromExplorer
exit 0
