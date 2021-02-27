#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

#include "class_system/definitions.inc"
#include "class_system/public_data.sp"
#include "class_system/core_setup.sp"
#include "class_system/player_functions.sp"
#include "class_system/functions.sp"
#include "class_system/timers.sp"
#include "class_system/player_classes.sp"
#include "class_system/player_skills.sp"
#include "class_system/admin_commands.sp"
 
public Plugin:myinfo =
{
	name = "Zombie Panic: Source Class System",
	author = "Rawr",
	description = "Class System for Zombie Panic: Source",
	version = "1.4.0",
	url = ""
};

public OnPluginStart()
{
	SetupEventHooks();
	SetupHandles();
	InitializePlugin();
	RegisterCommands();

	CreateTimer(10.0, BleedThink, _, TIMER_REPEAT);
}

public OnClientDisconnect(Client)
{
	ClearPlayerData(Client, true);
}

public OnClientPutInServer(Client)
{
	ClientCommand(Client, "bind 8 slot8");
	ClientCommand(Client, "bind 9 \x22menuselect 9\x22");
	ClientCommand(Client, "bind 0 \x22menuselect 10;slot1\x22");
}

public OnMapStart()
{
	GetCurrentMap(CurrentMap, sizeof(CurrentMap)); 
	g_PlayerResource = FindResourceEntity();
	PrecacheFiles();
	ClearGlobalVariables();
	ClearAllPlayerData(true);
}

public Action:PrePlayerDeath(Handle:event, const String:Name[], bool:Broadcast)
{
	decl Client, Attacker, LastAttacker, cTeam, aTeam;
	Client = GetClientOfUserId(GetEventInt(event, "userid"));
	Attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	LastAttacker = GetLastAttacker(Client);
	
	if (Attacker == Client && IsPlayer(LastAttacker))
	{
		cTeam = GetClientTeam(Client);
		aTeam = GetClientTeam(LastAttacker);
		SetEventString(event, "weapon", "world");
		SetEventInt(event, "attacker", GetClientUserId(LastAttacker));
		SetTeamScore(cTeam, (GetTeamScore(cTeam) + 1));
		SetTeamScore(aTeam, (GetTeamScore(aTeam) + 1));
		SetEntProp(Client, Prop_Data, "m_iFrags", (GetEntProp(Client, Prop_Data, "m_iFrags", 4) + 1), 4);
		SetEntProp(LastAttacker, Prop_Data, "m_iFrags", (GetEntProp(LastAttacker, Prop_Data, "m_iFrags", 4) + 1), 4);
		SetEntProp(Client, Prop_Data, "m_iDeaths", (GetEntProp(Client, Prop_Data, "m_iDeaths", 4) - 1), 4);
	}
	
	return Plugin_Continue;
}

public Action:PlayerDeath(Handle:event, const String:Name[], bool:Broadcast)
{
	decl Client, Attacker, cTeam;
	Client = GetClientOfUserId(GetEventInt(event, "userid"));
	Attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	cTeam = GetClientTeam(Client);
	
 	ClearPlayerData(Client, false);
	
	for (new x = NONE; x <= GetRandomInt(4, 7); x++)
	{
		Bleed(Client, 12, cTeam, true);
	}
	
	switch (cTeam)
	  {
		case HUMAN:
		{
			//if (Attacker && GetClientTeam(Attacker) == ZOMBIE)
			//{
			//	HandleHumanRagdoll(Client, Attacker);
			//}
			FadeClientScreen(Client, 255, 2000, FADE_OUT_STAY);
		}
	 	case ZOMBIE:
		{
			CreateTimer(3.0, Dissolve, Client);
		}
	}

	return Plugin_Continue;
}

public Action:PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	decl Client, cTeam;
	Client = GetClientOfUserId(GetEventInt(event, "userid"));
	cTeam = GetClientTeam(Client);
	
	if (pDataInt[CLASS][ROUND][Client] != CLASS_NONE)
	{
		ClearPlayerData(Client, false);
	}
 
	SetPlayerDefaults(Client, cTeam); 
 
	switch (cTeam)
	{
		case HUMAN, ZOMBIE:
		{
			SetSpawnModel(Client, cTeam);
			
			if (RoundStarted)
			{
				OpenClassMenu(Client, cTeam);
			}
		}
	}
	
	return Plugin_Continue;
}

