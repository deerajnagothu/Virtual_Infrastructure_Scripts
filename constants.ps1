
#-----------------------Connection Constants
$DatacenetrName="Watson School"
$ClusterName="Andrey Sec Lab"
$DatastoreFolderName="Sec Lab Data"
$VMFolderName="Sec Lab VMs"


#-----------------------VApp and VM contants
$SourceVappName="Lab12_Reference_Nexus"
#$ContainerVAppName=$SourceVappName+"_container"
$ContainerVAppName="Testing_Container"
$ReferenceSnapshotName="Point_zero"
$StudentVAppPrefix="STU"
$ESX_Name_Prefix="ESXi_cns_lab"
$VCenter_Name_Prefix="Vcenter_cns_lab"
$N1KV_Name_Prefix="Nexus_cns_lab"
$win7_Name_Prefix="Win7_cns_lab"

#-----------------------Network constants
$StudentMainNetworkPrefix="stu_net_"       #these are main experimental studetn netwrorks connecting Windows, nexus, esx and vcenter 
$StudentTaggedNetworkPrefix="stu_t_"     #these are tagged networks of main networks (tagged version of main netwrok for ESX)
$StudentControlNetwork="windows"   #these are the networks between control windows and vyos
$ReferenceNetworkPrefix="reference_1"
$ReferenceTaggedNetworkPrefix="reference_1_trunk"

$OLD_InternetFacingNetworkName_Windows="VLAN76"
$OLD_LocalFacingNetworkName_Windows=$ReferenceNetworkPrefix

#-----------------------Number of items





#------------------------------------------------------
#
#------------------Get some system info

$datacenter=Get-Datacenter $DatacenetrName
Write-Host "Datacenter: $datacenter"

$datastore_folder=Get-Folder $DatastoreFolderName -Type Datastore -Location $datacenter

$cluster=Get-Cluster -Name $ClusterName
Write-Host "Cluster: $cluster"

#$resourcepool=Get-ResourcePool -Name "Resources"
#Write-Host "Resource pool: $resourcepool"

$vmhosts = (Get-VMHost -Location $cluster) | Sort-Object -Property Name -Descending
Write-Host "Available VMHosts $vmhosts"

$datastores=Get-Datastore -Location $datastore_folder
Write-Host "Datastores: $datastores" 

$vm_folder=Get-Folder $VMFolderName -Type VM -Location $datacenter
Write-Host "Folder: $vm_folder"

$datastore_seclab= Get-Datastore -Name "sec-lab-SAS"     # this is used to get sec-lab datastore for machines to be created on this datastore
Write-Host "Network Datastore: $datastore_seclab" 

