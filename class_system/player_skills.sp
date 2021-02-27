UseHumanSkill(Client, Skill)
{
	decl Float:fSkill1Time, Float:fSkill2Time, Float:cGameTime;
	fSkill1Time = pDataFloat[FLOAT_SKILL_1_TIME][ROUND][Client];
	fSkill2Time = pDataFloat[FLOAT_SKILL_2_TIME][ROUND][Client];
	
	cGameTime = GetGameTime();
	
	switch (pDataInt[CLASS][ROUND][Client])
	{
		case MEDIC:
		{
			switch (Skill)
			{
				case SKILL_1:
				{
					decl kEntity;

					kEntity = GetClientAimTarget(Client, false);
					
					if (CompareEntityClass(kEntity, "item_healthkit"))
					{
						if (CheckDistance(Client, kEntity, 120))
						{
							decl iSkill1Data_1;
							iSkill1Data_1 = pDataInt[SKILL1DATA_1][ROUND][Client];
							
							if ((iSkill1Data_1 + 1) <= MEDIC_MAX_MEDKITS)
							{
								if (IsValidEntity(kEntity))
								{
									pDataInt[SKILL1DATA_1][ROUND][Client]++;
									AcceptEntityInput(kEntity, "kill");
									PrintToChat(Client, "You picked up a Medkit. You have %i left.", (iSkill1Data_1 + 1));
								}
							}
							else
							{
								PrintToChat(Client, "You can't pick up any more Medkits.");
							}
						}
						else
						{
							PrintToChat(Client, "You are too far away to pick that up.");
						}
					}
					else if (CompareEntityClass(kEntity, "item_healthvial"))
					{
						if (CheckDistance(Client, kEntity, 120))
						{
							decl iSkill1Data_2;
							iSkill1Data_2 = pDataInt[SKILL1DATA_2][ROUND][Client];
							
							if ((iSkill1Data_2 + 1) <= MEDIC_MAX_PAINKILLERS)
							{
								if (IsValidEntity(kEntity))
								{
									AcceptEntityInput(kEntity, "kill");
									pDataInt[SKILL1DATA_2][ROUND][Client]++;
									PrintToChat(Client, "You picked up Painkillers. %i left.", (iSkill1Data_2 + 1));
								}
							}
							else
							{
								PrintToChat(Client, "You can't pick up any more Painkillers.");
							}							
						}
						else
						{
							PrintToChat(Client, "You are too far away to pick that up.");
						}
					}
					else
					{
						if (fSkill1Time <= (cGameTime - 1.5) || fSkill1Time == 0.0)
						{		
							new Handle:hMedicalMenu = CreateMenu(MedicCategoryHandler);
							decl String:Temp[64], iSkill1Data, iSkill2Data;
							
							decl iSkill1Data_1, iSkill1Data_2;
							iSkill1Data_1 = pDataInt[SKILL1DATA_1][ROUND][Client];
							iSkill1Data_2 = pDataInt[SKILL1DATA_2][ROUND][Client];
							
							SetMenuTitle(hMedicalMenu, "+ Medical Supplies");
							
							if (iSkill1Data_1 > NONE)
							{
								Format(Temp, sizeof(Temp), "Medkit (%i Left)",  iSkill1Data_1);
								AddMenuItem(hMedicalMenu, "0", Temp);
							}
							else
							{
								AddMenuItem(hMedicalMenu, "0", "Medkit (OUT)", ITEMDRAW_DISABLED);
							}
	
							if (iSkill1Data_2 > NONE)
							{
								Format(Temp, sizeof(Temp), "Painkillers (%i Left)",  iSkill1Data_2);
								AddMenuItem(hMedicalMenu, "1", Temp);
							}
							else
							{
								AddMenuItem(hMedicalMenu, "1", "Painkillers (OUT)", ITEMDRAW_DISABLED);
							}

							AddMenuItem(hMedicalMenu, "2", "Bandage Target");
							AddMenuItem(hMedicalMenu, "3", "Bandage Yourself");
							
							AddMenuItem(hMedicalMenu, "-1", "None");

							SetMenuExitButton(hMedicalMenu, true);
							DisplayMenu(hMedicalMenu, Client, 50);
						}
						else
						{
							decl Float:tRemain;
							tRemain = (2.5 - (cGameTime - fSkill1Time));
							PrintToChat(Client, "You can access your medical supplies in %s second(s).", ConvertFloatToText(tRemain));
						}
					}
				}
				
				case SKILL_2:
				{
					PrintToChat(Client, "This class has no secondary skill.");
				}
			}
		}

		case DEMOLITIONIST:
		{
			switch (Skill)
			{
				case SKILL_1:
				{
					if (fSkill1Time <= (cGameTime - 3.0) || fSkill1Time == 0.0)
					{
						OpenMineMenu(Client);
					}
					else
					{
						decl Float:tRemain;
						tRemain = (4.0 - (cGameTime - fSkill1Time));
						PrintToChat(Client, "You can set another mine in %s second(s).", ConvertFloatToText(tRemain));
					}
				}
				case SKILL_2:
				{
					PrintToChat(Client, "This class has no secondary skill.");
				}
			}
		}

		case CONSTRUCTOR:
		{
			switch (Skill)
			{
				case SKILL_1:
				{
					if (fSkill1Time <= (cGameTime - 3.0) || fSkill1Time == 0.0)
					{
						OpenPropMenu(Client);
					}
					else
					{
						decl Float:tRemain;
						tRemain = (4.0 - (cGameTime - fSkill1Time));
						PrintToChat(Client, "You can create an object in %s second(s).", ConvertFloatToText(tRemain));
					}
				}
				
				case SKILL_2:
				{
					if (pDataBool[IS_HOLDING_OBJECT][ROUND][Client] == true)
					{
						pDataBool[IS_HOLDING_OBJECT][ROUND][Client] = false;
					}
					else
					{
						decl Entity;
						Entity = GetClientAimTarget(Client, false);
											
						if (Entity)
						{
							decl cPropOwner, cPropEntity;
							
							for (new i = NONE; i < MAX_PROPS ; i++)
							{
								cPropOwner = pPlayerProps[i][PROP_OWNER];
								cPropEntity = pPlayerProps[i][PROP_ENTITY];
							
								if (cPropOwner == Client && cPropEntity == Entity)
								{
									if (CheckDistance(Client, Entity, 100))
									{
										if (!IsEntityHeld(Entity))
										{
											pDataInt[SKILL2DATA_1][ROUND][Client] = Entity;
											pDataBool[IS_HOLDING_OBJECT][ROUND][Client] = true;
											SetSpeed(Client, 0.75, 0.0);
											AcceptEntityInput(Entity, "DisableMotion");
											AddHeldEntity(Entity);
											pDataHandle[TIMER_HOLDING_OBJECT][ROUND][Client] = CreateTimer(0.1, ObjectHoldTimer, Client, TIMER_REPEAT);
										}
										else
										{
											PrintToChat(Client, "You can't hold that right now.");
										}
									}
									else
									{
										PrintToChat(Client, "That is too far away.");
									}
									break;
								}
							}
						}
					}
				}
			}
		}
		case SHARPSHOOTER:
		{
			switch (Skill)
			{
				case SKILL_1:
				{
					PrintToChat(Client, "This class has no primary skill.");
				}
				case SKILL_2:
				{
					if (!pDataBool[SKILL2BOOL_1][ROUND][Client])
					{
						SetEntProp(Client, Prop_Data, "m_iFOV", 20);
						SetSpeed(Client, 0.60, 0.0);
						pDataBool[SKILL2BOOL_1][ROUND][Client] = true;
					}
					else
					{
						SetEntProp(Client, Prop_Data, "m_iFOV", 100);
						SetSpeed(Client, 1.0, 0.0);
						pDataBool[SKILL2BOOL_1][ROUND][Client] = false;
					}
				}
			}
		}
		case BIOCHEMIST:
		{
			switch (Skill)
			{
				case SKILL_1:
				{
					if (CompareEntityClass(GetEntDataEnt2(Client, g_hActiveWeapon), "weapon_emptyhand"))
					{
						if (fSkill1Time <= (cGameTime - 2.7) || fSkill1Time == 0.0)
						{
							decl iSkill1Data_1;
							iSkill1Data_1 = pDataInt[SKILL1DATA_1][ROUND][Client];
							
							if (iSkill1Data_1 > NONE)
							{
								decl Float:Position[3], Float:Angles[3], Float:Velocity[3], Entity, String:Temp[64];
								
								GetClientEyePosition(Client, Position);
								GetClientEyeAngles(Client, Angles);
								GetAngleVectors(Angles, Velocity, NULL_VECTOR, NULL_VECTOR);
								NormalizeVector(Velocity, Velocity);
								
								for (new x = 0; x < 3; x++)
								{
									Velocity[x]=Velocity[x]*700;
								}
								
								Entity = SpawnSkillItem(Client, "prop_physics", MDL_ACIDBOMB, Position, Angles, Velocity, "255 255 255");
								
								Format(Temp, sizeof(Temp), "Humans/HumanMale-01/Jump/jump-0%i.wav", GetRandomInt(1, 6));
								PlaySoundToAll(Temp, Entity, 0.7, 100);
								
								TE_SetupBeamFollow(Entity, g_Sprite4, g_Sprite4, 1.0, 10.0, 10.0, 5, BOMB_GREEN);
								TE_SendToAll();
								
								SetEntProp(Entity, Prop_Data, "m_takedamage", 2);
								
								IntToString(ACID_BOMB, Temp, sizeof(Temp));
								DispatchKeyValue(Entity, "targetname", Temp);
								
								pDataInt[SKILL1DATA_1][ROUND][Client]--;
								pDataFloat[FLOAT_SKILL_1_TIME][ROUND][Client] = cGameTime;
								PrintToChat(Client, "You have %i acidbomb(s) left.", iSkill1Data_1);
							}
							else
							{
								PrintToChat(Client, "You are out of acidbombs.");
							}
						}
						else
						{
							decl Float:tRemain;
							tRemain = (3.7 - (cGameTime - fSkill1Time));
							PrintToChat(Client, "You can throw an acidbomb in %s second(s).", ConvertFloatToText(tRemain));
						}
					}
					else
					{
						PrintToChat(Client, "You need to holster your weapon first.");
					}
				}
				case SKILL_2:
				{
					if (CompareEntityClass(GetEntDataEnt2(Client, g_hActiveWeapon), "weapon_emptyhand"))
					{
						if (fSkill2Time <= (cGameTime - 3.0) || fSkill2Time == 0.0)
						{
							decl iSkill2Data_1;
							iSkill2Data_1 = pDataInt[SKILL2DATA_1][ROUND][Client];
							
							if (iSkill2Data_1 > NONE)
							{
								decl Float:Position[3], Float:Angles[3], Float:Velocity[3], Entity, String:Temp[64];
								
								GetClientEyePosition(Client, Position);
								GetClientEyeAngles(Client, Angles);
								GetAngleVectors(Angles, Velocity, NULL_VECTOR, NULL_VECTOR);
								NormalizeVector(Velocity, Velocity);
								
								for (new x = 0; x < 3; x++)
								{
									Velocity[x]=Velocity[x]*450;
								}
								
								Entity = SpawnSkillItem(Client, "prop_physics", MDL_IKARBOMB, Position, Angles, Velocity, "255 255 255");
								
								Format(Temp, sizeof(Temp), "Humans/HumanMale-01/Jump/jump-0%i.wav", GetRandomInt(1, 6));
								PlaySoundToAll(Temp, Entity, 0.8, 100);
								
								TE_SetupBeamFollow(Entity, g_Sprite5, g_Sprite5, 1.0, 5.0, 5.0, 5, BOMB_WHITE);
								TE_SendToAll();
								
								SetEntProp(Entity, Prop_Data, "m_takedamage", 2);
								
								IntToString(IKAR_BOMB, Temp, sizeof(Temp));
								DispatchKeyValue(Entity, "targetname", Temp);

								pDataInt[SKILL2DATA_1][ROUND][Client]--;
								PrintToChat(Client, "You have %i ikarbomb(s) left.", (iSkill2Data_1 - 1));
								pDataFloat[FLOAT_SKILL_2_TIME][ROUND][Client] = cGameTime;
							}
							else
							{
								PrintToChat(Client, "You are out of ikarbombs.");
							}
						}
						else
						{
							decl Float:tRemain;
							tRemain = (4.0 - (cGameTime - fSkill2Time));
							PrintToChat(Client, "You can throw a ikarbomb in %s second(s).", ConvertFloatToText(tRemain));
						}
					}
					else
					{
						PrintToChat(Client, "You need to holster your weapon first.");
					}
				}
			}
		}
		default:
		{
			switch (Skill)
			{
				case SKILL_1:
				{
					PrintToChat(Client, "This class has no primary skill.");
				}
				case SKILL_2:
				{
					PrintToChat(Client, "This class has no secondary skill.");
				}
			}
		}
	}
}

