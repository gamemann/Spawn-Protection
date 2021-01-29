# Spawn Protection
## Description
A simple SourceMod Spawn Protection plugin that was developed for Counter-Strike: Source and Counter-Strike: Global Offensive, but should work in other games as well. What's neat about this plugin is it uses SDKHooks to block damage and includes an option to stop spawn protection when the victim fires their weapon.

## ConVars
* **sm_sp_announce** - When enabled, the attacker will receive chat messages (if enabled per client) that the victim is protected (Default 1).
* **sm_sp_time** - The amount of time to protect each player on spawn (Default 5.0).
* **sm_sp_on_fire** - When enabled, if the victim fires their weapon before the spawn protection time runs out, it will remove their protection (Default 1).

## Commands
* **sm_rspnotify** - This toggles protected notifications per attacker/client via client cookies.

## Natives
For developers, the following natives are supported.

```SourcePawn
/**
 * Checks whether the client is protected or not.
 * 
 * @param iClient Client's index.
 * 
 * @return boolean
 */
native bool IsSpawnProtected(int iClient);

/**
 * Notifies the attacker that the victim is AFK.
 * 
 * @param iAttacker The attacker's client index.
 * @param iVictim The victim's client index.
 * 
 * @return boolean Returns true on success and false otherwise.
 */
native bool NotifyAttacker(int iAttacker, int iVictim);
```

You may include the plugin with the following assuming `scripting/include/RSP.inc` exists.

```SourcePawn
#include <RSP>
```

## Installation
You'll want to compile the source code (`scripting/SpawnProtection.sp`). Afterwards, copy/move the compiled SpawnProtection.smx file into the server's addons/sourcemod/plugins directory.

## Credits
* [Christian Deacon](https://github.com/gamemann)