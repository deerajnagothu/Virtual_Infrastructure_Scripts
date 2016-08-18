#Snapshot everything

$executingScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$scriptPath1 = Join-Path $executingScriptDirectory "constants.ps1"
$scriptPath2 = Join-Path $executingScriptDirectory "common_functions.ps1"
. $scriptPath1
. $scriptPath2

$indicies = $start..$end
ForEach ( $index in $indicies) 
   { 
    $StudentVAppName=$StudentVAppPrefix+$index

    # Deleting previous VApp
    $student_vapp=Get-VApp -Name $StudentVAppName -Location $container_vapp -ErrorAction Stop
    SnapshotVApp -VApp $student_vapp -SnapshotName "Vanilla"
}