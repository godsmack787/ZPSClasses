new Handle:hDropWeapon = INVALID_HANDLE;
new Handle:hRemoveWeight = INVALID_HANDLE;
new Handle:hSwitchWeapon = INVALID_HANDLE;
new Handle:hDamageEffect = INVALID_HANDLE;
new Handle:hPickupItem = INVALID_HANDLE;
new Handle:hGiveAmmo = INVALID_HANDLE;
new Handle:hScootInventory = INVALID_HANDLE;

new Handle:g_hInfectedChance = INVALID_HANDLE;
//new Handle:g_hInfectedTurntime = INVALID_HANDLE;

new Handle:g_hHandsCenterForce = INVALID_HANDLE;
new Handle:g_hHandsOffsetForce = INVALID_HANDLE;

new Handle:g_hArmsCenterForce = INVALID_HANDLE;
new Handle:g_hArmsOffsetForce = INVALID_HANDLE;

new Handle:g_hCarrierArmsCenterForce = INVALID_HANDLE;
new Handle:g_hCarrierArmsOffsetForce = INVALID_HANDLE;

new Handle:g_hPassword = INVALID_HANDLE;
new Handle:g_hCheats = INVALID_HANDLE;
new Handle:g_hTestMode = INVALID_HANDLE;
new Handle:g_hFriendlyFire = INVALID_HANDLE;

stock g_PlayerResource;
stock g_InfectionTimeOffset;

new UserMsg:g_FadeUserMsgId;

SetupEventHooks()
{
	HookEvent("game_round_restart", RoundRestart);
	HookEvent("player_death", PlayerDeath);
	HookEvent("player_death", PrePlayerDeath, EventHookMode_Pre);
	HookEvent("player_spawn",PlayerSpawn);
	HookEvent("player_hurt", PlayerHurt);
	HookEvent("break_prop", BreakProp, EventHookMode_Pre);
}

SetupHandles()
{
	g_hActiveWeapon = FindSendPropOffs("CAI_BaseNPC", "m_hActiveWeapon");
	g_hTestMode = FindConVar("sv_testmode");
	g_hCheats = FindConVar("sv_cheats");
	g_hPassword = FindConVar("sv_password");
	g_hFriendlyFire = FindConVar("mp_friendlyfire");
	g_hInfectedChance = FindConVar("infected_chance");
	//g_hInfectedTurntime = FindConVar("infected_turntime");
	g_hHandsCenterForce = FindConVar("hands_centerforce");
	g_hHandsOffsetForce = FindConVar("hands_offsetforce");
	g_hArmsCenterForce = FindConVar("arms_centerforce");
	g_hArmsOffsetForce = FindConVar("arms_offsetforce");
	g_hCarrierArmsCenterForce = FindConVar("carrierarms_centerforce");
	g_hCarrierArmsOffsetForce = FindConVar("carrierarms_offsetforce");
	g_FadeUserMsgId = GetUserMessageId("Fade");
}

RegisterCommands()
{
	RegConsoleCmd("sm_skill1", Command_ClassSkill1);
	RegConsoleCmd("sm_skill2", Command_ClassSkill2);
	RegConsoleCmd("sm_class", Command_ClassMenu);
	RegConsoleCmd("sm_list", Command_ClassList);
	RegConsoleCmd("sm_stuck", Command_Stuck);

	RegAdminCmd("sm_class_remove", Command_ClassRemove, ADMFLAG_CUSTOM6);
}