OpenMineMenu(Client)
{
	new Handle:hMineMenu = CreateMenu(MineCategoryHandler);
	decl String:Temp[64], iSkill1Data_1, iSkill1Data_2, iSkill1Data_3;
	iSkill1Data_1 = pDataInt[SKILL1DATA_1][ROUND][Client];
	iSkill1Data_2 = pDataInt[SKILL1DATA_2][ROUND][Client];
	iSkill1Data_3 = pDataInt[SKILL1DATA_3][ROUND][Client];	
	
	SetMenuTitle(hMineMenu, "+ Explosives");
							
	if (iSkill1Data_1 > NONE)
	{
		Format(Temp, sizeof(Temp), "Tripmine (%i Left)",  iSkill1Data_1);
		AddMenuItem(hMineMenu, "0", Temp);
	}
	else
	{
		AddMenuItem(hMineMenu, "0", "Tripmine (OUT)", ITEMDRAW_DISABLED);
	}

	if (iSkill1Data_3 > NONE)
	{
		Format(Temp, sizeof(Temp), "Proxmine (%i Left)", iSkill1Data_3);
		AddMenuItem(hMineMenu, "2", Temp);
	}
	else
	{
		AddMenuItem(hMineMenu, "2", "Proxmine (OUT)", ITEMDRAW_DISABLED);
	}
								
	AddMenuItem(hMineMenu, "-1", "None");

	SetMenuExitButton(hMineMenu, true);
	DisplayMenu(hMineMenu, Client, 50);
}

