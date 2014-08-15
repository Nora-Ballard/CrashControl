Function Get-TargetResource
{
    param(
        [Parameter()]
        [ValidateSet('None','Complete','Kernel','Small','Automatic')]
        $CrashDumpMode = 'Automatic',

        [Parameter()]
        [ValidateSet('Enabled','Disabled')]
        $AlwaysKeepMemoryDump = 'Disabled',

        [Parameter()]
        [ValidateSet('Enabled','Disabled')]
        $CrashOnCtrlScroll = 'Disabled',

        [Parameter()]
        [ValidateSet('Enabled','Disabled')]
        $NMICrashDump = 'Disabled'
    )

    $Output = @{
        CrashDumpMode = Get-CrashDumpMode
        AlwaysKeepMemoryDump = Get-CrashAlwaysKeep
        CrashOnCtrlScroll =  Get-CrashOnCtrlScroll
        NMICrashDump =  Get-CrashNmiDump
    }

    Write-Output $Output

}

Function Set-TargetResource
{
    param(
        [Parameter()]
        [ValidateSet('None','Complete','Kernel','Small','Automatic')]
        $CrashDumpMode = 'Automatic',

        [Parameter()]
        [ValidateSet('Enabled','Disabled')]
        $AlwaysKeepMemoryDump = 'Disabled',

        [Parameter()]
        [ValidateSet('Enabled','Disabled')]
        $CrashOnCtrlScroll = 'Disabled',

        [Parameter()]
        [ValidateSet('Enabled','Disabled')]
        $NMICrashDump = 'Disabled'
    )

    Set-CrashDumpMode -State $CrashDumpMode

    Set-CrashAlwaysKeep -State $AlwaysKeepMemoryDump

    Set-CrashOnCtrlScroll -State $CrashOnCtrlScroll

    Set-CrashNmiDump -State $NMICrashDump

}

Function Test-TargetResource
{
    param(
        [Parameter()]
        [ValidateSet('None','Complete','Kernel','Small','Automatic')]
        $CrashDumpMode = 'Automatic',

        [Parameter()]
        [ValidateSet('Enabled','Disabled')]
        $AlwaysKeepMemoryDump = 'Disabled',

        [Parameter()]
        [ValidateSet('Enabled','Disabled')]
        $CrashOnCtrlScroll = 'Disabled',

        [Parameter()]
        [ValidateSet('Enabled','Disabled')]
        $NMICrashDump = 'Disabled'
    )
    $EnabledDisabledtoBool = @{
        Enabled  = $true
        Disabled = $false
    }

    $TestResult = $true

    if ((Get-CrashDumpMode) -ne $CrashDumpMode) { 
        $TestResult = $false 
    }

    if ((Get-CrashAlwaysKeep) -ne $EnabledDisabledtoBool[$AlwaysKeepMemoryDump]) {
        $TestResult = $false
    }

    if (((Get-CrashOnCtrlScroll).PS2 -ne $EnabledDisabledtoBool[$CrashOnCtrlScroll]) -and 
        ((Get-CrashOnCtrlScroll).USB -ne $EnabledDisabledtoBool[$CrashOnCtrlScroll])) {
        $TestResult = $false
    }

    if ((Get-CrashNmiDump) -ne $EnabledDisabledtoBool[$NMICrashDump]) {
        $TestResult = $false
    }

    Write-Output $TestResult
}

