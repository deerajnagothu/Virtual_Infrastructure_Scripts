
#-----------------------Connection Constants
$DatacenetrName=""
$ClusterName=""
$DatastoreFolderName=""
$VMFolderName=""


#-----------------------VApp and VM contants
# Change the variable based on the VM names in the VApp
$SourceVappName=""
#$ContainerVAppName=$SourceVappName+"_container"
$ContainerVAppName=""
$ReferenceSnapshotName=""
$StudentVAppPrefix=""
$ESX_Name_Prefix=""
$VCenter_Name_Prefix=""
$N1KV_Name_Prefix=""
$win7_Name_Prefix=""

#-----------------------Network constants
# Use the networking port-profiles used for the above mentioned VM's
$StudentMainNetworkPrefix=""       #these are main experimental studetn netwrorks connecting Windows, nexus, esx and vcenter 
$StudentTaggedNetworkPrefix=""     #these are tagged networks of main networks (tagged version of main netwrok for ESX)
$StudentControlNetwork=""   #these are the networks between control windows and vyos
$ReferenceNetworkPrefix=""
$ReferenceTaggedNetworkPrefix=""

$OLD_InternetFacingNetworkName_Windows=""
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

