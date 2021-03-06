/**
 * vim: set ts=4 :
 * =============================================================================
 * Weapon Only
 * Force specific weapons in Fistful of Frags
 *
 * Copyright 2021 CrimsonTautology
 * =============================================================================
 *
 */

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>

#define PLUGIN_VERSION "1.10.0"
#define PLUGIN_NAME  "[FoF] Weapon Only"

#define WEAPON_NAME_SIZE 32

public Plugin myinfo =
{
    name = PLUGIN_NAME,
    author = "CrimsonTautology",
    description = "Allows one type of weapon only",
    version = PLUGIN_VERSION,
    url = "http://github.com/CrimsonTautology/sm-weapon-only"
};

ConVar g_Cvar_Enabled;
ConVar g_Cvar_TargetWeapon;

public void OnPluginStart()
{
    CreateConVar(
            "sm_weapon_only_version", PLUGIN_VERSION, PLUGIN_NAME, FCVAR_SPONLY
            | FCVAR_REPLICATED | FCVAR_NOTIFY | FCVAR_DONTRECORD);

    g_Cvar_Enabled = CreateConVar(
            "sm_weapon_only",
            "1",
            "Set to 1 to enable the weapon only plugin",
            FCVAR_REPLICATED | FCVAR_NOTIFY,
            true,
            0.0,
            true,
            1.0);
    g_Cvar_TargetWeapon = CreateConVar(
            "sm_weapon_only_weapon",
            "none",
            "The class name of the weapon",
            FCVAR_REPLICATED | FCVAR_NOTIFY
            );

    RegAdminCmd("sm_only", Command_Only, ADMFLAG_SLAY,
            "[ADMIN] Set to one type of weapon only.");
    RegAdminCmd("sm_give", Command_Give, ADMFLAG_SLAY,
            "[ADMIN] Give yourself a weapon.");

    g_Cvar_Enabled.AddChangeHook(OnEnabledChange);
    g_Cvar_TargetWeapon.AddChangeHook(OnTargetWeaponChange);

    HookEvent("player_spawn", Event_PlayerSpawn);

    AutoExecConfig();
}

