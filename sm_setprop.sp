#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#define COMPARE_MATCH		0

new g_PlayerResource;
new Handle:hSetPlayerTeamModel = INVALID_HANDLE;

public Plugin:myinfo =
{
	name = "Testing Plugin",
	author = "Rawr",
	description = "Test Plugin",
	version = "1.0.0",
	url = ""
};

public OnPluginStart() 
{
	new Handle:hGameConf = INVALID_HANDLE;
	hGameConf = LoadGameConfigFile("sdktools.games.ep2");
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Virtual, "SetPlayerTeamModel");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	hSetPlayerTeamModel = EndPrepSDKCall();

	CloseHandle(hGameConf);
	
	RegConsoleCmd("sm_test", Command_Test);
	RegConsoleCmd("sm_findinfection", Command_FindInfection);
	RegConsoleCmd("sm_propint", Command_PropInt);
	RegConsoleCmd("sm_dataint", Command_DataInt);
	RegConsoleCmd("sm_findint", Command_FindDataInt);
	RegConsoleCmd("sm_propfloat", Command_PropFloat);
	RegConsoleCmd("sm_datafloat", Command_DataFloat);
	RegConsoleCmd("sm_findfloat", Command_FindDataFloat);
	RegConsoleCmd("sm_propvector", Command_PropVector);
	RegConsoleCmd("sm_gettarget", Command_GetTarget);
}

public Action:Command_Test(Client, args)
{
	if(args < 1)
	{
		PrintToConsole(Client, "[SM]  Incorrect Usage.");
		return Plugin_Handled;
	}
	
	decl String:sAmount[32], iAmount;
	GetCmdArg(1, sAmount, sizeof(sAmount));
	iAmount = StringToInt(sAmount);
	
	SDKCall(hSetPlayerTeamModel, Client, iAmount);
	return Plugin_Handled;
}

public Action:Command_FindInfection(Client, args)
{
	decl Float:tmp, Float:tTime;
	
	tTime = (60.0 + GetGameTime());
	
	PrintToConsole(Client, "Possible Infection Time Offsets:");
	
	for (new x = 4; x < 10000; x+=4)
	{
		tmp = GetEntDataFloat(Client, x);
		
		if (tmp >= (tTime - 15.0) && tmp <= (tTime + 15.0))
		{
			PrintToConsole(Client, "Offset: %i, Data: %f", x, tmp);
		}
	}

	return Plugin_Handled;
}

public OnMapStart()
{
	g_PlayerResource = FindResourceEntity();
	if (g_PlayerResource == 0) PrintToServer("Error Finding PlayerResource!");
}

public Action:Command_GetTarget(Client, args)
{
	new String:sName[32] = "None";
	decl Target;
	
	Target = GetClientAimTarget(Client, false);

	if (IsValidEdict(Target))
	{
		GetEdictClassname(Target, sName, sizeof(sName));
		PrintToChat(Client, "Class Name: %s / ID: %i", sName, Target);
	}
	
	PrintToChat(Client, "Class Name: %s / ID: %i", sName, Target);
	
	return Plugin_Handled;
}

public Action:Command_PropInt(Client, args)
{
	new String:sHandle[32], String:sAmount[32];
	
	if(args < 2)
	{
		if(args < 1)
		{
			PrintToConsole(Client, "[SM]  Incorrect Usage.");
			return Plugin_Handled;
		}
		else
		{
			decl tmp;
			GetCmdArg(1, sHandle, sizeof(sHandle));
			tmp = GetEntProp(Client, Prop_Data, sHandle, 4);
			PrintToConsole(Client, "Property: %s, Data: %i", sHandle, tmp);
			return Plugin_Handled;
		}
	}

	decl iAmount;
	
	GetCmdArg(1, sHandle, sizeof(sHandle));
	GetCmdArg(2, sAmount, sizeof(sAmount));

	iAmount = StringToInt(sAmount);

	SetEntProp(Client, Prop_Data, sHandle, iAmount, 4);
	return Plugin_Handled;
}

public Action:Command_DataInt(Client, args)
{
	new String:sOffset[32], String:sAmount[32];
	decl iAmount, iOffset;
	
	if(args < 2)
	{
		if(args < 1)
		{
			PrintToConsole(Client, "[SM]  Incorrect Usage.");
			return Plugin_Handled;
		}
		else
		{
			decl tmp;
			GetCmdArg(1, sOffset, sizeof(sOffset));
			iOffset = StringToInt(sOffset);
			tmp = GetEntData(Client, iOffset, 4);
			PrintToConsole(Client, "Offset: %i, Data: %i", iOffset, tmp);
			return Plugin_Handled;
		}
	}
	
	GetCmdArg(1, sOffset, sizeof(sOffset));
	GetCmdArg(2, sAmount, sizeof(sAmount));

	iOffset = StringToInt(sOffset);
	iAmount = StringToInt(sAmount);

	SetEntData(Client, iOffset, iAmount, 4);
	return Plugin_Handled;
}

public Action:Command_FindDataInt(Client, args)
{
	new String:sArg1[32];
	decl iArg1, tmp;
	GetCmdArg(1, sArg1, sizeof(sArg1));
	iArg1 = StringToInt(sArg1);

	PrintToConsole(Client, "Client Offsets Found:");

	for (new x = 4; x < 10000; x+=4)
	{
		tmp = GetEntData(Client, x, 4);
		if (tmp == iArg1)
		{
			PrintToConsole(Client, "Offset: %i, Data: %i", x, tmp);
		}
	}
	PrintToConsole(Client, "PlayerResource Offsets Found:");
	for (new x = 4; x < 10000; x+=4)
	{
		tmp = GetEntData(g_PlayerResource, x, 4);
		if (tmp == iArg1)
		{
			PrintToConsole(Client, "Offset: %i, Data: %i", x, tmp);
		}
	}
	return Plugin_Handled;
}

