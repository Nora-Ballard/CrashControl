function Set-CrashAlwaysKeep {
<#
.Synopsis
   Forces Windows 7 to keep the crash dump even if free space is low.
.DESCRIPTION
   Windows 7 will not keep crash dumps if free space is below 25GB when joined to a domain.
.EXAMPLE
   Set-CrashAlwaysKeep
.EXAMPLE
   Set-CrashAlwaysKeep -State Disabled
#>
[cmdletbinding(SupportsShouldProcess=$true,ConfirmImpact='Medium')]
param(
    [Parameter()]
    [ValidateSet('Enabled','Disabled')]
    [string]$State = 'Enabled'
)
    $StateToValue = @{
        Enabled  = 1
        Disabled = 0
    }

    $ItemProperty = @{
        Name  = 'AlwaysKeepMemoryDump'
        Value = $StateToValue[$State]
        Type  = 'DWord'
        Path  = 'HKLM:\System\CurrentControlSet\Control\CrashControl'
    }
    if ($PSCmdlet.ShouldProcess($ItemProperty.Name, $('{0} ({1})' -f $State, $ItemProperty.Value))) {
        Set-ItemProperty @ItemProperty -ErrorAction Stop
    }

}

function Get-CrashAlwaysKeep {
[OutputType([bool])]
    $Key  = 'HKLM:\System\CurrentControlSet\Control\CrashControl'
    $Name = 'AlwaysKeepMemoryDump'
    [bool](Get-Item -path $Key).GetValue($Name)
}

function Set-CrashOnCtrlScroll {
<#
.Synopsis
   Enables or Disables whether Windows will generate a crash dump when the 'Right‐Ctrl + Scroll Lock (twice)' keystroke is pressed.
.DESCRIPTION
   Allows you to force a system memory dump from a keyboard. By default this function will enable the option for both USB and PS2 keyboards.
.EXAMPLE
   Set-CrashOnCtrlScroll
.EXAMPLE
   Set-CrashOnCtrlScroll -State Disabled -DeviceType USB
.PARAMETER State
    Defaults to Enabled
.PARAMETER DeviceType
    Defaults to All
#>
[cmdletbinding(SupportsShouldProcess=$true,ConfirmImpact='Medium')]
param(
    [Parameter()]
    [ValidateSet('Enabled','Disabled')]
    [string]$State = 'Enabled',

    [Parameter()]
    [ValidateSet('All', 'USB','PS2')]
    [string]$DeviceType = 'All'
)
    $StateToValue = @{
        Enabled  = 1
        Disabled = 0
    }
    
    $ItemProperty = @{
        Name  = 'CrashOnCtrlScroll'
        Type  = 'DWord'
        Value = $StateToValue[$State]
        Path  = ''
    }

    $DeviceKeys = @{ 
        PS2 = 'HKLM:\SYSTEM\CurrentControlSet\services\i8042prt\Parameters'
        USB = 'HKLM:\SYSTEM\CurrentControlSet\services\kbdhid\Parameters'
    }

    if ($DeviceType -eq 'All') {
        $DeviceTypesToProcess = @($DeviceKeys.Keys)
    }
    else {
        $DeviceTypesToProcess = $DeviceKeys[$DeviceType]
    }

    $DeviceTypesToProcess | ForEach-Object {
        $ItemProperty.Path  = $DeviceKeys[$_]
        if ($PSCmdlet.ShouldProcess($ItemProperty.Name, $('{0} ({1})' -f $State, $ItemProperty.Value))) {
            Set-ItemProperty @ItemProperty -ErrorAction Stop
        }
    }
}

function Get-CrashOnCtrlScroll {
[OutputType([pscustomobject])]
    $Key  = 'HKLM:\SYSTEM\CurrentControlSet\services\i8042prt\Parameters'
    $Name = 'CrashOnCtrlScroll'
    $IsPS2Enabled = [bool](Get-Item -path $Key).GetValue($Name)

    $Key  = 'HKLM:\SYSTEM\CurrentControlSet\services\kbdhid\Parameters'
    $Name = 'CrashOnCtrlScroll'
    $IsUsbEnabled = [bool](Get-Item -path $Key).GetValue($Name)
    $Output = [pscustomobject]@{
        PS2 = $IsPS2Enabled
        USB = $IsUsbEnabled
    }
    Write-Output $Output
}