public Action:PlayerHurt(Handle:event, const String:name[], bool:dontBroadcast)
{
	decl Client, Attacker, cTeam, aTeam;
	Client = GetClientOfUserId(GetEventInt(event, "userid"));
	Attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	cTeam = GetClientTeam(Client);

	if (IsPlayer(Attacker))
	{
		aTeam = GetClientTeam(Attacker);
		if  (Client != Attacker)
		{
			SetLastAttacker(Client, Attacker);
		  	for (new x = NONE; x < GetRandomInt(1, 4); x++)
			{
	 			Bleed(Client, 12, cTeam, true);
			}
			
			switch (aTeam)
			{
				case ZOMBIE:
				{
					switch (pDataBool[IS_CARRIER][ROUND][Client])
					{
						case true:
						{
							InfectPlayer(Client, 20, GetRandomInt(30, 75));
						}
						case false:
						{
							InfectPlayer(Client, 10, GetRandomInt(100, 160));
						}
					}
				}
			}
		}
	}
						
	switch (cTeam)
	{
		case HUMAN: 
		{
			pDataBool[IS_BANDAGED][ROUND][Client] = false;
			switch (pDataInt[CLASS][ROUND][Client])
			{
				case MEDIC:
				{
					if (pDataHandle[TIMER_REGEN][ROUND][Client] == INVALID_HANDLE)
					{
						pDataHandle[TIMER_REGEN][ROUND][Client] = CreateTimer(8.0, Regen, Client, TIMER_REPEAT);
						
					}
				}
			}			
		}
		case ZOMBIE:
		{ 
			switch (pDataInt[CLASS][ROUND][Client])
			{
				case HULKER, FULMINATOR:
				{
					if (pDataHandle[TIMER_REGEN][ROUND][Client] == INVALID_HANDLE)
					{
						pDataHandle[TIMER_REGEN][ROUND][Client] = CreateTimer(2.0, Regen, Client, TIMER_REPEAT);
					}
				}
			}
		}
	}

	return Plugin_Continue;
}

public Action:RoundRestart(Handle:event, const String:name[], bool:dontBroadcast)
{
	ClearGlobalVariables();
	ClearAllPlayerData(false);
	
	return Plugin_Continue;
} 

public Action:BreakProp(Handle:event, const String:Name[], bool:Broadcast)
{
	decl String:iName[64], Entity;
	
	Entity = GetEventInt(event, "entindex");

	GetEntPropString(Entity, Prop_Data, "m_iName", iName, sizeof(iName));

	switch(StringToInt(iName))
	{
		case CONSTRUCTOR_PROP:
		{
			decl cPropEntity;
			
			for (new i = 0; i < MAX_PROPS; i++)
			{
				cPropEntity = pPlayerProps[i][PROP_ENTITY];

				if (cPropEntity == Entity)
				{
					decl cPropOwner;
					cPropOwner = pPlayerProps[i][PROP_OWNER];

					if (IsClientInGame(cPropOwner) && IsPlayerAlive(cPropOwner))
					{
						if (pDataInt[CLASS][ROUND][cPropOwner] == CONSTRUCTOR && pDataInt[CLASS_TEAM][ROUND][cPropOwner] == HUMAN)
						{
							decl Breaker, Float:pWeight;
							Breaker = GetClientOfUserId(GetEventInt(event, "userid"));
							pWeight = pPropsWeight[pPlayerProps[i][PROP_WEIGHT]][ROUND];
							
							if (Breaker == cPropOwner)
							{
								pDataFloat[FLOAT_SKILL_1_DATA][ROUND][cPropOwner] -= pWeight;
							}
							else
							{
								switch (Breaker)
								{
									case NONE:
									{
										pDataFloat[FLOAT_SKILL_1_DATA][ROUND][cPropOwner] -= pWeight;
									}
									default:
									{
										if (IsPlayer(Breaker))
										{
											if (GetClientTeam(Breaker) == ZOMBIE)
											{
												pDataFloat[FLOAT_SKILL_1_DATA][ROUND][cPropOwner] -= pWeight;
												pDataFloat[FLOAT_SKILL_1_DATA_2][ROUND][cPropOwner] -= (pWeight / 2);										
											}
											else
											{
												pDataFloat[FLOAT_SKILL_1_DATA][ROUND][cPropOwner] -= pWeight;
											}
										}
										else
										{
											pDataFloat[FLOAT_SKILL_1_DATA][ROUND][cPropOwner] -= pWeight;
										}
									}
								}
							}
						}
					}
					
					ClearSingleProp(i);
					break;
				}
			}
		}
		case IKAR_BOMB:
		{
			decl cPropEntity;
			
			for (new i = 0; i < MAX_PROPS; i++)
			{
				cPropEntity = pPlayerProps[i][PROP_ENTITY];

				if (cPropEntity == Entity)
				{
					decl cPropOwner;
					cPropOwner = pPlayerProps[i][PROP_OWNER];
					HandleChemistBombs(Entity, cPropOwner, IKAR_BOMB);
					ClearSingleProp(i);
					break;
				}	
			}
		}
		case ACID_BOMB:
		{
			decl cPropEntity;
			
			for (new i = 0; i < MAX_PROPS; i++)
			{
				cPropEntity = pPlayerProps[i][PROP_ENTITY];

				if (cPropEntity == Entity)
				{
					decl cPropOwner;
					cPropOwner = pPlayerProps[i][PROP_OWNER];
					HandleChemistBombs(Entity, cPropOwner, ACID_BOMB);
					ClearSingleProp(i);
					break;
				}	
			}
		}
	}

	return Plugin_Continue;
}

