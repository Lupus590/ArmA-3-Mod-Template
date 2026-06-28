# Setup script that enables GitHub workflows and converts to LFS
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

Write-Output "Running setup..."
Write-Output ""

# Enable workflows
Write-Output "Step 1: Enabling GitHub workflows..."
& "$PSScriptRoot/enableWorkflows.ps1"
if ($LASTEXITCODE -ne 0) {
	Write-Error "enableWorkflows.ps1 failed, aborting setup."
	Pause-If-FromExplorer
	exit $LASTEXITCODE
}

Write-Output ""

# Convert to LFS
Write-Output "Step 2: Converting to Git LFS..."
& "$PSScriptRoot/convertToLFS.ps1"
if ($LASTEXITCODE -ne 0) {
	Write-Error "convertToLFS.ps1 failed, aborting setup."
	Pause-If-FromExplorer
	exit $LASTEXITCODE
}

Write-Output ""
Write-Output "Setup complete!"
Write-Output "Don't forget to commit the changes."
Pause-If-FromExplorer
exit 0
