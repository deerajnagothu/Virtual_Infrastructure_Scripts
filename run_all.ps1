$executingScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
    
$mult=1        #create VMs in batches of size $mult
$total=1       #total number of VMs needed
$index_base=100# the minimal number from where indexing will start will be ($index_base+1)
$slices=$total/$mult
ForEach ( $ququ in 0..($slices-1)) 
{
   $start= $ququ*$mult+($index_base+1)
   $end=($ququ+1)*$mult+$index_base

   $scriptPath1 = Join-Path $executingScriptDirectory "constants.ps1"
   $scriptPath2 = Join-Path $executingScriptDirectory "common_functions.ps1"
   


    
    . $scriptPath1
    . $scriptPath2
    Yo "Slicing from $start to $end"
    $scriptPath3 = Join-Path $executingScriptDirectory "populate_vapps.ps1"
    . $scriptPath3
    $scriptPath4 = Join-Path $executingScriptDirectory "remap_networking.ps1"
    . $scriptPath4
    $scriptPath5 = Join-Path $executingScriptDirectory "populate_windows_gateways.ps1"
    . $scriptPath5

    $scriptPath6 = Join-Path $executingScriptDirectory "snapshot_student_vapps.ps1"
    . $scriptPath6

   
}

Wait-A-Min -Time 1
Start-VApp -VApp $ContainerVAppName
exit


exit

$indicies = $start..$end
ForEach ( $index in $indicies) 
{
    $selector=$index%$vmhosts.Count
    $vmhost=$vmhosts[$selector]
    $vm_to_move=(Get-VM -Name $ClonedVMPrefix$_)
    if ($vm_to_move.VMHost -EQ $vmhost ) 
    {
        Write-Host "same host"
        }
    else{
        Write-Host "Moving $vm_to_move to different host $vmhost"
        Move-VM -VM $vm_to_move -Destination $vmhost
    }
}