public Action:Command_ClassSkill1(Client, Args)
{
	switch (IsPlayerAlive(Client))
	{
		case true:
		{
			switch (pDataInt[CLASS_TEAM][ROUND][Client])
			{
				case HUMAN:
				{
					UseHumanSkill(Client, SKILL_1);
				}
				case ZOMBIE:
				{
					UseZombieSkill(Client, SKILL_1);
				}
			}
		}
		case false:
		{
			PrintToChat(Client, "You can't use skills while dead.");
		}
	}
	
	return Plugin_Handled;
}

public Action:Command_ClassSkill2(Client, Args)
{
	switch (IsPlayerAlive(Client))
	{
		case true:
		{
			switch (pDataInt[CLASS_TEAM][ROUND][Client])
			{
				case HUMAN:
				{
					UseHumanSkill(Client, SKILL_2);
				}
				case ZOMBIE:
				{
					UseZombieSkill(Client, SKILL_2);
				}
			}
		}
		case false:
		{
			PrintToChat(Client, "You can't use skills while dead.");
		}
	}

	return Plugin_Handled;
}

public Action:Command_ClassList(Client, Args)
{
	decl cTeam;
	cTeam = GetClientTeam(Client);
	
	switch (cTeam)
	{
		case HUMAN, ZOMBIE:
		{
			OpenClassList(Client, cTeam);
		}
		default:
		{
			PrintToChat(Client, "You are not on a team.");
		}
	}
	return Plugin_Handled;
}

public Action:Command_ClassMenu(Client, Args)
{
	switch (pDataInt[CLASS][ROUND][Client])
	{
		case CLASS_NONE:
		{
			decl Float:fMenuTime, cTeam;
			fMenuTime = pDataFloat[FLOAT_MENU_TIME][ROUND][Client];
			cTeam = GetClientTeam(Client);
			
			if (fMenuTime <= (GetGameTime() - 2.0) || fMenuTime == 0.0)
			{
				if ((GetGameTime() - 120.0) <= RoundTime || cTeam == ZOMBIE || GetConVarInt(g_hTestMode))
				{
					OpenClassMenu(Client, cTeam);
				}
				else
				{
					PrintToChat(Client, "You can't change your class until next round.");
				}
			}
			else
			{
				decl Float:tRemain;
				tRemain = (3.0 - (GetGameTime() - fMenuTime));
				PrintToChat(Client, "You can change your class in %s second(s).", ConvertFloatToText(tRemain));
			}
		}
		default:
		{ 
			PrintToChat(Client, "You have already set your class.");
		}
	}

	return Plugin_Handled;
}

public Action:Command_Stuck(Client, Args)
{
	decl Float:fStuckTime, Float:cGameTime;
	fStuckTime = pDataFloat[FLOAT_UNSTUCK_TIME][ROUND][Client];
	cGameTime = GetGameTime();
	
	if (fStuckTime <= (cGameTime - 180.0) || fStuckTime == 0.0)
	{
		switch (GetClientTeam(Client))
		{
			case HUMAN, ZOMBIE:
			{
				pDataFloat[FLOAT_UNSTUCK_TIME][ROUND][Client] = cGameTime;
				pDataHandle[TIMER_UNSTUCK][ROUND][Client] = CreateTimer(5.0, UnstuckTeleport, Client);
				PrintToChat(Client, "You will be unstuck in 5 seconds.");
			}
			default:
			{
				PrintToChat(Client, "You are not on a team.");
			}
		}
	}
	else
	{
		decl Float:tRemain;
		tRemain = (181.0 - (cGameTime - fStuckTime));
		PrintToChat(Client, "You can use !stuck again in %s seconds.", ConvertFloatToText(tRemain));
	}
	return Plugin_Handled;
}

