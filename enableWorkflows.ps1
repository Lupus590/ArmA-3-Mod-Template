# Script to re-enable GitHub workflows by renaming .yml.disabled back to .yml
# Note: .yml.wip files are work-in-progress workflows and will not be enabled by this script
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

$workflowsPath = ".github/workflows"

if (-not (Test-Path $workflowsPath)) {
	Write-Error "Workflows directory not found: $workflowsPath"
	Pause-If-FromExplorer
	exit 1
}

$disabledWorkflows = Get-ChildItem -Path $workflowsPath -Filter "*.yml.disabled"

if ($disabledWorkflows.Count -eq 0) {
	Write-Output "No disabled workflows found to enable."
	Pause-If-FromExplorer
	exit 0
}

$enabledCount = 0
$failedCount = 0
foreach ($workflow in $disabledWorkflows) {
	$newName = $workflow.Name -replace "\.yml\.disabled$", ".yml"
	$newPath = Join-Path $workflowsPath $newName
	try {
		Rename-Item -Path $workflow.FullName -NewName $newName -ErrorAction Stop
		Write-Output "Enabled: $newName"
		$enabledCount++
	} catch {
		Write-Error "Failed to enable: $($workflow.Name)"
		$failedCount++
	}
}

Write-Output ""
Write-Output "$enabledCount workflow(s) have been enabled."
if ($failedCount -gt 0) {
	Write-Output "$failedCount workflow(s) failed to enable."
}
Write-Output "Don't forget to commit the changes."
Pause-If-FromExplorer
exit 0
