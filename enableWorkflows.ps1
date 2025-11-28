# Script to re-enable GitHub workflows by renaming .yml.disabled back to .yml

$workflowsPath = ".github/workflows"

# Workflows to exclude from enabling (work-in-progress or non-functional)
$excludedWorkflows = @(
	"make-release.yml.disabled"
)

if (-not (Test-Path $workflowsPath)) {
	Write-Error "Workflows directory not found: $workflowsPath"
	Read-Host -Prompt "Press Enter to continue"
	exit 1
}

$disabledWorkflows = Get-ChildItem -Path $workflowsPath -Filter "*.yml.disabled" | Where-Object { $excludedWorkflows -notcontains $_.Name }

if ($disabledWorkflows.Count -eq 0) {
	Write-Output "No disabled workflows found to enable."
	Read-Host -Prompt "Press Enter to continue"
	exit 0
}

$enabledCount = 0
foreach ($workflow in $disabledWorkflows) {
	$newName = $workflow.Name -replace "\.yml\.disabled$", ".yml"
	$newPath = Join-Path $workflowsPath $newName
	
	Rename-Item -Path $workflow.FullName -NewName $newName
	
	if ($?) {
		Write-Output "Enabled: $newName"
		$enabledCount++
	} else {
		Write-Error "Failed to enable: $($workflow.Name)"
	}
}

Write-Output ""
Write-Output "$enabledCount workflow(s) have been enabled."
Write-Output "Don't forget to commit the changes."
Read-Host -Prompt "Press Enter to continue"
exit 0