OpenPropMenu(Client)
{
	new Handle:hPropMenu = CreateMenu(PropCategoryHandler);
	new Float:cfWeight = pDataFloat[FLOAT_SKILL_1_DATA][ROUND][Client];
	new String:Temp[64];
	
	Format(Temp, sizeof(Temp), "+ Salvage Object (%.2f/%.2f used)", cfWeight, pDataFloat[FLOAT_SKILL_1_DATA_2][ROUND][Client]);
	SetMenuTitle(hPropMenu, Temp);

	AddMenuItem(hPropMenu, "0", "Wooden Box (0.75 WT)");
	AddMenuItem(hPropMenu, "1", "Double Wooden Box (1.00 WT)");
	//AddMenuItem(hPropMenu, "2", "Wooden Pallet (0.40 WT)");
	
	//AddMenuItem(hPropMenu, "98", "Destroy Last");
	//AddMenuItem(hPropMenu, "99", "Destroy All");
	AddMenuItem(hPropMenu, "-1", "None");

	SetMenuExitButton(hPropMenu, true);
	DisplayMenu(hPropMenu, Client, 50);
}

public MineCategoryHandler(Handle:hMineMenu, MenuAction:action, Client, SelectedOption)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			switch (IsPlayerAlive(Client))
			{
				case true:
				{
					decl String:Temp[8];
					decl pMineSelected;
					GetMenuItem(hMineMenu, SelectedOption, Temp, sizeof(Temp));
					pMineSelected = StringToInt(Temp);

					if (pMineSelected != -1)
					{
						switch (pMineSelected)
						{
							case MINE_TRIP:
							{
								if (MineChecks(Client))
								{
									if (pDataInt[SKILL1DATA_1][ROUND][Client] > 0)
									{
										SetMine(Client, MINE_TRIP);
									}
								}
							}
							case MINE_PROXIMITY:
							{
								if (MineChecks(Client))
								{
									if (pDataInt[SKILL1DATA_3][ROUND][Client] > 0)
									{
										SetMine(Client, MINE_PROXIMITY);
									}
								}	
							}
						}
					}
				}
			}
		}
		case MenuAction_End:
		{
			CloseHandle(hMineMenu);
		}
	}
}

