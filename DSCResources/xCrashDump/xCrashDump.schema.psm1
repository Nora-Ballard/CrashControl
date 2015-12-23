Configuration xCrashDump
{
	param
	(
		[Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
		[ValidateSet('Present','Absent')]
		[string]$Ensure,
        
		[Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
		[bool]$AlwaysKeep,
        
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('None','Complete','Kernel','Small','Automatic')]
        [string]$Mode
		
	)
	
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
	
	Registry AlwaysKeep {
		Ensure = $Ensure
		Key    = 'HKLM:\System\CurrentControlSet\Control\CrashControl'
		ValueName = 'AlwaysKeepMemoryDump'
		ValueData = [int]$AlwaysKeep
		ValueType = 'DWord'
	}
    
    # Value should always be present, default is 'Automatic'
    if ($Ensure -eq 'Absent') { $Mode = 7 }
    
    $CrashDumpModes = @{
        None      = 0
        Complete  = 1
        Kernel    = 2
        Small     = 3
        Automatic = 7
    }
    
    Registry Mode {
        Ensure = 'Present'
        Key    = 'HKLM:\System\CurrentControlSet\Control\CrashControl'
        ValueName  = 'CrashdumpEnabled'
        ValueData  = $CrashDumpModes[$Mode]
        ValueType  = 'DWord'
    }
    
}