public Action:Command_FindDataFloat(Client, args)
{
	new String:sArg1[32], String:sArg2[32];
	decl Float:fArg1, Float:fArg2, Float:tmp;
	GetCmdArg(1, sArg1, sizeof(sArg1));
	GetCmdArg(2, sArg2, sizeof(sArg2));
	fArg1 = StringToFloat(sArg1);
	fArg2 = StringToFloat(sArg2);
	PrintToConsole(Client, "Client Offsets Found:");
	
	for (new x = 4; x < 10000; x+=4)
	{
		tmp = GetEntDataFloat(Client, x);
		
		if(args == 2)
		{
			if (tmp >= fArg1 && tmp <= fArg2)
			{
				PrintToConsole(Client, "Offset: %i, Data: %f", x, tmp);
			}
		}
		else
		{
			if (tmp == fArg1)
			{
				PrintToConsole(Client, "Offset: %i, Data: %f", x, tmp);
			}
		}
	}

	PrintToConsole(Client, "PlayerResource Offsets Found:");
	for (new x = 4; x < 10000; x+=4)
	{
		tmp = GetEntDataFloat(g_PlayerResource, x);
		if(args == 2)
		{
			if (tmp >= fArg1 && tmp <= fArg2)
			{
				PrintToConsole(Client, "Offset: %i, Data: %f", x, tmp);
			}
		}
		else
		{
			if (tmp == fArg1)
			{
				PrintToConsole(Client, "Offset: %i, Data: %f", x, tmp);
			}
		}
	}
	return Plugin_Handled;
}

public Action:Command_PropFloat(Client, args)
{
	new String:sHandle[32], String:sAmount[32];
	
	if(args < 2)
	{
		if(args < 1)
		{
			PrintToConsole(Client, "[SM]  Incorrect Usage.");
			return Plugin_Handled;
		}
		else
		{
			decl Float:tmp;
			GetCmdArg(1, sHandle, sizeof(sHandle));
			tmp = GetEntPropFloat(Client, Prop_Data, sHandle);
			PrintToConsole(Client, "Property: %s, Data: %f", sHandle, tmp);
			return Plugin_Handled;
		}
	}
	
	decl Float:iAmount;
	
	GetCmdArg(1, sHandle, sizeof(sHandle));
	GetCmdArg(2, sAmount, sizeof(sAmount));

	iAmount = StringToFloat(sAmount);

	SetEntPropFloat(Client, Prop_Data, sHandle, iAmount);
	return Plugin_Handled;
}

public Action:Command_DataFloat(Client, args)
{
	new String:sOffset[32], String:sAmount[32];
	decl Float:fAmount, iOffset;
	
	if(args < 2)
	{
		if(args < 1)
		{
			PrintToConsole(Client, "[SM]  Incorrect Usage.");
			return Plugin_Handled;
		}
		else
		{
			decl Float:tmp;
			GetCmdArg(1, sOffset, sizeof(sOffset));
			iOffset = StringToInt(sOffset);
			tmp = GetEntDataFloat(Client, iOffset);
			PrintToConsole(Client, "Offset: %i, Data: %f", iOffset, tmp);
			return Plugin_Handled;
		}
	}
	
	GetCmdArg(1, sOffset, sizeof(sOffset));
	GetCmdArg(2, sAmount, sizeof(sAmount));

	iOffset = StringToInt(sOffset);
	fAmount = StringToFloat(sAmount);

	SetEntDataFloat(Client, iOffset, fAmount);
	return Plugin_Handled;
}

public Action:Command_PropVector(Client, args)
{
	new String:sHandle[32], String:sVector[32][3];
	if(args < 2)
	{
		if(args < 1)
		{
			PrintToConsole(Client, "[SM]  Incorrect Usage.");
			return Plugin_Handled;
		}
		else
		{
			decl Float:tmp[3];
			GetCmdArg(1, sHandle, sizeof(sHandle));
			GetEntPropVector(Client, Prop_Data, sHandle, tmp);
			PrintToConsole(Client, "Property: %s, Data: Vector[0]:[%f] | Vector[1]:[%f] | Vector[2]:[%f]", sHandle, tmp[0], tmp[1], tmp[2]);
			return Plugin_Handled;
		}
	}

	new Float:vec[3];

	GetCmdArg(1, sHandle, sizeof(sHandle));
	GetCmdArg(2, sVector[0], sizeof(sVector));
	GetCmdArg(3, sVector[1], sizeof(sVector));
	GetCmdArg(4, sVector[2], sizeof(sVector));

	for(new x = 0; x <= 2; x++)
	{
		vec[x] = StringToFloat(sVector[x]);
	}
	
	SetEntPropVector(Client, Prop_Data, sHandle, vec);
	return Plugin_Handled;
}

/*
		TE_Start("Energy Splash");
		TE_WriteVector("m_vecPos", Position);
		TE_WriteVector("m_vecDir", Float:{0.0,0.0,0.0});
		TE_WriteNum("m_bExplosive", 1);
		TE_SendToAll(0.0);
*/

FindResourceEntity()
{
	new i, String:ClassName[64];
	
	for(i = MaxClients; i <= GetMaxEntities(); i++){
	 	if(IsValidEntity(i))
		{
			GetEntityNetClass(i, ClassName, 64);
			if(StrEqual(ClassName, "CPlayerResource"))
			{
				return i;
			}
		}
	}
	
	return 0;
}