public MedicCategoryHandler(Handle:hMedicalMenu, MenuAction:action, Client, SelectedOption)
{

	switch (action)
	{
		case MenuAction_Select:
		{
			switch (IsPlayerAlive(Client))
			{
				case true:
				{
					decl String:Temp[8];
					decl pMedicalSelected;
					GetMenuItem(hMedicalMenu, SelectedOption, Temp, sizeof(Temp));
					pMedicalSelected = StringToInt(Temp);

					if (pMedicalSelected != -1)
					{
						decl Float:Position[3], Float:Angles[3], Float:Velocity[3];
			
						GetClientEyePosition(Client, Position);
						GetClientEyeAngles(Client, Angles);
						GetAngleVectors(Angles, Velocity, NULL_VECTOR, NULL_VECTOR);
						NormalizeVector(Velocity, Velocity);
						
						pDataFloat[FLOAT_SKILL_1_TIME][ROUND][Client] = GetGameTime();		
						
						for (new x = 0; x < 3; x++)
						{
							Velocity[x]=Velocity[x]*140;
						}
						
						switch (pMedicalSelected)
						{
							case 0:
							{				
								SpawnSkillItem(Client, "item_healthkit", "", Position, Angles, Velocity, "255 255 255");
								
								pDataInt[SKILL1DATA_1][ROUND][Client]--;
							}
							case 1:
							{
								SpawnSkillItem(Client, "item_healthvial", "", Position, Angles, Velocity, "255 255 255");
								
								pDataInt[SKILL1DATA_2][ROUND][Client]--;
							}
							case 2:
							{
								decl Target;
								Target = GetClientAimTarget(Client, true);
								
								if (IsPlayer(Target) && GetClientTeam(Target) == HUMAN && CheckSightPath(Client, Target))
								{
									if (CheckDistance(Client, Target, 85))
									{
										if (!pDataBool[IS_BANDAGED][ROUND][Target])
										{
											PlaySoundToAll("Items/HealthPack/LgHealthPack.wav", Target, 0.50, 105);
											SDKCall(hDamageEffect, Target, 0.0, 1);
											pDataBool[IS_BANDAGED][ROUND][Target] = true;
										}
										else
										{
											PrintToChat(Client, "They are already bandaged.");
										}	
									}
									else
									{
										PrintToChat(Client, "Your target is too far away.");
									}
								}
								else
								{
									PrintToChat(Client, "You have no target to bandage.");
								}
							}
							case 3:
							{
								if (!pDataBool[IS_BANDAGED][ROUND][Client])
								{
									PlaySoundToAll("Items/HealthPack/LgHealthPack.wav", Client, 0.50, 105);
									SDKCall(hDamageEffect, Client, 0.0, 1);
									pDataBool[IS_BANDAGED][ROUND][Client] = true;
								}
								else
								{
									PrintToChat(Client, "You are already bandaged.");
								}	
							}
						}
					}
				}
			}
		}
		case MenuAction_End:
		{
			CloseHandle(hMedicalMenu);
		}
	}
}

public PropCategoryHandler(Handle:hPropMenu, MenuAction:action, Client, SelectedOption)
{

	switch (action)
	{
		case MenuAction_Select:
		{
			switch (IsPlayerAlive(Client))
			{
				case true:
				{
					decl String:Temp[8];
					decl pPropSelected;
					GetMenuItem(hPropMenu, SelectedOption, Temp, sizeof(Temp));
					pPropSelected = StringToInt(Temp);

					if (pPropSelected != PROP_NONE)
					{					
						switch (pPropSelected)
						{
							case 0:
							{
								SpawnProp(Client, PROP_WOODEN_BOX_MODEL, 155, PROP_WOODEN_BOX, 24);
							}
							case 1:
							{
								SpawnProp(Client, PROP_DOUBLE_WOODEN_BOX_MODEL, 255, PROP_DOUBLE_WOODEN_BOX, 24);
							}
							case 2:
							{
								SpawnProp(Client, PROP_WOODEN_PALLET_MODEL, 220, PROP_WOODEN_PALLET, 45);
							}
							case 98:
							{
								decl cProp;
								
								cProp = pDataInt[SKILL1DATA_1][ROUND][Client];
								
								if (cProp > NONE)
								{
									if (IsValidEdict(cProp))
									{
										AcceptEntityInput(cProp, "break");
										AcceptEntityInput(cProp, "kill");
									}
									pDataInt[SKILL1DATA_1][ROUND][Client] = NONE;
								}
							}
							case 99:
							{
								decl cProp, cPropOwner;
								
								for (new i = 0; i < MAX_PROPS; i++)
								{
									cPropOwner = pPlayerProps[i][PROP_OWNER];
									
									if (cPropOwner == Client)
									{
										cProp = pPlayerProps[i][PROP_ENTITY];
										
										if (IsValidEdict(cProp))
										{
											AcceptEntityInput(cProp, "kill");
											pDataFloat[FLOAT_SKILL_1_DATA][ROUND][Client] -= pPropsWeight[pPlayerProps[i][PROP_WEIGHT]][ROUND];
										}

										ClearSingleProp(i);
									}
								}
							}
						}
					}
				}
			}
		}
		case MenuAction_End:
		{
			CloseHandle(hPropMenu);
		}
	}
}

bool:MineChecks(Client)
{
	if (IsPlayerAlive(Client))
	{
		new String:Target[64];
		decl Entity;
		Entity = GetClientAimTarget(Client, false);

		if (Entity > NONE)
		{
			GetEntPropString(Entity, Prop_Data, "m_iName", Target, sizeof(Target));
			if (StrContains(Target, "BeamMDL", false) == 0)
			{
				return false;
			}
		}
	}
	else
	{
		return false;
	}
	return true;
}

