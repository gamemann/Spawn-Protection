/* Natives */
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