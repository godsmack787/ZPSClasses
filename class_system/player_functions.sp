SetPlayerDefaults(Client, pTeam)
{
	SetEntityRenderColor(Client, 255, 255, 255, 255);
	SetEntityRenderFx(Client, RENDERFX_NONE);
	SetEntityRenderMode(Client, RENDER_NORMAL);
	FadeClientScreen(Client, 0, 0, NO_FADE);
	SetEntityGravity(Client, 1.0);	
	RemoveClientOverlay(Client);
	SetEntProp(Client, Prop_Data, "m_CollisionGroup", 5);
	SetEntProp(Client, Prop_Data, "m_takedamage", 2);

	switch (pTeam)
	{
		case HUMAN, ZOMBIE:
		{
			decl Float:sVector[3];
			GetClientAbsOrigin(Client, sVector);
			SetPlayerVector(Client, sVector, VECTOR_SPAWN);
			SetDefaultHealth(Client, CLASS_NONE, pTeam);
			SetDefaultSpeed(Client, CLASS_NONE, pTeam);
		}
	}
}

ClearPlayerData(Client, bool:ClearMapData)
{
	decl cClass, cTeam, cTeamArray;	
	cClass = pDataInt[CLASS][ROUND][Client];
	cTeam = pDataInt[CLASS_TEAM][ROUND][Client];
	cTeamArray = (pDataInt[CLASS_TEAM][ROUND][Client] - 2);
	
	if (cClass != CLASS_NONE)
	{
		switch (cTeam)
		{
			case HUMAN, ZOMBIE:
			{
				iClassLimitCurrent[cClass][cTeamArray]--;
			}
		}
	}
	
	switch (cTeam)
	{
		case HUMAN:
		{
			switch (cClass)
			{
				case CONSTRUCTOR:
				{
					ClearPlayerProps(Client);
				}
			}
		}
	}

	KillAllPlayerTimers(Client);
	
	for (new r = NONE; r < PARALLEL_SIZE; r++)
	{
		pDataInt[r][ROUND][Client] = NONE;
		pDataFloat[r][ROUND][Client] = 0.0;
		pDataBool[r][ROUND][Client] = false;
		DeletePlayerVector(Client, r);
		
		if (ClearMapData)
		{
			switch (r)
			{
				case LAST_CLASS:
				{
					pDataInt[LAST_CLASS][MAP][Client] = CLASS_NONE;
				}
				default:
				{
					pDataInt[r][MAP][Client] = NONE;
				}	
			}
		}
	}
	
	pDataInt[CLASS][ROUND][Client] = CLASS_NONE;
}

ClearAllPlayerData(bool:ClearMapData)
{
	for (new x = 1; x <= MaxClients; x++)
	{
		ClearPlayerData(x, ClearMapData);
	}
}


KillPlayerTimer(Client, Timer)
{
	if (pDataHandle[Timer][ROUND][Client] != INVALID_HANDLE)
	{
		KillTimer(pDataHandle[Timer][ROUND][Client]);
		pDataHandle[Timer][ROUND][Client] = INVALID_HANDLE;
	}
}

KillAllPlayerTimers(Client)
{
	for (new r = NONE; r < PARALLEL_SIZE; r++)
	{
		KillPlayerTimer(Client, r);
	}
}

ClearPlayerProps(Client)
{	
	decl cPropOwner;
	
	for (new i = NONE; i < MAX_PROPS; i++)
	{
		cPropOwner = pPlayerProps[i][PROP_OWNER];
							
		if (cPropOwner == Client)
		{
			ClearSingleProp(i);
		}
	}
}

AddHeldEntity(Entity)
{
	for (new i = NONE; i < MAX_PROPS; i++)
	{
		if (hHeldEntities[i][ROUND] == NONE)
		{
			hHeldEntities[i][ROUND] = Entity;
			break;
		}
	}
}

DeleteHeldEntity(Entity)
{
	for (new i = NONE; i < MAX_PROPS; i++)
	{
		if (hHeldEntities[i][ROUND] == Entity)
		{
			hHeldEntities[i][ROUND] = NONE;
			break;
		}
	}
}

bool:IsEntityHeld(Entity)
{
	for (new i = NONE; i < MAX_PROPS; i++)
	{
		if (hHeldEntities[i][ROUND] == Entity)
		{
			return true;
		}
	}
	return false;
}