InitializePlugin()
{
	new Handle:hGameConf = INVALID_HANDLE;
	hGameConf = LoadGameConfigFile("sdktools.games.ep2");

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Virtual, "Weapon_Drop");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer, VDECODE_FLAG_ALLOWNULL);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer, VDECODE_FLAG_ALLOWNULL);
	hDropWeapon = EndPrepSDKCall();
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Virtual, "RemoveWeight");
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	hRemoveWeight = EndPrepSDKCall();
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Virtual, "DamageEffect");
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	hDamageEffect = EndPrepSDKCall();
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Virtual, "Weapon_Switch");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	hSwitchWeapon = EndPrepSDKCall();
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Virtual, "PlayerWeaponPickup");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	hPickupItem = EndPrepSDKCall();
	
	// Arg1: Amount Arg2: Weapon Arg3: PlaySound 
	// Weapon #s: 1: Pistol, 2: Magnum, 3: Shotgun, 4:Rifle
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Virtual, "GiveAmmo");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	hGiveAmmo = EndPrepSDKCall();
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Virtual, "ScootInventory");
	hScootInventory = EndPrepSDKCall();
	
	CloseHandle(hGameConf);
	
	SetConVarFlags(g_hInfectedChance, (GetConVarFlags(g_hInfectedChance) & ~(FCVAR_CHEAT)));
	//SetConVarFlags(g_hInfectedTurntime, (GetConVarFlags(g_hInfectedTurntime) & ~(FCVAR_CHEAT)));

	SetConVarFlags(g_hHandsCenterForce, (GetConVarFlags(g_hHandsCenterForce) & ~(FCVAR_CHEAT)));
	SetConVarFlags(g_hHandsOffsetForce, (GetConVarFlags(g_hHandsOffsetForce) & ~(FCVAR_CHEAT)));
	
	SetConVarFlags(g_hArmsCenterForce, (GetConVarFlags(g_hArmsCenterForce) & ~(FCVAR_CHEAT)));
	SetConVarFlags(g_hArmsOffsetForce, (GetConVarFlags(g_hArmsOffsetForce) & ~(FCVAR_CHEAT)));
	
	SetConVarFlags(g_hCarrierArmsCenterForce, (GetConVarFlags(g_hCarrierArmsCenterForce) & ~(FCVAR_CHEAT)));
	SetConVarFlags(g_hCarrierArmsOffsetForce, (GetConVarFlags(g_hCarrierArmsOffsetForce) & ~(FCVAR_CHEAT)));

	SetConVarFlags(g_hCheats, (GetConVarFlags(g_hCheats) & ~(FCVAR_NOTIFY)));
	
//	SetConVarBounds(g_hInfectedTurntime, ConVarBound_Lower, true, 0.0);
	
	new String:tmp[64];
	GetConVarString(g_hPassword, tmp, sizeof(tmp));
	
	switch (strcmp(tmp, "rawr", false))
	{
		case COMPARE_MATCH:
		{
			g_InfectionTimeOffset = 4976; // Windows
		}
		default:
		{
			g_InfectionTimeOffset = 5052; // Linux
		}
	}
}