SetMine(Client, Mine)
{
	decl Float:Start[3], Float:Angle[3], Float:End[3], Float:Normal[3], Float:BeamEnd[3], Float:Rotate[3], Float:cGameTime;
	cGameTime = GetGameTime();

	GetClientEyePosition( Client, Start );
	GetClientEyeAngles( Client, Angle );
	GetAngleVectors(Angle, End, NULL_VECTOR, NULL_VECTOR);
	NormalizeVector(End, End);

	for(new x = NONE; x < 3; x++)
	{
		Start[x]=Start[x]+End[x]*5;
		End[x]=Start[x]+End[x]*64;
	}
	
	TR_TraceRayFilter(Start, End, CONTENTS_SOLID, RayType_EndPoint, FilterAll, NONE);
	
	if (TR_DidHit(INVALID_HANDLE))
	{
		TR_GetEndPosition(End, INVALID_HANDLE);
		TR_GetPlaneNormal(INVALID_HANDLE, Normal);
		GetVectorAngles(Normal, Normal);

		TR_TraceRayFilter(End, Normal, CONTENTS_SOLID, RayType_Infinite, FilterAll, NONE);
		TR_GetEndPosition(BeamEnd, INVALID_HANDLE);

		Rotate[0] = 90.0 + Normal[0];
		Rotate[1] = NONE + Normal[1];
		Rotate[2] = NONE + Normal[2];
		
		if (Normal[0]<181 && Normal[0])
		{
			End[2] -= 1.8;
			BeamEnd[2] -= 1.8;
		}
		else
		{
			End[2] += 1.8;
			BeamEnd[2] += 1.8;
		}

		if (Normal[1]<181 && Normal[1])
		{
			End[0] -= 3.5;
			End[1] += 2.8;
			BeamEnd[0] -= 3.5;
			BeamEnd[1] += 2.8;
		}
		else
		{
			End[1] -= 1.8;
			BeamEnd[1] -= 1.8;
		}

		if (Normal[2]<181 && Normal[2])
		{
			End[0] -= 1.8;
			BeamEnd[0] -= 1.8;
		}
		else
		{
			End[0] += 1.5;
			BeamEnd[0] += 1.5;
		}
		
		decl Float:bTime;
		bTime = TR_GetFraction(INVALID_HANDLE);
		pDataFloat[FLOAT_SKILL_1_TIME][ROUND][Client] = cGameTime;		
		
		switch (Mine)
		{
			case MINE_TRIP:
			{
				if (bTime > 0.006000)
				{
					PrintToChat(Client, "The opposite wall is too far away.");
					return;
				}
				
				pDataInt[SKILL1DATA_1][ROUND][Client]--;
				TripMine(Client, BeamEnd, End, Rotate);
				PrintToChat(Client, "You have %i tripmine(s) left.", pDataInt[SKILL1DATA_1][ROUND][Client]);
			}
			
			case MINE_PROXIMITY:
			{
				pDataInt[SKILL1DATA_3][ROUND][Client]--;
				ProxMine(Client, End, Rotate);
				PrintToChat(Client, "You have %i proxmine(s) left.", pDataInt[SKILL1DATA_3][ROUND][Client]);
			}
		}	 
	}
	else
	{
		PrintToChat(Client, "You are too far away from the wall.");
	}
	return; 
}

TripMine(Client, Float:BeamEnd[3], Float:End[3], Float:Rotate[3])
{
	new String:Temp[32], String:BeamID[32], String:MineID[32];
	decl Entity, Entity2;
		
	Entity = CreateEntityByName("prop_physics_override");
	Entity2	= CreateEntityByName("env_beam");
	
	IntToString(Entity, MineID, sizeof(MineID));
	IntToString(Entity2, BeamID, sizeof(BeamID));
	
	// Setup Mine
	SetEntityModel(Entity,MDL_MINE);
	DispatchSpawn(Entity);
		
	SetEntityMoveType(Entity, MOVETYPE_NONE);
		
	SetEntProp(Entity, Prop_Data, "m_usSolidFlags", 152);
	SetEntProp(Entity, Prop_Data, "m_CollisionGroup", 1);
	SetEntProp(Entity, Prop_Data, "m_MoveCollide", 0);
	SetEntProp(Entity, Prop_Data, "m_nSolidType", 6);
	SetEntProp(Entity, Prop_Data, "m_takedamage", 2);
	SetEntProp(Entity, Prop_Data, "m_iHealth", 5);
	SetEntPropEnt(Entity, Prop_Data, "m_hLastAttacker", Client);
		
	DispatchKeyValue(Entity, "rendercolor", "0 165 70");
	DispatchKeyValue(Entity, "targetname", BeamID);
	DispatchKeyValue(Entity, "ExplodeRadius", "185");
	DispatchKeyValue(Entity, "ExplodeDamage", "260");
	DispatchKeyValue(Entity, "disableshadows", "1");
	Format(Temp, sizeof(Temp), "%s,Break,,0,-1", MineID);
	DispatchKeyValue(Entity, "OnHealthChanged", Temp);
	Format(Temp, sizeof(Temp), "%s,Kill,,0,-1", BeamID);
	DispatchKeyValue(Entity, "OnBreak", Temp);
	Format(Temp, sizeof(Temp), "%s,Kill,,0,-1", MineID);
	DispatchKeyValue(Entity, "OnBreak", Temp);
	
	TeleportEntity(Entity, End, Rotate, NULL_VECTOR);

	// Setup Beam
	SetEntityModel(Entity2, MDL_LASER);
				
	DispatchKeyValue(Entity2, "texture", MDL_LASER);
	DispatchKeyValue(Entity2, "targetname", MineID);
	DispatchKeyValue(Entity2, "TouchType", "8");
	DispatchKeyValue(Entity2, "LightningStart", BeamID);
	DispatchKeyValue(Entity2, "NoiseAmplitude", "0");
	DispatchKeyValue(Entity2, "BoltWidth", "1.0");
	DispatchKeyValue(Entity2, "life", "0");
	DispatchKeyValue(Entity2, "rendercolor", "0 0 0");
	DispatchKeyValue(Entity2, "renderamt", "0");
	DispatchKeyValue(Entity2, "HDRColorScale", "1.0");
	DispatchKeyValue(Entity2, "decalname", "Bigshot");
	DispatchKeyValue(Entity2, "StrikeTime", "0");
	DispatchKeyValue(Entity2, "TextureScroll", "35");
		 
	SetEntPropVector(Entity2, Prop_Data, "m_vecEndPos", End);
	SetEntPropFloat(Entity2, Prop_Data, "m_fWidth", 1.0);
	
	HookSingleEntityOutput(Entity2, "OnTouchedByEntity", HandleTripMineBeam, false);
	TeleportEntity(Entity2, BeamEnd, NULL_VECTOR, NULL_VECTOR);
	AcceptEntityInput(Entity2, "TurnOff");

	CreateTimer(3.0, TurnTripBeamOn, Entity2);
	EmitSoundToAll(SND_MINE, Entity, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, 100, Entity, End, NULL_VECTOR, true, 0.0);
}