AddRagdoll(Entity)
{
	for (new i = NONE; i < MAX_PROPS; i++)
	{
		if (hHumanRagdolls[i][ROUND] == NONE)
		{
			hHumanRagdolls[i][ROUND] = Entity;
			break;
		}
	}
}

DeleteRagdoll(Entity)
{
	for (new i = NONE; i < MAX_PROPS; i++)
	{
		if (hHumanRagdolls[i][ROUND] == Entity)
		{
			hHumanRagdolls[i][ROUND] = NONE;
			break;
		}
	}
}

ClearGlobalVariables()
{
	for (new i = NONE; i < MAX_PROPS; i++)
	{
		hHeldEntities[i][ROUND] = NONE;
		
		for (new r = NONE; r < 2; r++)
		{
			hHumanRagdolls[i][r] = NONE;
		}
		
		for (new x = NONE; x < 3; x++)
		{
			pPlayerProps[i][x] = NONE;
		}
	}

	RoundStarted = false;
	
	if (hRoundTimer != INVALID_HANDLE)
	{
		KillTimer(hRoundTimer);
	}
	
	hRoundTimer = CreateTimer(0.5, RoundStartTimer, _, TIMER_REPEAT);
}

DeletePlayerVector(Client, Vector)
{
	for (new i = NONE; i < 3; i++)
	{
		pDataVector[Vector][i][Client] = 0.0;
	}
}

SetPlayerVector(Client, Float:pVector[3], dVector)
{
	for (new i = NONE; i < 3; i++)
	{
		pDataVector[dVector][i][Client] = pVector[i];
	}
}

SetSpawnModel(Client, Team)
{
	decl String:mName[128];
	
	switch (Team)
	{
		case HUMAN:
		{
			GetClientModel(Client, mName, sizeof(mName));

			switch (strcmp(mName, WHITE_MODEL, false))
			{
				case COMPARE_MATCH:
				{
					Format(mName, sizeof(mName), "models/humans/custom/male_0%i.mdl", GetRandomInt(1, 3));
					SetEntityModel(Client, mName);
					pDataBool[IS_WHITE_MODEL][ROUND][Client] = true;
				}
				  
				default:
				{
					switch (strcmp(mName, BLACK_MODEL, false))
					{
						case COMPARE_MATCH:
						{
							Format(mName, sizeof(mName), "models/humans/custom/male_0%i.mdl", GetRandomInt(4, 6));
							SetEntityModel(Client, mName);
						}
					}
				}
			}
		}
		/*
		case ZOMBIE:
		{
			GetClientModel(Client, mName, sizeof(mName));
			switch (strcmp(mName, CARRIER_MODEL, false))
			{
				case COMPARE_MATCH:
				{
					Format(mName, sizeof(mName), "models/custom/carrier.mdl");
					SetEntityModel(Client, mName);
					pDataBool[IS_CARRIER][ROUND][Client] = true;
				}
				default:
				{
					Format(mName, sizeof(mName), "models/custom/normal%i.mdl", GetRandomInt(1, 5));
					SetEntityModel(Client, mName);
				}
			}
		}
		*/
	}
}

SetClassModel(Client, Class, Team)
{
	decl String:mName[128];
	
	switch (Team)
	{
		case HUMAN:
		{
			switch (Class)
			{
				case MEDIC:
				{
					switch (pDataBool[IS_WHITE_MODEL][ROUND][Client])
					{
						case true:
						{
							Format(mName, sizeof(mName), "models/humans/group03m/male_0%i.mdl", GetRandomInt(6, 9));
							SetEntityModel(Client, mName);
						}
						  
						case false:
						{
							switch (GetRandomInt(1, 3))
							{
								case 1:
								{
									SetEntityModel(Client, "models/humans/group03m/male_01.mdl");
								}
								case 2:
								{
									SetEntityModel(Client, "models/humans/group03m/male_03.mdl");
								}
								case 3:
								{
									SetEntityModel(Client, "models/humans/group03m/male_05.mdl");
								}
							}
						}
					}
				}
				case DEMOLITIONIST:
				{
					SetEntityModel(Client, MDL_DEMOLITIONIST);
				}
				case CONSTRUCTOR:
				{
					switch (pDataBool[IS_WHITE_MODEL][ROUND][Client])
					{
						case true:
						{
							Format(mName, sizeof(mName), "models/humans/group03/male_0%i.mdl", GetRandomInt(6, 9));
							SetEntityModel(Client, mName);
						}
						  
						case false:
						{
							switch (GetRandomInt(1, 3))
							{
								case 1:
								{
									SetEntityModel(Client, "models/humans/group03/male_01.mdl");
								}
								case 2:
								{
									SetEntityModel(Client, "models/humans/group03/male_03.mdl");
								}
								case 3:
								{
									SetEntityModel(Client, "models/humans/group03/male_05.mdl");
								}
							}
						}
					}
				}
			}
		}
		
		case ZOMBIE:
		{
			GetClientModel(Client, mName, sizeof(mName));
			switch (strcmp(mName, CARRIER_MODEL, false))
			{
				case COMPARE_MATCH:
				{
					//Format(mName, sizeof(mName), "models/custom/carrier.mdl");
					//SetEntityModel(Client, mName);
					pDataBool[IS_CARRIER][ROUND][Client] = true;
				}
				/*
				default:
				{
					if (strcmp(mName, "models/custom/carrier.mdl", false) != COMPARE_MATCH)
					{
						Format(mName, sizeof(mName), "models/custom/normal%i.mdl", GetRandomInt(1, 5));
						SetEntityModel(Client, mName);
					}
				}
				*/
			}
		}
	}
}

