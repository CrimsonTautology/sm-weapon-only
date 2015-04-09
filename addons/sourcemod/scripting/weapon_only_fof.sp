#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

new bool:bMeleeOnly = false;
new nKicksMode = 0;
new bool:bAutoFF = false;

#define PLUGIN_VERSION "1.0.0"
#define PLUGIN_NAME  "[FoF] Weapon Only"

#define WEAPON_NAME_SIZE 32

public Plugin:myinfo =
{
    name = PLUGIN_NAME,
    author = "CrimsonTautology",
    description = "Allows one type of weapon only",
    version = PLUGIN_VERSION,
    url = "http://github.com/CrimsonTautology/sm_weapon_only"
};

new Handle:g_Cvar_Enabled      = INVALID_HANDLE;
new Handle:g_Cvar_TargetWeapon = INVALID_HANDLE;

public OnPluginStart()
{
    CreateConVar("sm_weapon_only_version", PLUGIN_VERSION, PLUGIN_NAME, FCVAR_PLUGIN | FCVAR_SPONLY | FCVAR_REPLICATED | FCVAR_NOTIFY | FCVAR_DONTRECORD);
    g_Cvar_Enabled = CreateConVar(
            "sm_weapon_only",
            "1",
            "Set to 1 to enable the weapon only plugin",
            FCVAR_PLUGIN | FCVAR_REPLICATED | FCVAR_NOTIFY,
            true,
            0.0,
            true,
            1.0);
    g_Cvar_TargetWeapon = CreateConVar(
            "sm_weapon_only_weapon",
            "weapon_dynamite_black",
            "The class name of the weapon",
            FCVAR_PLUGIN | FCVAR_REPLICATED | FCVAR_NOTIFY
            );

    HookConVarChange(g_Cvar_Enabled, OnEnabledChange);
    HookConVarChange(g_Cvar_TargetWeapon, OnTargetWeaponChange);

    HookEvent("player_spawn", Event_PlayerSpawn);

    AutoExecConfig();
}

public OnMapStart()
{
    CreateTimer( 1.0, Timer_Repeat, .flags = TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE );
}

public OnEnabledChange(Handle:cvar, const String:oldValue[], const String:newValue[])
{
    if(cvar != g_Cvar_Enabled) return;

    new bool:was_on = !!StringToInt(oldValue);
    new bool:now_on = !!StringToInt(newValue);

    //When changing from on to off
    if(was_on && !now_on)
    {
    }

    //When changing from off to on
    if(!was_on && now_on)
    {
        new String:weapon[WEAPON_NAME_SIZE];
        GetConVarString(g_Cvar_TargetWeapon, weapon, sizeof(weapon));
        StripInvalidWeaponsAll(weapon);
    }
}

public OnTargetWeaponChange(Handle:cvar, const String:oldValue[], const String:newValue[])
{
    if(cvar != g_Cvar_TargetWeapon) return;
    if(!IsWeaponOnlyEnabled()) return;

    StripInvalidWeaponsAll(newValue);
}

bool:IsWeaponOnlyEnabled()
{
    return GetConVarBool(g_Cvar_Enabled);
}

public Event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
    if(IsWeaponOnlyEnabled())
    {
        new player = GetEventInt(event, "userid");
        CreateTimer( 0.0, PlayerSpawnDelay, player, TIMER_FLAG_NO_MAPCHANGE );
    }
}

public Action:PlayerSpawnDelay( Handle:timer, any:player )
{
    new client = GetClientOfUserId(player);

    if(client <= 0) return Plugin_Handled;
    if(!IsClientInGame(client)) return Plugin_Handled;
    if(!IsPlayerAlive(client)) return Plugin_Handled;
    if(!IsWeaponOnlyEnabled()) return Plugin_Handled;

    new String:weapon[WEAPON_NAME_SIZE];
    GetConVarString(g_Cvar_TargetWeapon, weapon, sizeof(weapon));
    StripInvalidWeapons(client, weapon);

    return Plugin_Handled;
}

ForceEquipWeapon(client, const String:weapon[])
{
    new String:tmp[WEAPON_NAME_SIZE];

    GivePlayerItem(client, weapon);

    Format(tmp, sizeof(tmp), "use %s", weapon);
    ClientCommand(client, tmp);//TODO switch to fake?
}

ForceEquipWeaponAll(const String:weapon[])
{
    for (new client=1; client <= MaxClients; client++)
    {
        if(!IsClientInGame(client)) continue;
        if(!IsPlayerAlive(client)) continue;

        ForceEquipWeapon(client, weapon);
    }
}

public Action:Timer_Repeat(Handle:timer)
{
    if(!IsWeaponOnlyEnabled()) return Plugin_Continue;

    //LogMessage("HIT %d", time_left);//TODO
    new String:weapon[WEAPON_NAME_SIZE];
    GetConVarString(g_Cvar_TargetWeapon, weapon, sizeof(weapon));
    
    StripInvalidWeaponsAll(weapon);

    return Plugin_Handled;
}

StripInvalidWeapons(client, const String:target_weapon[])
{
    decl String:class_name[WEAPON_NAME_SIZE], String:target_weapon2[WEAPON_NAME_SIZE];
    new weapon_ent, strip_occured=false, has_target_weapon=false;

    //Format(target_weapon2, sizeof(target_weapon2), "%s2", target_weapon);
    for (new slot=0; slot<6; slot++)
    {
        weapon_ent = GetPlayerWeaponSlot(client, slot);
        if(weapon_ent <= 0) continue;

        GetEdictClassname(weapon_ent, class_name, sizeof(class_name));

        if(StrEqual(class_name, target_weapon))
        {
            has_target_weapon = true;
        }

        if(!(StrEqual(class_name, target_weapon) || StrEqual(class_name, "weapon_fists")) )
        {
            strip_occured=true;
            RemovePlayerItem(client, weapon_ent);
            RemoveEdict(weapon_ent);
        }
    }

    if(strip_occured && !has_target_weapon)
    {
        ForceEquipWeapon(client, target_weapon);
    }

}

StripInvalidWeaponsAll(const String:target_weapon[])
{
    for (new client=1; client <= MaxClients; client++)
    {
        if(!IsClientInGame(client)) continue;
        if(!IsPlayerAlive(client)) continue;

        StripInvalidWeapons(client, target_weapon);
    }
}
