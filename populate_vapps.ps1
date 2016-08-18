$executingScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$scriptPath1 = Join-Path $executingScriptDirectory "constants.ps1"
$scriptPath2 = Join-Path $executingScriptDirectory "common_functions.ps1"
. $scriptPath1
. $scriptPath2

$VMPostfix=$StudentVAppPrefix #gets added to the each VM name in the end. So for the student VApp Lab1 student vms will look like ESXi_LAb1 Windows_Lab1 etc.

#------------------------------------------


#Find source vapp. Stop if not found
$source_vapp = Get-VApp -Name $SourceVappName -ErrorAction Stop
Yo "Source VApp: $source_vapp"

#Create destination container vapp. This vapp will contain all student vapps.
Yo "Create or find container VApp to put all the lab in: $ContainerVAppName" 

$container_vapp=Get-VApp -Name $ContainerVAppName -ErrorAction SilentlyContinue
if (!$container_vapp){
    Yo "`t$ContainerVAppName doesn't exist. Creating ..." 
    $container_vapp=New-VApp -Name $ContainerVAppName -Location $cluster -ErrorAction Stop

}
else{
    Yo "`tFound existing container vapp $container_vapp" 
}

Yo "Perform VApp cloning $source_vapp to container $container_vapp"

$indicies = $start..$end
ForEach ( $index in $indicies) 
   { 
    $selector=$index%$vmhosts.Count
    $vmhost=$vmhosts[$selector]
    Yo "`tCloning into: $vmhost"

    $StudentVAppName=$StudentVAppPrefix+$index

    # Deleting previous VApp
    $student_vapp=Get-VApp -Name $StudentVAppName -Location $container_vapp -ErrorAction SilentlyContinue
    if ($student_vapp){
        Yo "`t$Dound existing student VApp $student_vapp Deleting ..." 
        Stop-VApp $student_vapp -Force  -Confirm:$false -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
        Sleep 2
        Remove-VApp -DeletePermanently $student_vapp -Confirm:$false -ErrorAction Stop -WarningAction SilentlyContinue
        Sleep 2
    }
    Yo "`tCreating student VApp $StudentVAppName"
    $student_vapp=New-VApp -Name $StudentVAppName -Location $container_vapp -ErrorAction Stop 
    Get-VM -Location $source_vapp | foreach {
        $srcVM=$_
        #$dstVMName=$srcVM.Name+"_"+$VMPostfix+$index
        $dstVMName=(GetStudentVMName -OriginVM $srcVM -index $index)
        Yo "`t`tCloning $srcVM to $dstVMName on $vmhost"    

        #$vm_object= New-VM -Name $dstVMName -VM $srcVM -VMHost $vmhost -Location $oVcenterFolder -ResourcePool  $student_vapp -LinkedClone -ReferenceSnapshot $ReferenceSnapshotName         
        $vm_object= New-VM -Name $dstVMName -VM $srcVM -VMHost $vmhost -ResourcePool $student_vapp -Location $vm_folder -Datastore $datastore_seclab -LinkedClone -ReferenceSnapshot $ReferenceSnapshotName  -RunAsync        
    }
}