SetDefaultSpeed(Client, Class, cTeam)
{
	switch (cTeam)
	{
		case HUMAN:
		{
			switch (Class)
			{
				case CLASS_NONE:
				{
					SetSpeed(Client, 1.0, 0.0);
				}
				default:
				{
					SetSpeed(Client, cBaseSpeed[Class][HUMAN - 2], 0.0);
				}
			}
		}
		case ZOMBIE:
		{
			switch (Class)
			{
				case CLASS_NONE:
				{
					SetSpeed(Client, 0.75, 0.0);
				}
				case LEAPER:
				{
					SetSpeed(Client, cBaseSpeed[LEAPER][ZOMBIE - 2], 0.15);
				}
				default:
				{
					SetSpeed(Client, cBaseSpeed[Class][ZOMBIE - 2], 0.0);
				}
			}
		}
	}
}

SetSpeed(Client, Float:Speed, Float:GravityMod)
{
	new Float:Gravity;
	Gravity = ((2.0 - Speed) - GravityMod);
	
	SetEntityGravity(Client, Gravity);
	SetEntPropFloat(Client, Prop_Data, "m_flLaggedMovementValue", Speed);
}

SetDefaultHealth(Client, Class, cTeam)
{
	decl NewHealth, CurHealth;
	CurHealth = GetClientHealth(Client);
	
	switch (Class)
	{
		case CLASS_NONE:
		{
			NewHealth = CurHealth;
		}
		default:
		{
			NewHealth = cBaseHealth[Class][cTeam - 2];
		}
	}
	
	pDataInt[MAXHEALTH][ROUND][Client] = NewHealth;
	
	if (CurHealth !=  NewHealth)
	{
		SetEntityHealth(Client, NewHealth);
	}
}

InfectPlayer(Client, Chance, Time)
{
	if (!IsInfected(Client))
	{
		if (GetRandomInt(1, 100) <= Chance)
		{
			SetEntDataFloat(Client, g_InfectionTimeOffset, (GetGameTime() + Time));
			SetEntData(Client, FindSendPropInfo("CHL2MP_Player", "m_IsInfected"), 1); 
		}
	}
}

bool:IsInfected(Client)
{
	if (GetEntData(Client, FindSendPropInfo("CHL2MP_Player", "m_IsInfected"))) return true;
	
	return false;
}

SetLastAttacker(Client, Attacker)
{
	pDataInt[LAST_ATTACKER][ROUND][Client] = GetClientUserId(Attacker);
}

GetLastAttacker(Client)
{
	return GetClientOfUserId(pDataInt[LAST_ATTACKER][ROUND][Client]);
}

FadeClientScreen(Client, Amount, FadeTime, Flags)
{
	new Target[2], Handle:Msg;
	Target[0] = Client;
	
	Msg = StartMessageEx(g_FadeUserMsgId, Target, 1);
	
	BfWriteShort(Msg, FadeTime);
	BfWriteShort(Msg, FadeTime);
	

	BfWriteShort(Msg, Flags);

	BfWriteByte(Msg, 0);
	BfWriteByte(Msg, 0);
	BfWriteByte(Msg, 0);
	BfWriteByte(Msg, Amount);
	 
	EndMessage();
}