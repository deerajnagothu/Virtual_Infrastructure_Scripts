$executingScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$scriptPath1 = Join-Path $executingScriptDirectory "constants.ps1"
$scriptPath2 = Join-Path $executingScriptDirectory "common_functions.ps1"
. $scriptPath1
. $scriptPath2



$VMPostfix=$StudentVAppPrefix

$vapp=Get-VApp -Name $ContainerVAppName -ErrorAction Stop

$indicies = $start..$end
ForEach ( $index in $indicies) {
#for ESXi
    $vm=Get-VM -Name (GetStudentVMName $ESX_Name_Prefix $index) -ErrorAction Stop
    Yo "Get host vm $vm"

    $net_name=(ExpandNetworkName $StudentMainNetworkPrefix $index)
    Yo "Searching for adapter $ReferenceNetworkPrefix in $vm"
    $nwadap=(Get-NetworkAdapter -VM $vm) | Where-Object -Property NetworkName -EQ -Value  $ReferenceNetworkPrefix  -ErrorAction Stop
    Yo "Setting network $net_name for $nwadap"
    Set-NetworkAdapter -NetworkAdapter $nwadap -NetworkName $net_name  -Confirm:$false

    $nwadap=(Get-NetworkAdapter -VM $vm) | Where-Object -Property NetworkName -EQ -Value $ReferenceTaggedNetworkPrefix -ErrorAction Stop
    Yo "Setting network $(ExpandNetworkName $StudentTaggedNetworkPrefix $index) for $nwadap"
    Set-NetworkAdapter -NetworkAdapter $nwadap -NetworkName (ExpandNetworkName $StudentTaggedNetworkPrefix $index)  -Confirm:$false

#for Vcenter
    $vm=Get-VM -Name (GetStudentVMName $VCenter_Name_Prefix $index) -ErrorAction Stop
    Yo "Get host vm $vm"
    $nwadap=(Get-NetworkAdapter -VM $vm) | Where-Object -Property NetworkName -EQ -Value $ReferenceNetworkPrefix  -ErrorAction Stop 
    Yo "Setting network $net_name for $nwadap"
    Set-NetworkAdapter -NetworkAdapter $nwadap -NetworkName $net_name  -Confirm:$false
#for Nexus
    $vm=Get-VM -Name (GetStudentVMName $N1KV_Name_Prefix $index) -ErrorAction Stop
    Yo "Get host vm $vm"

    $nwadap_1=(Get-NetworkAdapter -VM $vm) | Where-Object -Property NetworkName -EQ -Value $ReferenceNetworkPrefix   -ErrorAction Stop 
    Yo "Setting network $net_name for $nwadap_1"
    Set-NetworkAdapter -NetworkAdapter $nwadap_1 -NetworkName $net_name  -Confirm:$false
    #$nwadap_2=(Get-NetworkAdapter -VM $vm) | Where-Object -Property NetworkName -EQ -Value $ReferenceNetworkPrefix -ErrorAction Stop 
    #Yo "Setting network $net_name for $nwadap_2"
    #Set-NetworkAdapter -NetworkAdapter $nwadap_2 -NetworkName $net_name  -Confirm:$false
    #$nwadap_3=(Get-NetworkAdapter -VM $vm) | Where-Object -Property NetworkName -EQ -Value $ReferenceNetworkPrefix -ErrorAction Stop 
    #Yo "Setting network $net_name for $nwadap_3"
    #Set-NetworkAdapter -NetworkAdapter $nwadap_3 -NetworkName $net_name  -Confirm:$false


}
