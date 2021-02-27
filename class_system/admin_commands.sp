public Action:Command_ClassRemove(Client, Args)
{
	if (Args < 1)
	{
		ReplyToCommand(Client, "[SM] Usage: sm_class_remove <name or #userid>");
		return Plugin_Handled;	
	}	

	decl String:Arg1[64], Target;
	
	GetCmdArg(1, Arg1, sizeof(Arg1));
	Target = FindTarget(Client, Arg1);
	
	if (Target != -1)
	{
		decl cTeam;
		cTeam = GetClientTeam(Target);
		
		ClearPlayerData(Target, false);
		SetPlayerDefaults(Target, cTeam);
		
		new String:tName[32], String:cName[32];
		GetClientName(Client, String:cName, sizeof(cName));
		GetClientName(Target, String:tName, sizeof(tName));
		PrintToChat(Client, "[SM] You have removed %s's class.", tName);
		PrintToChat(Target, "[SM] %s has removed your class.", cName);
	}
	else
	{
		PrintToChat(Client, "[SM] Player not found.");
	}
	return Plugin_Handled;
}