function Load-PowerCLI
{
    #Add-PSSnapin VMware.VimAutomation.Core
    #Add-PSSnapin  VMware.VimAutomation.Vds
    #Add-PSSnapin  VMware.VimAutomation
    . "C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1"
}


Load-PowerCLI
Connect-VIServer -Server  wsvc.bgm.bu.int
