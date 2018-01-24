
$executingScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$scriptPath1 = Join-Path $executingScriptDirectory "constants.ps1"
$scriptPath2 = Join-Path $executingScriptDirectory "common_functions.ps1"
. $scriptPath1
. $scriptPath2

#----------------------------------------------
$ClonedVMPrefix=$win7_Name_Prefix
$OriginVMName= $win7_Name_Prefix

# Give the custom MAC address for the network adapter
$InternetFacingMACPrefix=""
$LocalFacingMACPrefix=""

#------------------------------------------

$container_vapp=Get-VApp -Name $ContainerVAppName -ErrorAction Stop
Yo "Container vapp found $container_vapp"

$origin_vm=Get-VM -Name $OriginVMName -Location $SourceVappName -ErrorAction Stop
Yo "Origin VM found $origin_vm"
$origin_vm_snapshot= Get-Snapshot -VM $origin_vm -Name $ReferenceSnapshotName  -ErrorAction Stop
Yo "Origin VM snapshot found $origin_vm_snapshot"





#if new snapshot is needed before cloning uncomment line below
#$oSnapshot= New-Snapshot -VM $sOriginVM -Name $sOriginVMSnapshotName -Description "Snapshot for linked Clone" -Memory -Quiesce


$indicies = $start..$end

#ForEach -Parallel ( $index in $indicies) 
ForEach ( $index in $indicies) 
   { 

    $StudentVAppName=$StudentVAppPrefix+$index

    $student_vapp=Get-VApp -Name $StudentVAppName -Location $container_vapp -ErrorAction Stop
    Yo "Student sub-container vapp found $container_vapp"

    # Deleting all previous VMs
    Yo "Deleting known previous VMs"

    ForEach ($vm_to_delete in (Get-VM -Name $ClonedVMPrefix* -Location $student_vapp)) 
    {
        Delete-Known-VM -VM $vm_to_delete
    }

    $selector=$index%$vmhosts.Count
    $vmhost=$vmhosts[$selector]
    Yo "`tCloning with selected VMHost $vmhost"
    $new_vm_name=(GetStudentVMName $origin_vm -index $index)   
          
    Yo "Cloning $origin_vm to $new_vm_name"
    
    $new_vm=New-VM -Name $new_vm_name -VMHost $vmhost -VM $origin_vm  -Location $vm_folder -ResourcePool $student_vapp -Datastore $datastore_seclab -LinkedClone -ReferenceSnapshot $origin_vm_snapshot -ErrorAction Stop
    
    $net_name=$net_name=(ExpandNetworkName $StudentControlNetwork $index)

    Update-MAC-VM -VM $new_vm -NetworkName $OLD_InternetFacingNetworkName_Windows -MACAddress (ExpandMAC -Prefix $InternetFacingMACPrefix -index $index)
    Update-Net-VM -VM $new_vm -OldNetworkName $OLD_InternetFacingNetworkName_Windows -NewNetworkName $net_name

    $net_name=(ExpandNetworkName $StudentMainNetworkPrefix $index)
    Update-MAC-VM -VM $new_vm -NetworkName $OLD_LocalFacingNetworkName_Windows -MACAddress (ExpandMAC -Prefix $LocalFacingMACPrefix -index $index)
    Update-Net-VM -VM $new_vm -OldNetworkName $OLD_LocalFacingNetworkName_Windows -NewNetworkName $net_name
   
}

ForEach ( $index in $indicies) {
    $new_vm=Get-VM -Name (GetStudentVMName $origin_vm -index $index) -ErrorAction Stop

    Yo "Starting VM $new_vm"
    $started_vm=Start-VM $new_vm -ErrorAction Stop |Wait-Tools
    Yo "I think VM $new_vm has started as $started_vm"
    Wait-A-Min -Time 1

    Change-Static-IP-Inside-VM -VM $started_vm -MACAddress (ExpandMAC -Prefix $LocalFacingMACPrefix -index $index) -NewIP ""
    Change-Static-IP-Inside-VM -VM $started_vm -MACAddress (ExpandMAC -Prefix $InternetFacingMACPrefix -index $index) -NewIP (""+$index+"")
    Change-Static-Gateway-Inside-VM -VM $started_vm -MACAddress (ExpandMAC -Prefix $InternetFacingMACPrefix -index $index) -GatewayIP (""+$index+"")
    Change-Password-for-windows -VM $started_vm -user_password $index
    Wait-A-Min -Time 1

    Shutdown-VMGuest -VM $new_vm  -Confirm:$false -ErrorAction Continue 
}


