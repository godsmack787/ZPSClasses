#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

#define PLUGIN_VERSION "1.3.0"
 
#define SPECTATOR		1
#define HUMAN			2
#define ZOMBIE			3
#define OBSERVER		4

#define PANEL_BACK	1
#define PANEL_EXIT	2
#define SELECT_CLASS	0
#define SELECT_SKILL1	1
#define SELECT_SKILL2	2

#define NONE		0

new Handle:hGameConf = INVALID_HANDLE;
new Handle:hShowBriefing = INVALID_HANDLE;
stock Handle:hHideBriefing = INVALID_HANDLE;

new String:sBindKeys[64] = "abcdefghijklmnopqrstuvwxyz,./;'[]-=";

new bool:HasViewedMOTD[64];

public Plugin:myinfo =
{
	name = "Zombie Panic: Source Class System Helper",
	author = "Rawr",
	description = "Class Help System for Zombie Panic: Source",
	version = PLUGIN_VERSION,
	url = "" 
};

public OnPluginStart() 
{ 
	HookEvent("player_spawn",PlayerSpawn);
	RegConsoleCmd("sm_bind", Command_Bind);
	RegConsoleCmd("sm_help", Command_Help);
	RegConsoleCmd("sm_motd", Command_MOTD);
	RegConsoleCmd("sm_objectives", Command_Objectives);
	 
	hGameConf = LoadGameConfigFile("sdktools.games.ep2");
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Virtual, "ShowBriefingMenu");
	hShowBriefing = EndPrepSDKCall();
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Virtual, "HideBriefingMenu");
	hHideBriefing = EndPrepSDKCall();
	
	CloseHandle(hGameConf);
}

public OnClientDisconnect(Client)
{
	HasViewedMOTD[Client] = false;
}

public Action:PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new Client = GetClientOfUserId(GetEventInt(event, "userid"));

	if (GetClientTeam(Client) == OBSERVER)
	{
		if (!HasViewedMOTD[Client])
		{
			PrintToChat(Client, "[SM] Type !help to get help on the class system.");
			ShowMOTDPanel(Client, "Server Information", "http://www.clanvortex.com/zps/help_system/motd.html", 2);
			HasViewedMOTD[Client] = true;
		}
		OpenSpawnMenu(Client);
	}
	
	return Plugin_Continue;
}

public Action:Command_Objectives(Client, Args)
{
	switch (GetClientTeam(Client))
	{
		case OBSERVER:
		{
			SDKCall(hShowBriefing, Client);
		}
		default:
		{
			PrintToChat(Client, "That command can only be used in the ready room.");
		}
	}
	return Plugin_Handled;
}

public Action:Command_MOTD(Client, Args)
{
	ShowMOTDPanel(Client, "Server Information", "http://www.clanvortex.com/zps/help_system/motd.html", 2);
	return Plugin_Handled;
}

public Action:Command_Help(Client, Args)
{
	ShowMOTDPanel(Client, "Server Information", "http://www.clanvortex.com/zps/help_system/help.html", 2);
	return Plugin_Handled;
}

public Action:Command_Bind(Client, Args)
{
	OpenKeyWarningPanel(Client);
	return Plugin_Handled;
}

public OpenKeyWarningPanel(Client)
{
	new Handle:HelpPanel = CreatePanel(GetMenuStyleHandle(MenuStyle_Radio));
		
	SetPanelTitle(HelpPanel, ": WARNING :" );
	DrawPanelText(HelpPanel, " ");
	DrawPanelText(HelpPanel, "Binding a key will overwrite your old bind on that key.");
	DrawPanelText(HelpPanel, "Are you sure you wish to do this?");
	DrawPanelText(HelpPanel, " ");
	DrawPanelItem(HelpPanel, "Yes");
	DrawPanelItem(HelpPanel, "No");
	SendPanelToClient(HelpPanel, Client, WarningPanelMenuHandler, 400);
		
	CloseHandle(HelpPanel);
}

public WarningPanelMenuHandler(Handle:menu, MenuAction:action, Client, SelectedOption)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			switch (SelectedOption)
			{
				case 1:
				{
					OpenBindMenu(Client);
				}
			
				case 2:
				{
					switch (GetClientTeam(Client))
					{
						case OBSERVER:
						{
							OpenSpawnMenu(Client);
						}
					}
				}
			
				default:
				{
					OpenKeyWarningPanel(Client);
				}
			}
		}
	}
}

public OpenBindMenu(Client)
{
	new Handle:hBindMenu = CreateMenu(BindMenuCategoryHandler);
				
	SetMenuTitle(hBindMenu, "+ Bind Menu");

	AddMenuItem(hBindMenu, "0", "Select Class");
	AddMenuItem(hBindMenu, "1", "Skill 1");
	AddMenuItem(hBindMenu, "2", "Skill 2");
	SetMenuExitButton(hBindMenu, true);
	DisplayMenu(hBindMenu, Client, 750);
}

