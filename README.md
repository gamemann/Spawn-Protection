# Spawn Protection
## Description
A simple Spawn Protection addon that was developed for Counter-Strike: Source and Counter-Strike: Global Offensive, but should work in other games. What's neat about this plugin is it uses SDKHooks to block damage and includes an option to stop spawn protection when the victim fires their weapon.

## ConVars
* **sm_sp_announce** - When enabled, the attacker will receive chat messages (if enabled per client) that the victim is AFK (Default 1).
* **sm_sp_time** - The amount of time to protect each player on spawn (Default 5.0).
* **sm_sp_on_fire** - When enabled, if the victim fires their weapon before the spawn protection time runs out, it will remove their protection (Default 1).

## Commands
* **sm_rspnotify** - This toggles AFK notifications per attacker/client via client cookies.

## Installation
You'll want to compile the source code (`scripting/SpawnProtection.sp`). Afterwards, copy/move the compiled SpawnProtection.smx file into the server's addons/sourcemod/plugins directory.

## Credits
* [Christian Deacon](https://github.com/gamemann)