ProxMine(Client,Float:End[3], Float:Rotate[3])
{
	new String:Temp[32], String:MineID[32];
	decl Entity;
		
	Entity = CreateEntityByName("prop_physics_override");
	IntToString(Entity, MineID, sizeof(MineID));
	
	SetEntityModel(Entity,MDL_MINE);
	DispatchKeyValue(Entity, "StartDisabled", "false");
	DispatchSpawn(Entity);
	
	SetEntityMoveType(Entity, MOVETYPE_NONE);
		
	SetEntProp(Entity, Prop_Data, "m_usSolidFlags", 152);
	SetEntProp(Entity, Prop_Data, "m_CollisionGroup", 1);
	SetEntProp(Entity, Prop_Data, "m_MoveCollide", 0);
	SetEntProp(Entity, Prop_Data, "m_nSolidType", 6);
	SetEntProp(Entity, Prop_Data, "m_takedamage", 2);
	SetEntProp(Entity, Prop_Data, "m_iHealth", 5);
	SetEntPropEnt(Entity, Prop_Data, "m_hLastAttacker", Client);
		
	DispatchKeyValue(Entity, "rendercolor", "100 10 10");
	DispatchKeyValue(Entity, "targetname", MineID);
	DispatchKeyValue(Entity, "ExplodeRadius", "160");
	DispatchKeyValue(Entity, "ExplodeDamage", "245");
	DispatchKeyValue(Entity, "disableshadows", "1");
	Format(Temp, sizeof(Temp), "%s,Break,,0,-1", MineID);
	DispatchKeyValue(Entity, "OnHealthChanged", Temp);
	Format(Temp, sizeof(Temp), "%s,Kill,,0,-1", MineID);
	DispatchKeyValue(Entity, "OnBreak", Temp);
		
	TeleportEntity(Entity, End, Rotate, NULL_VECTOR);

	CreateTimer(3.0, TurnProxMineOn, Entity);
	EmitSoundToAll(SND_MINE, Entity, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, 100, Entity, End, NULL_VECTOR, true, 0.0);
}

public HandleTripMineBeam(const String:output[], caller, activator, Float:delay)
{
	decl String:iName[64], MineID;
	GetEntPropString(caller, Prop_Data, "m_iName", iName, sizeof(iName));
	MineID = StringToInt(iName);
	
	AcceptEntityInput(caller, "TurnOff");
	AcceptEntityInput(caller, "TurnOn");
	
	if (IsPlayer(activator))
	{
		decl aTeam;
		aTeam = GetClientTeam(activator);
		
		switch (aTeam)
		{
			case HUMAN:
			{
				//SetEntPropEnt(MineID, Prop_Data, "m_hLastAttacker", activator);
				SetEntPropEnt(MineID, Prop_Data, "m_hLastAttacker", -1);
				AcceptEntityInput(MineID, "Break");
			}
			case ZOMBIE:
			{
				AcceptEntityInput(MineID, "Break");
			}
		}
	}
}

public Action:TurnTripBeamOn(Handle:timer, any:Entity)
{
	if (IsValidEntity(Entity))
	{
		EmitSoundToAll(SND_MINE, Entity, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, 155, Entity, NULL_VECTOR, NULL_VECTOR, true, 0.0);
		DispatchKeyValue(Entity, "rendercolor", "255 65 65");
		AcceptEntityInput(Entity, "TurnOn");
	}
}

public Action:TurnProxMineOn(Handle:timer, any:Entity)
{
	if (IsValidEntity(Entity))
	{
		EmitSoundToAll(SND_MINE, Entity, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, 155, Entity, NULL_VECTOR, NULL_VECTOR, true, 0.0);
		CreateTimer(1.5, ProxMineTimer, Entity, TIMER_REPEAT);
	}
}

public Action:ProxMineTimer(Handle:Timer, any:Entity)
{
	if (IsValidEntity(Entity))
	{
		decl Float:EntityOrigin[3];

		GetEntPropVector(Entity, Prop_Send, "m_vecOrigin", EntityOrigin);
		
		for (new o = 1; o <= MaxClients; o++)
		{
			if (IsClientInGame(o) && IsPlayerAlive(o) && (GetClientTeam(o) == ZOMBIE || GetConVarInt(g_hFriendlyFire)))
			{
				if (CheckDistance(o, Entity, 135))
				{
					decl Float:cPosition[3];
					GetClientEyePosition(o, cPosition);
													
					TR_TraceRayFilter(EntityOrigin, cPosition, MASK_PLAYERSOLID, RayType_EndPoint, FilterNonPlayer, o);
													
					if (TR_DidHit(INVALID_HANDLE))
					{
						if (TR_GetEntityIndex(INVALID_HANDLE) == o)
						{
							AcceptEntityInput(Entity, "break");
							AcceptEntityInput(Entity, "kill");
						}
					}
				}
			}
		}
	}
	else
	{
		KillTimer(Timer);
	}
}

