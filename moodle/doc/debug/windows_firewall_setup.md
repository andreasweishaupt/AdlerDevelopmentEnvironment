# Windows Setup
Windows classifies the WSL network as public.
Therefore, no incoming network connections from WSL to Windows are allowed.

Workaround ([see this issue](https://github.com/microsoft/WSL/issues/4585#issuecomment-610061194):
1. Open Windows terminal as admin
2. Run `New-NetFirewallRule -DisplayName "WSL" -Direction Inbound  -InterfaceAlias "vEthernet (WSL)"  -Action Allow` (or this in case the command does not work: `New-NetFirewallRule -DisplayName "WSL" -Direction Inbound -Action Allow`)

⚠️ This has to be done after every reboot.