public void OnMapStart()
{
    CreateTimer(1.0, Timer_Repeat, .flags = TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

void OnEnabledChange(Handle cvar, const char[] oldValue, const char[] newValue)
{
    if(cvar != g_Cvar_Enabled) return;

    bool was_on = !!StringToInt(oldValue);
    bool now_on = !!StringToInt(newValue);

    // when changing from off to on
    if(!was_on && now_on)
    {
        char weapon[WEAPON_NAME_SIZE];
        g_Cvar_TargetWeapon.GetString(weapon, sizeof(weapon));
        StripInvalidWeaponsAll(weapon);
    }
}

void OnTargetWeaponChange(Handle cvar, const char[] oldValue, const char[] newValue)
{
    if(cvar != g_Cvar_TargetWeapon) return;
    if(!IsWeaponOnlyEnabled()) return;

    StripInvalidWeaponsAll(newValue);
}

bool IsWeaponOnlyEnabled()
{
    return g_Cvar_Enabled.BoolValue;
}

void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    if(IsWeaponOnlyEnabled())
    {
        int player = event.GetInt("userid");
        CreateTimer(0.0, PlayerSpawnDelay, player, TIMER_FLAG_NO_MAPCHANGE);
    }
}

Action PlayerSpawnDelay(Handle timer, any player)
{
    int client = GetClientOfUserId(player);

    if(client <= 0) return Plugin_Handled;
    if(!IsClientInGame(client)) return Plugin_Handled;
    if(!IsPlayerAlive(client)) return Plugin_Handled;
    if(!IsWeaponOnlyEnabled()) return Plugin_Handled;

    char weapon[WEAPON_NAME_SIZE];
    g_Cvar_TargetWeapon.GetString(weapon, sizeof(weapon));
    StripInvalidWeapons(client, weapon);

    return Plugin_Handled;
}

void ForceEquipWeapon(int client, const char[] weapon)
{
    char tmp[WEAPON_NAME_SIZE];

    GivePlayerItem(client, weapon);

    Format(tmp, sizeof(tmp), "use %s", weapon);
    ClientCommand(client, tmp);
}

Action Timer_Repeat(Handle timer)
{
    if(!IsWeaponOnlyEnabled()) return Plugin_Continue;

    char weapon[WEAPON_NAME_SIZE];
    g_Cvar_TargetWeapon.GetString(weapon, sizeof(weapon));

    StripInvalidWeaponsAll(weapon);

    return Plugin_Handled;
}

void StripInvalidWeapons(int client, const char[] target_weapon)
{
    char class_name[WEAPON_NAME_SIZE], target_weapon2[WEAPON_NAME_SIZE];
    int weapon_ent;
    bool strip_occured=false, has_target_weapon=false;
    int offs = FindSendPropInfo("CBasePlayer","m_hMyWeapons");

    Format(target_weapon2, sizeof(target_weapon2), "%s2", target_weapon);
    for(int i = 0; i <= 47; i++)
    {
        weapon_ent = GetEntDataEnt2(client,offs + (i * 4));
        if(weapon_ent == -1) continue;
        GetEdictClassname(weapon_ent, class_name, sizeof(class_name));

        if(StrEqual(class_name, target_weapon) || StrEqual(class_name, target_weapon2))
        {
            has_target_weapon = true;
        }

        if(!(StrEqual(class_name, target_weapon) || StrEqual(class_name, target_weapon2) || StrEqual(class_name, "weapon_fists")) )
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

void StripInvalidWeaponsAll(const char[] target_weapon)
{
    for (int client=1; client <= MaxClients; client++)
    {
        if(!IsClientInGame(client)) continue;
        if(!IsPlayerAlive(client)) continue;

        StripInvalidWeapons(client, target_weapon);
    }
}

Action Command_Only(int client, int args)
{
    if(client <= 0) return Plugin_Handled;
    if(!IsClientInGame(client)) return Plugin_Handled;

    Menu menu = new Menu(WeaponOnlyMenuHandler);

    BuildWeaponMenu(menu);

    menu.Display(client, 20);

    return Plugin_Handled;
}

Action Command_Give(int client, int args)
{
    if(client <= 0) return Plugin_Handled;
    if(!IsClientInGame(client)) return Plugin_Handled;

    Menu menu = new Menu(WeaponGiveMenuHandler);

    BuildWeaponMenu(menu);

    menu.Display(client, 20);

    return Plugin_Handled;
}

void BuildWeaponMenu(Menu menu)
{
    menu.SetTitle("Choose Weapon");

    menu.AddItem("none", "Disable");
    menu.AddItem("weapon_knife", "Knife");
    menu.AddItem("weapon_axe", "Hatchet");
    menu.AddItem("weapon_machete", "Machete");
    menu.AddItem("weapon_dynamite", "Dynamite");
    menu.AddItem("weapon_dynamite_black", "Black Dynamite");
    menu.AddItem("weapon_dynamite_belt", "Dynamite Belt");
    menu.AddItem("weapon_deringer", "Deringer");
    menu.AddItem("weapon_hammerless", "Hammerless Pocket Revolver");
    menu.AddItem("weapon_coltnavy", "Colt Navy 1851");
    menu.AddItem("weapon_remington_army", "Remington Army 1858");
    menu.AddItem("weapon_schofield", "SW Schofield");
    menu.AddItem("weapon_volcanic", "Volcanic Pistol");
    menu.AddItem("weapon_maresleg", "Mare's Leg");
    menu.AddItem("weapon_peacemaker", "Peacemaker");
    menu.AddItem("weapon_walker", "Colt Walker");
    menu.AddItem("weapon_sawedoff_shotgun", "Sawed-Off Shotgun");
    menu.AddItem("weapon_coachgun", "Coach Shotgun");
    menu.AddItem("weapon_shotgun", "Pump Shotgun W1893");
    menu.AddItem("weapon_bow", "Bow");
    menu.AddItem("weapon_carbine", "Smith Carbine");
    menu.AddItem("weapon_henryrifle", "Henry Rifle");
    menu.AddItem("weapon_spencer", "Spencer Carbine");
    menu.AddItem("weapon_sharps", "Sharps Rifle");

    menu.AddItem("weapon_whiskey", "Whiskey");

    menu.AddItem("weapon_fists_ghost", "FistsGhost");
    menu.AddItem("weapon_ghostgun", "Ghost Gun");

    menu.AddItem("weapon_smg1", "Gatling Gun");
    menu.AddItem("weapon_rpg", "RPG");
    menu.AddItem("weapon_crossbow", "XBow");
    menu.AddItem("weapon_ar2", "AR2");
    menu.AddItem("weapon_357", "HL2 Magnum");
    menu.AddItem("weapon_pistol", "HL2 Pistol");
    menu.AddItem("weapon_frag", "HL2 Grenade");
    menu.AddItem("weapon_physcannon", "Gravity Gun");
    menu.AddItem("weapon_crowbar", "Crowbar");
    menu.AddItem("weapon_stunstick", "Stun Stick");
}

int WeaponOnlyMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
    switch (action)
    {
        case MenuAction_Select:
            {
                char weapon[32];
                menu.GetItem(param2, weapon, sizeof(weapon));

                if(StrEqual(weapon, "none"))
                {
                    g_Cvar_Enabled.SetBool(false);
                }else{
                    g_Cvar_TargetWeapon.SetString(weapon);
                    g_Cvar_Enabled.SetBool(true);
                }
            }
        case MenuAction_End: delete menu;
    }
}

int WeaponGiveMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
    switch (action)
    {
        case MenuAction_Select:
            {
                int client = param1;
                char weapon[32];
                menu.GetItem(param2, weapon, sizeof(weapon));

                if(StrEqual(weapon, "none"))
                {
                    //PASS
                }else{
                    ForceEquipWeapon(client, weapon);
                }
            }
        case MenuAction_End: delete menu;
    }
}