UseZombieSkill(Client, Skill)
{
	decl Float:fSkill1Time, Float:fSkill2Time, Float:cGameTime;
	fSkill1Time = pDataFloat[FLOAT_SKILL_1_TIME][ROUND][Client];
	fSkill2Time = pDataFloat[FLOAT_SKILL_2_TIME][ROUND][Client];
	cGameTime = GetGameTime();
	
	switch (pDataInt[CLASS][ROUND][Client])
	{
		case HULKER:
		{
			switch (Skill)
			{
				case SKILL_1:
				{
					if (pDataHandle[TIMER_SKILL_1][ROUND][Client] == INVALID_HANDLE)
					{
						if (fSkill1Time <= (cGameTime - 10.0) || fSkill1Time == 0.0)
						{
							decl String:Temp[64];
							
							SetSpeed(Client, 0.90, 0.0);
							SetEntityRenderColor(Client, 110, 20, 20, 255);
							
							Format(Temp, sizeof(Temp), "npc/ichthyosaur/attack_growl%i.wav", GetRandomInt(1, 3));
							
							PlaySoundToAll(Temp, Client, 0.4, 80);
							
							pDataFloat[FLOAT_SKILL_1_TIME][ROUND][Client] = cGameTime;
							pDataHandle[TIMER_SKILL_1][ROUND][Client] = CreateTimer(5.0, EndSkillTimer, Client);
						}
						else
						{
							decl Float:tRemain;
							tRemain = (11.0 - (cGameTime - fSkill1Time));
							PrintToChat(Client, "You can enrage again in %s second(s).", ConvertFloatToText(tRemain));
						}	
					}
					else
					{
						PrintToChat(Client, "You are already enraged.");
					}
				}
				
				case SKILL_2:
				{
					if (pDataHandle[TIMER_SKILL_1][ROUND][Client] != INVALID_HANDLE)
					{
						if (fSkill2Time <= (cGameTime - 2.0) || fSkill2Time == 0.0)
						{
							decl Target;
							Target = GetClientAimTarget(Client, false);	
							
							if (IsPlayer(Target) && GetClientTeam(Target) == HUMAN && CheckSightPath(Client, Target))
							{
								if (CheckDistance(Client, Target, 120))
								{
									decl Float:Position[3], Float:Angles[3], Float:Velocity[3], String:Temp[64], rInt;

									rInt = GetRandomInt(10, 30);
									
									Format(Temp, sizeof(Temp), "npc/ichthyosaur/attack_growl%i.wav", GetRandomInt(1, 3));
									PlaySoundToAll(Temp, Client, 0.8, 110);
																	
									GetClientEyePosition(Client, Position);
									GetClientEyeAngles(Client, Angles);
									GetAngleVectors(Angles, Velocity, NULL_VECTOR, NULL_VECTOR);
			
									for (new x = 0; x < 2; x++)
									{
										Velocity[x] = Velocity[x]*500;
									}
									
									Velocity[2] = 225.0;
									
									TeleportEntity(Target, NULL_VECTOR, NULL_VECTOR, Velocity);

									DamagePlayer(Target, rInt, true);	
									SetLastAttacker(Target, Client);
									
									pDataFloat[FLOAT_SKILL_2_TIME][ROUND][Client] = cGameTime;
								}
								else
								{
									PrintToChat(Client, "Your target is too far away.");
								}
							}
							else
							{
								PrintToChat(Client, "You have no target to bash.");
							}	
						}
						else
						{
							decl Float:tRemain;
							tRemain = (3.0 - (cGameTime - fSkill1Time));
							PrintToChat(Client, "You can bash again in %s second(s).", ConvertFloatToText(tRemain));
						}
					}
					else
					{
						PrintToChat(Client, "You must be enraged to use this.");
					}
				}
			}
		}

		case SHIFTER:
		{
			switch (Skill)
			{
				case SKILL_1:
				{
					if (fSkill1Time <= (cGameTime - 9.0) || fSkill1Time == 0.0)
					{
						decl Float:cPosition[3], Float:tPosition[3];
						GetClientEyePosition(Client, cPosition);
						
						TE_SetupSmoke(cPosition, g_Sprite2, 10.0, 1);
						TE_SendToAll(0.0);
						
						PlaySoundToAll(SND_SHIFTER_SHADOWS, Client, 0.5, 130);
						
						for (new o = 1; o <= MaxClients; o++)
						{
							if (IsClientInGame(o) && IsPlayerAlive(o) && GetClientTeam(o) == HUMAN)
							{
								if (CheckDistance(Client, o, 165))
								{								
									GetClientEyePosition(o, tPosition);		
									
									TR_TraceRayFilter(tPosition, cPosition, MASK_PLAYERSOLID, RayType_EndPoint, FilterNonPlayer, o);
																	
									if (TR_DidHit(INVALID_HANDLE))
									{
										if (TR_GetEntityIndex(INVALID_HANDLE) == o)
										{
											FadeClientVolume(o, 100.0, 3.0, 0.6, 0.2);
											FadeClientScreen(o, 248, 1200, FADE_IN);
										}
									}
								}
							}
						}
						pDataFloat[FLOAT_SKILL_1_TIME][ROUND][Client] = cGameTime;
					}
					else
					{
						decl Float:tRemain;
						tRemain = (10.0 - (cGameTime - fSkill1Time));
						PrintToChat(Client, "You can shadow seep again in %s second(s).", ConvertFloatToText(tRemain));
					}	
				}
				
				case SKILL_2:
				{
					/*
					decl Float:cPosition[3], Float:cAngles[3], Float:cDirection[3];
					GetClientEyePosition(Client, cPosition);
					GetClientEyeAngles(Client, cAngles);
					GetAngleVectors(cAngles, cDirection, NULL_VECTOR, NULL_VECTOR);
					
					NormalizeVector(cDirection, cDirection);
								
					for (new x = 0; x < 3; x++)
					{
						cDirection[x]=cDirection[x]*700;
					}
					
					TE_Start("Sprite Spray");
					TE_WriteVector("m_vecOrigin", cPosition);
					TE_WriteVector("m_vecDirection", cDirection);
					TE_WriteFloat("m_fNoise", 1000.0);
					TE_WriteNum("m_nCount", 20);
					TE_WriteNum("m_nSpeed", 3);
					TE_WriteNum("m_nModelIndex", g_Sprite3);
					TE_SendToAll(0.0);
					*/
					//SetClientOverlay(Client, "debug/yuv");
					PrintToChat(Client, "This class has no secondary skill.");
				}
			}
		}

		case LEAPER:
		{
			switch (Skill)
			{
				case SKILL_1:
				{
					if (fSkill1Time <= (cGameTime - 2.0) || fSkill1Time == 0.0)
					{
						decl Float:Position[3], Float:Angles[3], Float:Velocity[3], String:Temp[64];
								
						GetClientEyePosition(Client, Position);
						GetClientEyeAngles(Client, Angles);
						GetAngleVectors(Angles, Velocity, NULL_VECTOR, NULL_VECTOR);
						
						for (new x = 0; x < 2; x++)
						{
							Velocity[x] = Velocity[x]*250;
						}
						
						Velocity[2] = 270.0;
						
						Format(Temp, sizeof(Temp), "npc/antlion_guard/angry%i.wav", GetRandomInt(1, 3));
						
						PlaySoundToAll(Temp, Client, 0.25, 160);

						SetEntPropVector(Client, Prop_Data, "m_vecBaseVelocity", Velocity);
						pDataFloat[FLOAT_SKILL_1_TIME][ROUND][Client] = cGameTime;
					}
					else
					{
						decl Float:tRemain;
						tRemain = (3.0 - (cGameTime - fSkill1Time));
						PrintToChat(Client, "You can Leap again in %s second(s).", ConvertFloatToText(tRemain));
					}
				}
				
				case SKILL_2:
				{
					if (fSkill2Time <= (cGameTime - 11.0) || fSkill2Time == 0.0)
					{						
						decl Target;
						Target = GetClientAimTarget(Client, false);
						
						if (IsPlayer(Target) && GetClientTeam(Target) == HUMAN && CheckSightPath(Client, Target))
						{
							if (CheckDistance(Client, Target, 115))
							{
								if (pDataHandle[TIMER_PUNCTURE][ROUND][Target] == INVALID_HANDLE)
								{
									PlaySoundToAll(SND_LEAPER_PUNCTURE, Client, 0.17, 95);
									
									for(new x; x < GetRandomInt(4,7); x++)
									{
										Bleed(Target, 12, HUMAN, true);
									}
									
									InfectPlayer(Target, 8, GetRandomInt(75, 135));
									
									SDKCall(hDamageEffect, Client, 0.0, 1);
									SDKCall(hDamageEffect, Target, 0.0, 1);
									SDKCall(hDamageEffect, Target, 0.0, 2);
															
									SetLastAttacker(Target, Client);
															
									pDataBool[IS_BANDAGED][ROUND][Target] = false;
									pDataFloat[FLOAT_SKILL_2_TIME][ROUND][Client] = cGameTime;
									pDataHandle[TIMER_PUNCTURE][ROUND][Target] = CreateTimer(GetRandomFloat(1.0, 1.7), PunctureTimer, Target, TIMER_REPEAT);
								}
								else
								{
									PrintToChat(Client, "They are already punctured.");
								}					
							}
							else
							{
								PrintToChat(Client, "Your target is too far away.");
							}
						}
						else
						{
							PrintToChat(Client, "You have no target to puncture.");
						}	
					}
					else
					{
						decl Float:tRemain;
						tRemain = (12.0 - (cGameTime - fSkill2Time));
						PrintToChat(Client, "You can puncture again in %s second(s).", ConvertFloatToText(tRemain));
					}
				}
			}
		}
		case FULMINATOR:
		{
			switch (Skill)
			{
				case SKILL_1:
				{
					decl Float:EntityOrigin[3], Entity;
					Entity = GetClientAimTarget(Client, false);
					GetEntPropVector(Entity, Prop_Send, "m_vecOrigin", EntityOrigin);
					
					for (new x = 1; x < 10; x++)
					{
						TE_SetupBeamRingPoint(EntityOrigin, 1.0, 60.0, g_Sprite1, g_Sprite1, 0, 20, 0.9, 25.0, 0.5, {255, 20, 20, 220}, 1, 0);
						TE_SendToAll();
						TE_SetupBeamRingPoint(EntityOrigin, 35.0, 150.0, g_Sprite1, g_Sprite1, 0, 20, 0.8, 15.0, 0.3, {180, 50, 50, 180}, 1, 0);
						TE_SendToAll();
						TE_SetupBeamRingPoint(EntityOrigin, 110.0, 280.0, g_Sprite1, g_Sprite1, 0, 20, 0.9, 7.0, 0.1, {190, 20, 20, 120}, 1, 0);
						TE_SendToAll();
						EntityOrigin[2] += 6;
					}
				}
				case SKILL_2:
				{
					new Float:zMod = 0.0;
					
					for (new x = 1; x < 6; x++)
					{
						zMod += 10.0;
						Bleed(Client, 9, ZOMBIE, false, zMod);
					}
				}
			}
		}
		default:
		{
			switch (Skill)
			{
				case SKILL_1:
				{
					PrintToChat(Client, "This class has no primary skill.");
				}
				case SKILL_2:
				{
					PrintToChat(Client, "This class has no secondary skill.");
				}
			}
		}
	}
}
