#Write-Host -ForegroundColor White "Begin Common Functions!!!"

function Resolve-Error ($ErrorRecord=$Error[0])
{
   $ErrorRecord | Format-List * -Force
   $ErrorRecord.InvocationInfo |Format-List *
   $Exception = $ErrorRecord.Exception
   for ($i = 0; $Exception; $i++, ($Exception = $Exception.InnerException))
   {   "$i" * 80
       $Exception |Format-List * -Force
   }
}

function Yo
{
    param([string]$message)
    Write-Host -ForegroundColor DarkGray "$message"
}

function YoInt
{
    param([string]$message)
    Write-Host -ForegroundColor DarkYellow "`t$message"
}

function FailIfEmpty
{ param([object]$some_object)
    if ($some_object){
        $some_object
    }
    else{
        throw "Epty object. can not continue"
    }
}

function GetStudentVMName
{
    param([string]$OriginVM,
            [int]$index)
    $result=$OriginVM+"_"+$StudentVAppPostfix+"_"+$index
    $result
}

function ExpandMAC
{
    param([string]$Prefix,           
            [int]$index)
    $mactxt="{0:D2}" -f ($index-100)
    $mactxt=($Prefix+$mactxt)   
    $mactxt 
}

function ExpandNetworkName
{
    param([string]$Prefix,           
            [int]$index)
    $netname=$Prefix+$index
    $netname
}

function Delete-Known-VM
 {
   param([Object]$VM)
    YoInt "Stopping VM $VM"
    Stop-VM $VM -Confirm:$false -ErrorAction SilentlyContinue
    Sleep 2
    YoInt "Deleting VM $VM"
    Remove-VM -DeletePermanently $VM -Confirm:$false -ErrorAction Stop
 }


function Update-MAC-VM
{
   param([Object]$VM,
         [string]$NetworkName,
         [string]$MACAddress
   )
 
   $nwadap=(Get-NetworkAdapter -VM $VM -ErrorAction Stop) | Where-Object -Property NetworkName -EQ -Value $NetworkName 

   if ($nwadap){
       YoInt "Setting new MAC address $MACAddress for $nwadap for $VM"
       Set-NetworkAdapter -NetworkAdapter $nwadap -Confirm:$false -MacAddress $MACAddress -ErrorAction Stop
   }
   else{
       Throw "Couldn't find $NetworkName in VM $VM"
   }
}

function Update-Net-VM
{
   param([Object]$VM,
         [string]$OldNetworkName,
         [string]$NewNetworkName
   )
   $nwadap=(Get-NetworkAdapter -VM $VM  -ErrorAction Stop) | Where-Object -Property NetworkName -EQ -Value $OldNetworkName   

   if ($nwadap){
       YoInt "Setting new network $NewNetworkName for $nwadap for $VM"
       Set-NetworkAdapter -NetworkAdapter $nwadap -NetworkName $NewNetworkName  -Confirm:$false -ErrorAction Stop
   }
   else{
       Throw "Couldn't find $OldNetworkName in VM $VM"
   }
}

function Wait-A-Min{
    param([int]$Time=1)

    if($Time -ge 1){
            ForEach ( $m in 1..$Time){
                $remaining=$Time-$m+1
                ForEach ($q in 1..30){
                    Write-Host -NoNewline -ForegroundColor DarkGray "_"
                }
                Yo "waiting ... $remaining min"
                ForEach ($q in 1..30){
                    sleep 2
                    Write-Host -NoNewline -BackgroundColor DarkGray "*"
                }
                Yo ""
            }
            Yo ""
    }
}


function Change-Static-Gateway-Inside-VM
{
    param([Object]$VM,
          [string]$MACAddress,
          [string]$GatewayIP,
          [string]$username="Administrator",
          [string]$password="a siege retooled a bra")
    if (-Not $GatewayIP){
        Throw "ERROR: No Gateway IP Specified"
    }

    if (-Not $MACAddress){
        Throw "ERROR: No MAC Specified"
    }


    $change_ipscript=@'
(Get-WmiObject Win32_NetworkAdapterConfiguration -Filter "Index = '$(((Get-WmiObject Win32_NetworkAdapter -Filter "NetEnabled='True'")| Where {$_.MACAddress -Match "
'@

    $change_ipscript=$change_ipscript+$MACAddress+@'
"}).Index)'").SetGateways("
'@+$GatewayIP+@'
", 1)
'@
    Write-Host -ForegroundColor Magenta "Change script: $change_ipscript"
    Invoke-VMScript -VM $VM -ScriptText $change_ipscript -GuestUser $username -GuestPassword $password
}

function Change-Static-IP-Inside-VM
{
    param([Object]$VM,
          [string]$MACAddress,
          [string]$NewIP,
          [string]$NewMask="255.255.255.0",
          [string]$username="Administrator",
          [string]$password="a siege retooled a bra")
    
    if (-Not $NewIP){
        Throw "ERROR: No IP Specified"
    }

    if (-Not $MACAddress){
        Throw "ERROR: No MAC Specified"
    }

    $change_ipscript=@'
(Get-WmiObject Win32_NetworkAdapterConfiguration -Filter "Index = '$(((Get-WmiObject Win32_NetworkAdapter -Filter "NetEnabled='True'")| Where {$_.MACAddress -Match "
'@

    $change_ipscript=$change_ipscript+$MACAddress+@'
"}).Index)'").EnableStatic("
'@+$NewIP+@'
", "
'@+$NewMask+@'
")
'@
    Write-Host -ForegroundColor Magenta "Change script: $change_ipscript"
      

    Invoke-VMScript -VM $VM -ScriptText $change_ipscript -GuestUser $username -GuestPassword $password
}

function SnapshotVApp
{
    param([Object]$VApp,
            [string]$SnapshotName="Snapshot")

    Get-VM -Location $VApp | foreach {
        $srcVM=$_
        Yo "`t`tSnapshotting $srcVM in $VApp"    
        New-Snapshot -VM $srcVM -Name $SnapshotName -ErrorAction Continue
    }   
}

function Change-Password-for-windows
{
    param([Object]$VM,
          [string]$user_password,
          [string]$username="Administrator",
          [string]$password="a siege retooled a bra")

    if (-Not $user_password){
        Throw "ERROR: No Password Specified"
    }
    
    $change_password_script =@'
([adsi](“WinNT://"+((get-wmiobject win32_useraccount)[1].caption.replace(“\”,”/”)))).SetPassword("
'@+$user_password+@'
")
'@
    Write-Host -ForegroundColor Magenta "Password Change script: $change_password_script to $user_password"

    Invoke-VMScript -VM $VM -ScriptText $change_password_script -GuestUser $username -GuestPassword $password

}

#Write-Host -ForegroundColor White "End of Common Functions!!!"
#    +((get-wmiobject win32_useraccount)[1].caption.replace(“\”,”/”)))).SetPassword("

#### move code
#$counter=0
#101..103 | foreach {
#    $counter=$counter+1
#    $selector=$counter%$vmhosts.Count
#    $vmhost=$vmhosts[$selector]
#    $vm_to_move=(Get-VM -Name $ClonedVMPrefix$_)
#    if ($vm_to_move.VMHost -EQ $vmhost ) 
#    {
#        Write-Host "same host"
#        }
#    else{
#        Write-Host "Moving $vm_to_move to different host $vmhost"
#        Move-VM -VM $vm_to_move -Destination $vmhost
#    }
#}
#
#exit