public BindMenuCategoryHandler(Handle:hBindMenu, MenuAction:action, Client, SelectedOption)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			new String:Temp[32], pBindItemSelected;
			GetMenuItem(hBindMenu, SelectedOption, Temp, sizeof(Temp));
			pBindItemSelected = StringToInt(Temp);

			switch (pBindItemSelected)
			{
				case SELECT_CLASS:
				{
					BindKeyMenu(Client, SELECT_CLASS);
				}
				
				case SELECT_SKILL1:
				{
					BindKeyMenu(Client, SELECT_SKILL1);
				}
				
				case SELECT_SKILL2:
				{
					BindKeyMenu(Client, SELECT_SKILL2);
				}
				
				default:
				{
					OpenBindMenu(Client);
				}
			}
		}

		case MenuAction_End:
		{
			CloseHandle(hBindMenu);
		}
	}
}

public BindKeyMenu(Client, BindSelected)
{
	new Handle:hBindMenu;
	
	switch (BindSelected)
	{
		case SELECT_CLASS:
		{
			hBindMenu = CreateMenu(ClassBindCategoryHandler);
		}
		
		case SELECT_SKILL1:
		{
			hBindMenu = CreateMenu(Skill1BindCategoryHandler);
		}
		
		case SELECT_SKILL2:
		{
			hBindMenu = CreateMenu(Skill2BindCategoryHandler);
		}
	}

	SetMenuTitle(hBindMenu, "+ Select Key");

	for(new x = NONE; x < 35; x++)
	{ 
		decl String:Temp[2], String:Temp2[2];
		IntToString(x, Temp, sizeof(Temp));
		Format(Temp2, sizeof(Temp2), "%s\x0", sBindKeys[x]);
		AddMenuItem(hBindMenu, Temp, Temp2);
	}
	
	SetMenuExitButton(hBindMenu, true);
	DisplayMenu(hBindMenu, Client, 600);
}

public ClassBindCategoryHandler(Handle:hBindMenu, MenuAction:action, Client, SelectedOption)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			SetBind(Client, "\x22sm_class\x22", SelectedOption);
			OpenBindMenu(Client);
		}

		case MenuAction_End:
		{
			if (Client && IsClientConnected(Client) && IsClientInGame(Client) && GetClientTeam(Client) == OBSERVER)
			{
				OpenSpawnMenu(Client);
			}
			CloseHandle(hBindMenu);
		}
	}
}

public Skill1BindCategoryHandler(Handle:hBindMenu, MenuAction:action, Client, SelectedOption)
{

	switch (action)
	{
		case MenuAction_Select:
		{
			SetBind(Client, "\x22sm_skill1\x22", SelectedOption);
			OpenBindMenu(Client);
		}

		case MenuAction_End:
		{
			if (Client && IsClientConnected(Client) && IsClientInGame(Client) && GetClientTeam(Client) == OBSERVER)
			{
				OpenSpawnMenu(Client);
			}
			CloseHandle(hBindMenu);
		}
	}
}

public Skill2BindCategoryHandler(Handle:hBindMenu, MenuAction:action, Client, SelectedOption)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			SetBind(Client, "\x22sm_skill2\x22", SelectedOption);
			OpenBindMenu(Client);
		}

		case MenuAction_End:
		{
			if (Client && IsClientConnected(Client) && IsClientInGame(Client) && GetClientTeam(Client) == OBSERVER)
			{
				OpenSpawnMenu(Client);
			}
			CloseHandle(hBindMenu);
		}
	}
}

OpenSpawnMenu(Client)
{
	new Handle:hMainMenu = CreateMenu(SpawnCategoryHandler);
				
	SetMenuTitle(hMainMenu, "+ Main Menu");

	AddMenuItem(hMainMenu, "0", "Join Survivors");
	AddMenuItem(hMainMenu, "1", "Join Zombies");
	AddMenuItem(hMainMenu, "2", "Join Spectator");
	AddMenuItem(hMainMenu, "3", "Bind Menu");

	SetMenuExitButton(hMainMenu, true);
	DisplayMenu(hMainMenu, Client, 5000);
}

public SpawnCategoryHandler(Handle:hMainMenu, MenuAction:action, Client, SelectedOption)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			new String:Temp[32], pMenuItemSelected;
			GetMenuItem(hMainMenu, SelectedOption, Temp, sizeof(Temp));
			pMenuItemSelected = StringToInt(Temp);

			switch (pMenuItemSelected)
			{
				case 0:
				{
					ClientCommand(Client,"choose1");
				}
				
				case 1:
				{
					ClientCommand(Client,"choose2");
				}
				
				case 2:
				{
					ClientCommand(Client,"choose3");
				}
				case 3:
				{
					OpenKeyWarningPanel(Client);
				}
				default:
				{
					OpenSpawnMenu(Client);
				}
			}
		}

		case MenuAction_End:
		{
			CloseHandle(hMainMenu);
		}
	}
}

SetBind(Client, String:Command[128], SelectedKey)
{
	if (IsClientInGame(Client))
	{
		decl String:Temp[256], String:Temp2[2];
		
		Format(Temp2, sizeof(Temp2), "%s\x0", sBindKeys[SelectedKey]);
		Format(Temp, sizeof(Temp), "bind %s %s", Temp2, Command);
		ClientCommand(Client, Temp);
				
		PrintToChat(Client, "[SM] Bind set successfully.");
	}
}