# CrashControl

A module for setting Windows Crash Dump settings.

This module was inspired and informed by Bruce Mackenzie-Low's talk on 'Windows Debugging' at 'Techmentor 2014'. 

## Notes on crash dumps:
- When a system is in a partially functional or hung state, a good way to get a `.dmp` file to analyze is to force a crash dump using keystroke or NMI
- Some BIOS have an `Automatic Server Recovery` or `Watchdog` setting which tries to detect if OS is live and resets. This will often interrupt the memory dump generation. If you encounter this, then disabling this setting can allow you to get a full dump.
- A truncated dump file may still have usefull information. 

## Non-Maskable Interrupt (NMI)
This is a signal, sent from the system hardware, which triggers a crash dump. This is used in cases where a keyboard may not be available. Such as, from a BMC or hypervisor remote console.

### Triggering an NMI signal

Type | Method
---- | ------
HP iLO | Use the button on the system's iLO diagnostics page. 
Hyper-V VM | Powershell command: `Debug‐Vm “VM 1" ‐InjectNonMaskableInterrupt –Force`
VMware VM | See [KB2005715](http://kb.vmware.com/selfservice/search.do?cmd=displayKC&docType=kc&docTypeID=DT_KB_1_1&externalId=2005715) and follow the instructions for your version


## Usage

### CrashAlwaysKeep

When `CrashAlwaysKeep` is enabled, Windows is forced to keep the `MEMORY.dmp` crash dump file, even if free space is low.

In Windows 7 the alogrithm for crash dump creation was updated. The default behavior is to delete the `MEMORY.dmp` crash dump file, if the machine is joined to a domain and the free space is below 25GB.

####Example
```powershell
# Get Current Settings
Get-CrashAlwaysKeep

# Enable
Set-CrashAlwaysKeep -Enabled

# Disable (default)
Set-CrashAlwaysKeep
```

### CrashOnCtrlScroll 

When `CrashOnCtrlScroll` is enabled, Windows will generate a crash dump when the `Right‐Ctrl + Scroll Lock (twice)` keystroke is pressed. This value must be configured separately for each type of keyboard that will be used.

Issues: `0xE2 (MANUALLY_INITIATED_CRASH)`

### Supported Keyboard Types:

Type | OS Supported | Service | Module Support
---- | ------------ | ------- | --------------
PS/2 | Windows 2000 and later | i8042prt | Yes
USB | Windows Vista and Later | kbdhid | Yes
Hyper-V | Windows 10 version 1903 and later | hyperkbd | No

You must restart the system for these settings to take effect.

#### TODO
- Add prompt for restart, and a warning that restart is required.
- Support [alternate shortcuts](https://docs.microsoft.com/en-us/windows-hardware/drivers/debugger/forcing-a-system-crash-from-the-keyboard?redirectedfrom=MSDN#defining-alternate-keyboard-shortcuts-to-force-a-system-crash-from-the-keyboard)

#### Example:
```powershell
# Get Current Settings
Get-CrashOnCtrlScroll

# Enable on USB keyboard
Set-CrashOnCtrlScroll -Enabled -DeviceType 'USB'; Restart-Computer

# Enable on USB and PS2 keyboards
Set-CrashOnCtrlScroll -Enabled; Restart-Computer

# Disable on USB and PS2 keyboards (Restore default)
Set-CrashOnCtrlScroll; Restart-Computer
```

### CrashDumpMode  

Sets the method of crash dump generation: `None`, `Complete`, `Kernel`, `Small`, `Automatic`

#### Examples
```powershell
# Get current settings
Get-CrashDumpMode

# Set the mode to Small
Set-CrashDumpMode -State 'Small'

# Set the mode to Kernel (default)
Set-CrashDumpMode
```

### CrashNmiDump 

In Windows version prior to Windows Server 2012 or Windows 8, this controls whether Windows will respond to respond to a `Non-Maskable Interrupt (NMI)` signal from the hardware. 

Issues: `0x80 bugcheck (NMI_HARDWARE_FAILURE)`

#### Examples
```powershell
# Get Current Settings
Get-CrashNmiDump

# Enable
Set-CrashNmiDump -Enabled

# Disable (default)
Set-CrashNmiDump
```

## References
[Kernel Dump Storage and Clean-up Behavior in Windows 7](https://web.archive.org/web/20100822214802/http://blogs.msdn.com/b/wer/archive/2009/02/09/kernel-dump-storage-and-clean-up-behavior-in-windows-7.aspx)

[Forcing a System Crash from the Keyboard](http://msdn.microsoft.com/en-us/library/windows/hardware/ff545499(v=vs.85).aspx)

[Generate Kernel or Complete Crash Dump: Use NMI](https://docs.microsoft.com/en-US/windows/client-management/generate-kernel-or-complete-crash-dump#use-nmi)

[Microsoft KB254649](http://support.microsoft.com/kb/254649)

Bruce Mackenzie-Low's talk on 'Windows Debugging' at 'Techmentor 2014'

