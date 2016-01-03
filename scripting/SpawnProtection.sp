#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <multicolors>

#define MAX_BUTTONS 25

public Plugin myinfo = 
{
	name = "Spawn Protection",
	author = "Roy (Christian Deacon)",
	description = "Advanced spawn protection.",
	version = "1.0",
	url = "GFLClan.com & TheDevelopingCommunity.com & alliedmods.net"
};

// Bools for the client
bool g_bProtected[MAXPLAYERS+1];
bool g_bAFK[MAXPLAYERS+1];
bool g_bFTimer[MAXPLAYERS+1];

// ConVars
Handle g_hAnnounce = null;
Handle g_hTime = null;
Handle g_hWeaponShoot = null;

// ConVar Values
bool g_bAnnounce;
float g_fTime
bool g_bWeaponShoot;

public void OnPluginStart() 
{
	// Events
	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("weapon_fire", Event_WeaponFire);
	
	// ConVars
	g_hAnnounce = CreateConVar("sm_sp_announce", "1", "Announce when the user is and is not protected?");
	HookConVarChange(g_hAnnounce, CVarChanged);
	
	g_hTime = CreateConVar("sm_sp_time", "5.0", "Amount of time protection lasts for if the user isn't AFK");
	HookConVarChange(g_hTime, CVarChanged);
	
	g_hWeaponShoot = CreateConVar("sm_sp_on_fire", "1", "If 1, even if the user is in the \"sm_roy_sp_time\" immunity, if they fire, it will remove spawn protection");
	HookConVarChange(g_hWeaponShoot, CVarChanged);
	
	// Translations
	LoadTranslations("spawnprotection.phrases.txt");
	
	// Config
	AutoExecConfig(true, "plugin.spawnprotection");
}

public void OnConfigsExecuted()
{
	// Receive the ConVar values.
	g_bAnnounce = GetConVarBool(g_hAnnounce);
	g_fTime = GetConVarFloat(g_hTime);
	g_bWeaponShoot = GetConVarBool(g_hWeaponShoot);
}

public void CVarChanged(Handle hCVar, const char[] sOldV, const char[] sNewV)
{
	OnConfigsExecuted();
}

// Event: Player Spawn
public Action Event_PlayerSpawn(Event eEvent, const char[] sName, bool bDontBroadcast) 
{
	// Get the client.
	int iClient = GetClientOfUserId(GetEventInt(eEvent, "userid"));
	
	// Set everything to true.
	g_bProtected[iClient] = true;
	g_bAFK[iClient] = false;
	g_bFTimer[iClient] = true;
	
	// Announce they are protected (if the ConVar is enabled)
	if (g_bAnnounce) 
	{
		// Make sure the client is valid.
		if (iClient > 0 && iClient <= MaxClients && IsClientInGame(iClient)) 
		{
			// Print to chat!
			CPrintToChat(iClient, "%t%t", "Tag", "Protected");
		}
	}
	
	// Create the timer to disable protection.
	CreateTimer(g_fTime, DisableProtection, iClient, TIMER_FLAG_NO_MAPCHANGE);
}

// Player Spawn timer to disable protection!
public Action DisableProtection(Handle hTimer, any iClient) 
{
	// Check if they are still protected and if the client is valid.
	if (g_bFTimer[iClient] && iClient > 0 && iClient <= MaxClients && IsClientInGame(iClient) && IsPlayerAlive(iClient) && GetClientTeam(iClient) > 1) 
	{
		// Set the "ftimer" protection to false.
		g_bFTimer[iClient] = false;
		
		// If they aren't protected (non-AFK), which means they are able to get damaged, announce they are no longer protected (if the ConVar is enabled)
		if (!g_bProtected[iClient]) 
		{
			// Check whether the ConVar is enabled or not.
			if (g_bAnnounce) 
			{
				// Print to the chat!
				CPrintToChat(iClient, "%t%t", "Tag", "NotProtected");
			}
		} 
		else 
		{
			// The user must be AFK, set "g_bAFK" to true.
			g_bAFK[iClient] = true;
		}
	}
}

