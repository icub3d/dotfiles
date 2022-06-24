# iCUE VM

I use a VM to manage my water system.

2 CPU / 4 GB

Add the 4 items as "USB Host Devices"

	2 x Commander Pro
	1 x Lighting Node Pro
	1 x Power Supply

## Auto-login

https://docs.microsoft.com/en-us/troubleshoot/windows-server/user-profiles-and-logon/turn-on-automatic-logon

HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon

Add or Update Keys:

    DefaultUserName (string key) username
	DefaultPassword (string key) password
	AutoAdminLogon (string key) 1