function Set-CrashDumpMode {
<#
.Synopsis
   Sets the method of crash dump generation.
.DESCRIPTION
   See Microsoft KB254649 for more info.
.EXAMPLE
   Set-CrashDumpMode -State Small
.EXAMPLE
   Set-CrashDumpMode
.PARAMETER State
    Defaults to Kernel Mode type.
#>
[cmdletbinding(SupportsShouldProcess=$true,ConfirmImpact='Medium')]
param(
    [Parameter()]
    [ValidateSet('None','Complete','Kernel','Small','Automatic')]
    [string]$State = 'Kernel'
)
    $StateToValue = @{
        None      = 0
        Complete  = 1
        Kernel    = 2
        Small     = 3
        Automatic = 7
    }

    $ItemProperty = @{
        Name  = 'CrashdumpEnabled'
        Value = $StateToValue[$State]
        Type  = 'DWord'
        Path  = 'HKLM:\System\CurrentControlSet\Control\CrashControl'
    }
    if ($PSCmdlet.ShouldProcess($ItemProperty.Name, $('{0} ({1})' -f $State, $ItemProperty.Value))) {
        Set-ItemProperty @ItemProperty -ErrorAction Stop
    }

}

function Get-CrashDumpMode {
[OutputType([string])]
    $ValueToState = @{
        0 = 'None'
        1 = 'Complete'
        2 = 'Kernel'
        3 = 'Small'
        7 = 'Automatic'
    }
    
    $Key  = 'HKLM:\System\CurrentControlSet\Control\CrashControl'
    $Name = 'CrashdumpEnabled'
    $ValueToState[(Get-Item -path $Key).GetValue($Name)]
}

function Set-CrashNmiDump {
<#
.Synopsis
   Controls whether Windows responds to an Non-Maskable Interrupt (NMI) for generating a crash dump. (Microsoft KB927069)
.DESCRIPTION
   Enables or Disables the 'HKLM:\System\CurrentControlSet\Control\CrashControl\NMICrashDump' registry setting.

   Enabling tells windows to respond to a NMI signal from the hardware, which results in a Stop 0x80 bugcheck (NMI_HARDWARE_FAILURE)

   Windows Server 2012 & Windows 8 do not require NMICrashDump to be set.

   To generate and NMI on HP Hardware see the documentation here:
        http://h20195.www2.hp.com/V2/GetDocument.aspx?docname=4AA4‐7853ENW&cc=us&lc=en

   To generate an NMI for a Hyper-V VM:
        debug‐vm “VM 1" ‐InjectNonMaskableInterrupt –Force

   To generate an NMI for a VMware VM see documentation here (KB2005715):
        http://kb.vmware.com/selfservice/search.do?cmd=displayKC&docType=kc&docTypeID=DT_KB_1_1&externalId=2005715
.EXAMPLE
   Set-CrashNmiDump -State Disabled
.EXAMPLE
   Set-CrashNmiDump
.PARAMETER State
    Defaults to Enabled.
#>
[cmdletbinding(SupportsShouldProcess=$true,ConfirmImpact='Medium')]
param(
    [Parameter()]
    [ValidateSet('Enabled','Disabled')]
    [string]$State = 'Enabled'
)
    $StateToValue = @{
        Enabled  = 1
        Disabled = 0
    }

    $ItemProperty = @{
        Name  = 'NMICrashDump'
        Value = $StateToValue[$State]
        Type  = 'DWord'
        Path  = 'HKLM:\System\CurrentControlSet\Control\CrashControl'
    }
    if ($PSCmdlet.ShouldProcess($ItemProperty.Name, $('{0} ({1})' -f $State, $ItemProperty.Value))) {
        Set-ItemProperty @ItemProperty -ErrorAction Stop
    }

}

function Get-CrashNmiDump {
[OutputType([bool])]
    $Key  = 'HKLM:\System\CurrentControlSet\Control\CrashControl'
    $Name = 'NMICrashDump'

    $KeyItem = Get-Item -Path $Key
    [bool]($KeyItem).GetValue($Name)
}