PrecacheFiles()
{
	AddFolderToDownloadTable("materials/models/weapons/w_slam");
	AddFolderToDownloadTable("materials/models/weapons/v_slam");
	AddFolderToDownloadTable("models/humans/custom");
	AddFolderToDownloadTable("models/humans/custom_c");
	AddFolderToDownloadTable("models/custom");
	AddFolderToDownloadTable("materials/models/humans/male/custom");
	AddFolderToDownloadTable("materials/models/humans/male/custom_c");
	AddFolderToDownloadTable("materials/models/humans/male/custom_c/demo");
	AddFolderToDownloadTable("materials/models/custom");
	AddFolderToDownloadTable("materials/models/custom/carrier");
	
	AddFileToDownloadsTable("models/weapons/w_slam.phy");
	AddFileToDownloadsTable("models/weapons/w_slam.sw.vtx");
	AddFileToDownloadsTable("models/weapons/w_slam.dx80.vtx");
	AddFileToDownloadsTable("models/weapons/w_slam.dx90.vtx");
	AddFileToDownloadsTable("models/weapons/w_slam.mdl");
	AddFileToDownloadsTable("models/weapons/w_slam.vvd");
	
	PrecacheModel(MDL_IKARBOMB, true);
	PrecacheModel(MDL_ACIDBOMB, true);
	PrecacheModel(MDL_MINE, true);
	PrecacheModel(MDL_LASER, true);
	PrecacheModel(PROP_WOODEN_BOX_MODEL, true);
	PrecacheModel(PROP_DOUBLE_WOODEN_BOX_MODEL, true);
	PrecacheModel(PROP_WOODEN_PALLET_MODEL, true);
	
	PrecacheModel(MDL_SCIENTIST, true);
	PrecacheModel(MDL_DEMOLITIONIST, true);

	PrecacheModel("models/humans/group03/male_01.mdl", true);
	PrecacheModel("models/humans/group03/male_03.mdl", true);
	PrecacheModel("models/humans/group03/male_05.mdl", true);
	PrecacheModel("models/humans/group03/male_06.mdl", true);
	PrecacheModel("models/humans/group03/male_07.mdl", true);
	PrecacheModel("models/humans/group03/male_08.mdl", true);
	PrecacheModel("models/humans/group03/male_09.mdl", true);

	PrecacheModel("models/humans/group03m/male_01.mdl", true);
	PrecacheModel("models/humans/group03m/male_03.mdl", true);
	PrecacheModel("models/humans/group03m/male_05.mdl", true);
	PrecacheModel("models/humans/group03m/male_06.mdl", true);
	PrecacheModel("models/humans/group03m/male_07.mdl", true);
	PrecacheModel("models/humans/group03m/male_08.mdl", true);
	PrecacheModel("models/humans/group03m/male_09.mdl", true);
	
	PrecacheModel("models/humans/custom/male_01.mdl", true);
	PrecacheModel("models/humans/custom/male_02.mdl", true);
	PrecacheModel("models/humans/custom/male_03.mdl", true);
	PrecacheModel("models/humans/custom/male_04.mdl", true);
	PrecacheModel("models/humans/custom/male_05.mdl", true);
	PrecacheModel("models/humans/custom/male_06.mdl", true);
	
	PrecacheModel("models/custom/carrier.mdl", true);
	PrecacheModel("models/custom/normal1.mdl", true);
	PrecacheModel("models/custom/normal2.mdl", true);
	PrecacheModel("models/custom/normal3.mdl", true);
	PrecacheModel("models/custom/normal4.mdl", true);
	PrecacheModel("models/custom/normal5.mdl", true);
	
	PrecacheSound(SND_MINE, true);	
	PrecacheSound(SND_ARMOR1, true);
	PrecacheSound(SND_ARMOR2, true);
	PrecacheSound(SND_MEDIC_OKAY, true);
	PrecacheSound(SND_MEDIC_HELP, true);
	PrecacheSound(SND_HULKER_GROAN, true);
	PrecacheSound(SND_SHIFTER_GROAN, true);
	PrecacheSound(SND_SHIFTER_SHADOWS, true);
	PrecacheSound(SND_LEAPER_GROAN, true);
	PrecacheSound(SND_LEAPER_PUNCTURE, true);
	PrecacheSound(SND_DEMOLITIONIST_COMEON, true);
	PrecacheSound(SND_DEMOLITIONIST_BREAK, true);
	PrecacheSound(SND_CONSTRUCTOR, true);
	PrecacheSound(SND_SHARPSHOOTER, true);
	PrecacheSound(SND_BIOCHEMIST, true);
	
	/*
	PrecacheSound("Humans/HM_Water/HM_AirRough-01.wav", true);
	PrecacheSound("Humans/HM_Water/HM_AirRough-02.wav", true);
	PrecacheSound("Humans/HM_Water/HM_AirRough-03.wav", true);
	PrecacheSound("Humans/HM_Water/HM_AirRough-04.wav", true);
	
	PrecacheSound("Humans/HumanMale-01/Jump/jump-01.wav", true);
	PrecacheSound("Humans/HumanMale-01/Jump/jump-02.wav", true);
	PrecacheSound("Humans/HumanMale-01/Jump/jump-03.wav", true);
	PrecacheSound("Humans/HumanMale-01/Jump/jump-04.wav", true);
	PrecacheSound("Humans/HumanMale-01/Jump/jump-05.wav", true);
	PrecacheSound("Humans/HumanMale-01/Jump/jump-06.wav", true);
	*/
	
	PrecacheSound("npc/ichthyosaur/attack_growl1.wav", true);
	PrecacheSound("npc/ichthyosaur/attack_growl2.wav", true);
	PrecacheSound("npc/ichthyosaur/attack_growl3.wav", true);
	PrecacheSound("npc/antlion_guard/angry1.wav", true);
	PrecacheSound("npc/antlion_guard/angry2.wav", true);
	PrecacheSound("npc/antlion_guard/angry3.wav", true);
	PrecacheSound("weapons/underwater_explode4.wav", true);
	PrecacheSound("weapons/underwater_explode3.wav", true);
	
	g_Sprite1 = PrecacheModel("materials/sprites/blueflare1.vmt");
	g_Sprite2 = PrecacheModel("materials/sprites/smoke.vmt");
	g_Sprite3 = PrecacheModel("materials/effects/slime1.vmt");
	g_Sprite4 = PrecacheModel("materials/sprites/greenglow1.vmt");
	g_Sprite5 = PrecacheModel("materials/sprites/lgtning.vmt");
	//g_Sprite6 = PrecacheModel(" ");
	//g_Sprite7 = PrecacheModel(" ");
	//g_Sprite8 = PrecacheModel(" ");
	//g_Sprite9 = PrecacheModel(" ");
}

public bool:FilterAll(Target, cMask)
{
	return false;
}

public bool:FilterProp(Target, cMask)
{
	return true;
}

public bool:FilterNonPlayer(Target, cMask, any:Entity)
{
	if (Target == Entity)
	{
		return true;
	}

	return false;
}

public bool:FilterSelf(Target, cMask, any:Entity)
{
	if (Target == Entity)
	{
		return false;
	}
	
	return true;
}

public BlankMenuHandler(Handle:menu, MenuAction:action, Client, SelectedOption)
{
	
}