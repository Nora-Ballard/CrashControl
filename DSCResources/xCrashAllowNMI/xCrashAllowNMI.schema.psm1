Configuration xCrashAllowNMI
{
	param
	(
		[Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
		[ValidateSet('Present','Absent')]
		[string]$Ensure,
        
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('All','USB','PS2')]
        [string]$CrashOnCtrlScroll
	)
	
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
    
    Registry AllowNMI {
        Ensure = $Ensure
        Key    = 'HKLM:\System\CurrentControlSet\Control\CrashControl'
        ValueName  = 'NMICrashDump'
        ValueData  = [int][bool]$Enabled
        ValueType  = 'DWord'
    }
    
    if ($CrashOnCtrlScroll -in @('All','USB'))
    {
        Registry $CrashOnCtrlScroll {
            Ensure = $Ensure
            Key    = 'HKLM:\SYSTEM\CurrentControlSet\services\kbdhid\Parameters'
            ValueName = 'CrashOnCtrlScroll'
            ValueData = [int]$true
            ValueType = 'DWord'
        }
        
    }
    
    if ($CrashOnCtrlScroll -in @('All','PS2'))
    {
        Registry $CrashOnCtrlScroll {
            Ensure = $Ensure
            Key    = 'HKLM:\SYSTEM\CurrentControlSet\services\i8042prt\Parameters'
            ValueName = 'CrashOnCtrlScroll'
            ValueData = [int]$true
            ValueType = 'DWord'
        }
        
    }
    
    
    
}