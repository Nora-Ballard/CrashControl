# Windows Crash Dump Control

A module for configuring Windows Crash Dumps.

This module was inspired and informed by Bruce Mackenzie-Low's talk on 'Windows Debugging' at 'Techmentor 2014'. 

## Notes
- When a system is in a partially functional or hung state, a good way to get a `.dmp` file to analyze is to force a crash dump using keystroke or NMI
- Some BIOS have an `Automatic Server Recovery` or `Watchdog` setting which tries to detect if OS is live and resets. This will often interrupt the memory dump generation. If you encounter this, then disabling this setting can allow you to get a full dump.
- A truncated dump file may still have usefull information. 


## Usage

### Crash On Keyboard

Windows can issue a `0xE2 (MANUALLY_INITIATED_CRASH)` signal when a specific keystroke is pressed. This is disabled by default, and must be enabled in the driver for each keyboard type. 

Supported Keyboard Types:

Type | OS Supported | Driver Service | Module Support
---- | ------------ | -------------- | --------------
PS/2 | Windows 2000 and later | i8042prt | Yes
USB | Windows Vista and Later | kbdhid | Yes
Hyper-V | Windows 10 version 1903 and later | hyperkbd | No


- The `CrashOnCtrlScroll` will enable the `Right‐Ctrl + Scroll Lock + Scroll Lock` keystroke. 
- The `Dump1Keys` setting can be used to enable alternate shortcuts. However this is not currently supported by this module.
- You must restart the system for these settings to take effect.

Examples
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

TODO:
- Add prompt for restart, and a warning that restart is required.
- Support [alternate shortcuts](https://docs.microsoft.com/en-us/windows-hardware/drivers/debugger/forcing-a-system-crash-from-the-keyboard?redirectedfrom=MSDN#defining-alternate-keyboard-shortcuts-to-force-a-system-crash-from-the-keyboard)

## Crash on Non-Maskable Interrupt (NMI)
Windows can issue a `0x80 bugcheck (NMI_HARDWARE_FAILURE)` in response to a `Non-Maskable Interrupt (NMI)` signal from the system hardware. This signal is used in cases where a keyboard may not be available. This is most commmonly used when remotely managing a system remotely from via the BMC or Hypervisor.

Triggering an NMI signal

Type | Method
---- | ------
HP iLO | Use the button on the system's iLO diagnostics page. 
Hyper-V VM | Powershell command: `Debug‐Vm “VM 1" ‐InjectNonMaskableInterrupt –Force`
VMware VM | See [KB2005715](http://kb.vmware.com/selfservice/search.do?cmd=displayKC&docType=kc&docTypeID=DT_KB_1_1&externalId=2005715) and follow the instructions for your version


In Windows version prior to Windows Server 2012 or Windows 8, this must be enabled with the `CrashNmiDump` settings. In later versions, this is not required and the setting has no effect 

Examples
```powershell
# Get Current Settings
Get-CrashNmiDump

# Enable
Set-CrashNmiDump -Enabled

# Disable (default)
Set-CrashNmiDump
```

### Always Keep

From Windows 7 onwards, if the machine is joined to a domain and the free space is below 25GB, then the `MEMORY.dmp` crash dump file will not be kept. This behavior is overridden when `CrashAlwaysKeep` is enabled.

Examples
```powershell
# Get Current Settings
Get-CrashAlwaysKeep

# Enable
Set-CrashAlwaysKeep -Enabled

# Disable (default)
Set-CrashAlwaysKeep
```

### Crash Dump Mode  

The method of crash dump generation can be configured for `None`, `Complete`, `Kernel`, `Small`, or `Automatic`. The default mode is `Kernel`

Examples
```powershell
# Get current settings
Get-CrashDumpMode

# Set the mode to Small
Set-CrashDumpMode -State 'Small'

# Set the mode to Kernel (default)
Set-CrashDumpMode
```


## References
[Kernel Dump Storage and Clean-up Behavior in Windows 7](https://web.archive.org/web/20100822214802/http://blogs.msdn.com/b/wer/archive/2009/02/09/kernel-dump-storage-and-clean-up-behavior-in-windows-7.aspx)

[Forcing a System Crash from the Keyboard](http://msdn.microsoft.com/en-us/library/windows/hardware/ff545499(v=vs.85).aspx)

[Generate Kernel or Complete Crash Dump: Use NMI](https://docs.microsoft.com/en-US/windows/client-management/generate-kernel-or-complete-crash-dump#use-nmi)

[Microsoft KB254649](http://support.microsoft.com/kb/254649)

Bruce Mackenzie-Low's talk on 'Windows Debugging' at 'Techmentor 2014'

