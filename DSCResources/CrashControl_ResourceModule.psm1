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

    $_CrashDumpMode = Get-CrashDumpMode
    Write-Debug ('CrashDumpMode = {0}' -f $_CrashDumpMode)
    if ($_CrashDumpMode -ne $CrashDumpMode) { 
        Write-Verbose "Tests failed on CrashDumpMode setting."
        $TestResult = $false 
    }

    $_AlwaysKeepMemoryDump = Get-CrashAlwaysKeep
    Write-Debug ('AlwaysKeepMemoryDump = {0}' -f $_AlwaysKeepMemoryDump)

    if ($_AlwaysKeepMemoryDump -ne $EnabledDisabledtoBool[$AlwaysKeepMemoryDump]) {
        Write-Verbose "Tests failed on AlwaysKeepMemoryDump setting."
        $TestResult = $false
    }

    $_CrashOnCtrlScroll = Get-CrashOnCtrlScroll
    Write-Debug ('CrashOnCtrlScroll for USB Keyboards = {0}' -f $_CrashOnCtrlScroll.USB)
    Write-Debug ('CrashOnCtrlScroll for PS2 Keyboards = {0}' -f $_CrashOnCtrlScroll.PS2)

    if (($_CrashOnCtrlScroll.PS2 -ne $EnabledDisabledtoBool[$CrashOnCtrlScroll]) -and 
        ($_CrashOnCtrlScroll.USB -ne $EnabledDisabledtoBool[$CrashOnCtrlScroll])) {
        Write-Verbose "Tests failed on CrashOnCtrlScroll setting."
        $TestResult = $false
    }

    $_NMICrashDump = Get-CrashNmiDump
    if ($_NMICrashDump -ne $EnabledDisabledtoBool[$NMICrashDump]) {
        Write-Verbose "Tests failed on NMICrashDump setting."
        $TestResult = $false
    }

    Write-Output $TestResult
}