OpenClassMenu(Client, cTeam)
{
	switch (RoundStarted)
	{
		case true:
		{
			if (IsPlayerAlive(Client))
			{
				if (GetClientHealth(Client) >= pDataInt[MAXHEALTH][ROUND][Client])
				{ 
					switch (cTeam)
					{
						case HUMAN, ZOMBIE:
						{
							new Handle:hClassMenu = CreateMenu(ClassCategoryHandler);
							decl String:sClassNum[64], String:Temp[64], cTeamArray, cLimit, cLimitCurrent;
							
							cTeamArray = (cTeam - 2);

							SetMenuTitle(hClassMenu, "+ Pick a Class");
							
							for (new x = NONE; iClassLimit[x][cTeamArray] != NONE; x++)
							{
								IntToString(x, sClassNum, sizeof(sClassNum));
								
								cLimit = iClassLimit[x][cTeamArray];
								cLimitCurrent = iClassLimitCurrent[x][cTeamArray];
								
								if (cLimitCurrent < cLimit)
								{
									if ((pDataInt[LAST_CLASS][MAP][Client] != x && cTeam == HUMAN) || cLimit != 1 || cTeam == ZOMBIE)
									{
										Format(Temp, sizeof(Temp), "%s (%i/%i)", sClassName[x][cTeamArray], cLimitCurrent, cLimit);
										AddMenuItem(hClassMenu, sClassNum, Temp);
									}
									else
									{
										Format(Temp, sizeof(Temp), "%s (Blocked)", sClassName[x][cTeamArray]);
										AddMenuItem(hClassMenu, sClassNum, Temp, ITEMDRAW_DISABLED);
									}
								}
								else
								{
									Format(Temp, sizeof(Temp), "%s (Full)", sClassName[x][cTeamArray]);
									AddMenuItem(hClassMenu, sClassNum, Temp, ITEMDRAW_DISABLED);
								}
							}
							
							SetMenuExitButton(hClassMenu, true);
							DisplayMenu(hClassMenu, Client, MENU_TIME_FOREVER);
							
							pDataFloat[FLOAT_MENU_TIME][ROUND][Client] = GetGameTime();
						} 
					}
				}
				else
				{
					PrintToChat(Client, "You need full health to change your class.");
				}
			}
			else
			{
				PrintToChat(Client, "You can't change classes while dead.");
			}
		}
		case false:
		{
			PrintToChat(Client, "The round has not started yet.");
		}
	}
}

public ClassCategoryHandler(Handle:hClassMenu, MenuAction:action, Client, SelectedOption)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			decl String:Temp[64], pClass;
			
			GetMenuItem(hClassMenu, SelectedOption, Temp, sizeof(Temp));
			pClass = StringToInt(Temp);

			switch (pClass)
			{
				case CLASS_NONE:
				{
					PrintToChat(Client, "Type !class to pick a class.");
				}
				default:
				{
					if (IsPlayerAlive(Client))
					{
						if (GetClientHealth(Client) >= pDataInt[MAXHEALTH][ROUND][Client])
						{
							decl cTeam, cTeamArray;
							cTeam = GetClientTeam(Client);
							cTeamArray = (cTeam - 2);
							
							if (iClassLimitCurrent[pClass][cTeamArray] < iClassLimit[pClass][cTeamArray])
							{
								switch (cTeam)
								{
									case HUMAN:
									{
										SetHumanClass(Client, pClass);
									}
									case ZOMBIE:
									{
										SetZombieClass(Client, pClass);
									}
								}
							}
							else
							{
								OpenClassMenu(Client, cTeam);
								PrintToChat(Client, "%s is full. Please pick another class.", sClassName[pClass][cTeamArray]);
							}
						}
						else
						{
							PrintToChat(Client, "You need full health to change your class.");
						}
					}
					else
					{
						PrintToChat(Client, "You can't change classes while dead.");
					}
				}
			}
		}
		
		case MenuAction_Cancel:
		{
			if (IsClientInGame(Client))
			{
				PrintToChat(Client, "Type !class to set your class.");
			}
		}
		
		case MenuAction_End:
		{
			CloseHandle(hClassMenu);
		}
	}
} 

OpenClassList(Client, cTeam)
{
	new Handle:CurrentUserPanel = CreatePanel(GetMenuStyleHandle(MenuStyle_Radio));
	decl String:pName[64], String:Temp[64];
	decl cClass;
	
	SetPanelTitle(CurrentUserPanel, "+ Player Class List" );
	 
	for(new x = 1; x <= MaxClients; x++)
	{
		if(IsClientInGame(x) && IsPlayerAlive(x))
		{
			cClass = pDataInt[CLASS][ROUND][x];
			
			if (cTeam == pDataInt[CLASS_TEAM][ROUND][x] && cClass != CLASS_NONE)
			{
				GetClientName(x, pName, sizeof(pName));
				Format(Temp, sizeof(Temp), "%s - %s", sClassName[cClass][pDataInt[CLASS_TEAM][ROUND][x] - 2], pName); 
				DrawPanelText(CurrentUserPanel, Temp);
			}
		} 
	}
 
	DrawPanelItem(CurrentUserPanel, "Exit");
	SendPanelToClient(CurrentUserPanel, Client, BlankMenuHandler, 25);
		
	CloseHandle(CurrentUserPanel);
}