// Weapon Fire Event!
public Action Event_WeaponFire(Event eEvent, const char[] sName, bool bDontBroadcast) 
{
	// Get the client index.
	int iClient = GetClientOfUserId(GetEventInt(eEvent, "userid"));
	
	// Check if the client is valid.
	if (iClient > 0 && iClient <= MaxClients && IsClientInGame(iClient) && GetClientTeam(iClient) > 1) 
	{
		// Check if the client has protection.
		if (g_bProtected[iClient] || g_bFTimer[iClient]) 
		{
			// If the weapon shoot ConVar is enabled, we must disable the "ftimer" protection as well.
			if (g_bWeaponShoot && g_bFTimer[iClient]) 
			{
				// Set "ftimer" to false.
				g_bFTimer[iClient] = false;
			}
			
			// Check if the client is "protected".
			if (g_bProtected[iClient]) 
			{
				// Set "g_bProtected" to false.
				g_bProtected[iClient] = false;
			}
			
			// Announce they are no longer protected (if the ConVar is enabled and they are actually no longer protected)
			if (g_bAnnounce && !g_bProtected[iClient] && !g_bFTimer[iClient]) 
			{
				// Print to chat!
				CPrintToChat(iClient, "%t%t", "Tag", "NotProtected");
			}
		}
		
		// Check if "g_bAFK" is true.
		if (g_bAFK[iClient]) 
		{
			// Set "g_bAFK" to false (since they fired).
			g_bAFK[iClient] = false;
		}
	}
}

// On Client Put In Server (once they connect)
public void OnClientPutInServer(int iClient) 
{
	// Hook the "OnTakeDamage" event.
    SDKHook(iClient, SDKHook_OnTakeDamage, OnTakeDamage);
}

// On Player Run Command action (if a user hits a key)
public Action OnPlayerRunCmd(int iClient, int &iButtons, int &iImpulse, float fVel[3], float fAngles[3], int &iWeapon) 
{
	// Get the maximum buttons.
	for (int i = 0; i < MAX_BUTTONS; i++) 
	{
		// Get the button
		int button = (1 << i);
		
		// Check whether the user is hitting a key.
		if ((iButtons & button)) 
		{
			// Check if the client is protected and if the client is valid.
			if (g_bProtected[iClient] && GetClientTeam(iClient) > 1 && iClient > 0 && iClient <= MaxClients && IsClientInGame(iClient)) 
			{
				// Set "g_bProtected" to false.
				g_bProtected[iClient] = false;
				
				// Set "g_bAFK" to false.
				g_bAFK[iClient] = false;
				
				// Announce they are no longer protected (if the ConVar is enabled and "ftimer" is false)
				if (g_bAnnounce && !g_bFTimer[iClient]) 
				{
					// Print to chat!
					CPrintToChat(iClient, "%t%t", "Tag", "NotProtected");
				}
			}
		}
	}
}

// The "OnTakeDamage" SDKHook.
public Action OnTakeDamage(int iVictim, int &iAttacker, int &iInflictor, float &fDamage, int &iDamageType) 
{
	// Check if "g_bProtected" or "g_bFTimer" is true for the victim.
	if (g_bProtected[iVictim] || g_bFTimer[iVictim]) 
	{
		// If it is, they are protected and we need to set fDamage to 0.0.
		fDamage = 0.0;
		
		// Check if the attacker is valid.
		if (iAttacker > 0 && iAttacker <= MaxClients && IsClientInGame(iAttacker)) 
		{
			// Check if "afk" is true for the victim.
			if (g_bAFK[iVictim]) 
			{
				// Print to chat! (victim is AFK)
				CPrintToChat(iAttacker, "%t%t", "Tag", "IsAFK", iVictim);
			} 
			else 
			{
				// Print to chat! (victim is protected but not AFK)
				CPrintToChat(iAttacker, "%t%t", "Tag", "IsProtected", iVictim);
			}
		}
		
		// Return the plugin changed values.
		return Plugin_Changed;
    }
    
	// Allow other plugins to execute "OnTakeDamage".
	return Plugin_Continue;
}
