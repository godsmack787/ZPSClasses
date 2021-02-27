public Action:ObjectHoldTimer(Handle:Timer, any:Client)
{
	decl Entity;
	Entity = pDataInt[SKILL2DATA_1][ROUND][Client];
	
	switch (IsValidEdict(Entity))
	{
		case true:
		{
			switch (pDataBool[IS_HOLDING_OBJECT][ROUND][Client])
			{
				case true:
				{
					HoldProp(Client, Entity);
				}
				case false:
				{
					AcceptEntityInput(Entity, "EnableMotion");
					AcceptEntityInput(Entity, "Wake");
					SetDefaultSpeed(Client, CONSTRUCTOR, HUMAN);
					DeleteHeldEntity(Entity);
					pDataBool[IS_HOLDING_OBJECT][ROUND][Client] = false;
					KillPlayerTimer(Client, TIMER_HOLDING_OBJECT);
				}
			}
		}
		case false:
		{
			SetDefaultSpeed(Client, CONSTRUCTOR, HUMAN);
			DeleteHeldEntity(Entity);
			pDataBool[IS_HOLDING_OBJECT][ROUND][Client] = false;
			KillPlayerTimer(Client, TIMER_HOLDING_OBJECT);
		}
	}
}

public Action:BleedThink(Handle:Timer)
{
	for (new x = 1; x <= MaxClients; x++)
	{
		if (IsClientInGame(x) && IsPlayerAlive(x))
		{
			decl cTeam;
			cTeam = GetClientTeam(x);
			
			if (cTeam == HUMAN)
			{
				decl Health;
				Health = GetClientHealth(x);
				
				if (!pDataBool[IS_BANDAGED][ROUND][x])
				{
					if (Health < 20)
					{
						decl String:Temp[32], rInt;
						rInt = GetRandomInt(1, 4);

						Format(Temp, 32, "Infection/Jolt-0%i.wav", GetRandomInt(2,4));
						PlaySoundToAll(Temp, x, 0.23, 100);
						
						Bleed(x, 12, cTeam, true);
						DamagePlayer(x, rInt, false);
					}
				}
				else
				{
					if (Health < 75)
					{
						SetEntityHealth(x, Health + GetRandomInt(1, 2));
					}
					else
					{
						pDataBool[IS_BANDAGED][ROUND][x] = false;
					}
				}
			}
		}
	}
}

public Action:EndSkillTimer(Handle:Timer, any:Client)
{
	if (IsClientInGame(Client) && IsPlayerAlive(Client))
	{
		switch (GetClientTeam(Client))
		{
			case ZOMBIE:
			{
				switch (pDataInt[CLASS][ROUND][Client])
				{
					case HULKER:
					{
						SetDefaultSpeed(Client, HULKER, ZOMBIE);
						SetEntityRenderColor(Client, 150, 90, 90, 255);
					}
				}
			}
		}
	}
	
	KillPlayerTimer(Client, TIMER_SKILL_1);
}

public Action:PunctureTimer(Handle:Timer, any:Client)
{
	if (IsClientInGame(Client) && IsPlayerAlive(Client))
	{
		decl cTeam;
		cTeam = GetClientTeam(Client);
		
		if (cTeam == HUMAN && !pDataBool[IS_BANDAGED][ROUND][Client])
		{ 
			decl String:Temp[64], rInt;
			rInt = GetRandomInt(2, 4);
			
			DamagePlayer(Client, GetRandomInt(2, 5), false);
					
			Format(Temp, sizeof(Temp), "Infection/Jolt-0%i.wav", GetRandomInt(2, 4));
			PlaySoundToAll(Temp, Client, 0.10, 100);
					
			for (new x = 1; x < rInt; x++)
			{
				Bleed(Client, 12, cTeam, true);
			}
					
			if (GetRandomInt(1, 100) <= 15)
			{
				KillPlayerTimer(Client, TIMER_PUNCTURE);
			}
		}
		else
		{
			KillPlayerTimer(Client, TIMER_PUNCTURE);
		}
	}
	else
	{
		KillPlayerTimer(Client, TIMER_PUNCTURE);
	}
}

public Action:Restrict(Handle:Timer, any:Client)
{
	if (IsClientInGame(Client) && IsPlayerAlive(Client) && GetClientTeam(Client) == HUMAN)
	{
		decl String:sName[32], pClass, Entity, iSlot;
		pClass = pDataInt[CLASS][ROUND][Client];
		Entity = GetEntDataEnt2(Client, g_hActiveWeapon);
		GetEdictClassname(Entity, sName, sizeof(sName));
		
		for (new i = NONE;i< 5;++i)
		{
			switch (strcmp(sName, sRestricted[pClass][i], false))
			{
				case COMPARE_MATCH:
				{
					new bool:HasSwitched = false;
					
					PrintToChat(Client, "Your class can't use that weapon.");
					
					for (new j = 1; j < 5; ++j)
					{
						iSlot = GetPlayerWeaponSlot(Client, j);
						
						if (Entity != iSlot && iSlot != -1)
						{
							DropWeapon(Client, Entity, false);
							SDKCall(hSwitchWeapon, Client, iSlot, NONE, NONE);
							SDKCall(hScootInventory, Client);
							HasSwitched = true;
							
							break;
						}
					}
					
					if (!HasSwitched)
					{
						DropWeapon(Client, Entity, false);
						SDKCall(hSwitchWeapon, Client, GetPlayerWeaponSlot(Client, 0), NONE, NONE);
						SDKCall(hScootInventory, Client);
					}
					
					break;
				}
			}
		}
	}
	else
	{
		KillPlayerTimer(Client, TIMER_RESTRICT);
	}
}

public Action:OffsetNaturalRegen(Handle:timer, any:Client)
{
	if (IsClientInGame(Client) && IsPlayerAlive(Client))
	{
		switch (GetClientTeam(Client))
		{
			case ZOMBIE:
			{
				switch (pDataInt[CLASS][ROUND][Client])
				{
					case HULKER:
					{
						KillPlayerTimer(Client, TIMER_REGEN_OFFSET);
					}
					default:
					{
						decl Health, pMaxHealth;
						Health = GetClientHealth(Client);
						pMaxHealth = pDataInt[MAXHEALTH][ROUND][Client];
						
						if (Health > pMaxHealth) 
						{
							SetEntityHealth(Client, pMaxHealth);
						}
					}
				}
			}
			default:
			{
				KillPlayerTimer(Client, TIMER_REGEN_OFFSET);
			}
		}
	}
	else
	{
		KillPlayerTimer(Client, TIMER_REGEN_OFFSET);
	}

}

public Action:Regen(Handle:timer, any:Client)
{
	if (IsClientInGame(Client) && IsPlayerAlive(Client))
	{
		decl Health, pMaxHealth;
		Health = GetClientHealth(Client);
		pMaxHealth = pDataInt[MAXHEALTH][ROUND][Client];
		
		if (Health < pMaxHealth)
		{
			decl pClass;
			pClass = pDataInt[CLASS][ROUND][Client];
			
			switch (GetClientTeam(Client))
			{
				case HUMAN:
				{
					switch (pClass)
					{
						case MEDIC:
						{
							if (Health + 1 >= pMaxHealth)
							{
								SetEntityHealth(Client, pMaxHealth);
							}
							else
							{
								SetEntityHealth(Client, Health + 1);
							}
						}
					}
				}
				case ZOMBIE:
				{
					switch (pClass)
					{
						case HULKER:
						{
							if (Health + 12 >= pMaxHealth)
							{
								SetEntityHealth(Client, pMaxHealth);
							}
							else
							{
								if (Health >= 200)
								{
									SetEntityHealth(Client, Health + 12);
								}
								else
								{
									SetEntityHealth(Client, Health + 8);
								}
							}
						}
						default:
						{
							if (Health + 4 >= pMaxHealth)
							{
								SetEntityHealth(Client, pMaxHealth);
							}
							else
							{
								if (Health >= 200)
								{
									SetEntityHealth(Client, Health + 4);
								}
							}
						}
					}
				}
			}

			if (Health >= pMaxHealth) 
			{
				KillPlayerTimer(Client, TIMER_REGEN);
			}
		}
		else
		{
			KillPlayerTimer(Client, TIMER_REGEN);
		}
	}
	else
	{
		KillPlayerTimer(Client, TIMER_REGEN);
	}
}


public Action:UnstuckTeleport(Handle:timer, any:Client)
{
	if (IsClientInGame(Client) && IsPlayerAlive(Client))
	{
		decl Float:sVector[3], Float:sAngles[3];

		for(new r = NONE; r < 3; r++)
		{
			sVector[r] = pDataVector[VECTOR_SPAWN][r][Client];
		}
		
		if (sVector[0] || sVector[1] || sVector[2])
		{
			GetClientEyeAngles(Client, sAngles);
			TeleportEntity(Client, sVector, sAngles, NULL_VECTOR);
		}
		else
		{
			PrintToChat(Client, "No valid spawn point found.");
		}
	}
	
	KillPlayerTimer(Client, TIMER_UNSTUCK);
}

public Action:RoundStartTimer(Handle:timer)
{
	if (GetTeamClientCount(ZOMBIE) || GetConVarInt(g_hTestMode))
	{ 
		RoundStarted = true;
		for (new x = 1; x <= MaxClients; x++)
		{
			if (IsClientInGame(x) && IsPlayerAlive(x))
			{
				decl cTeam;
				cTeam = GetClientTeam(x);
				switch (cTeam)
				{
					case HUMAN, ZOMBIE:
					{
						OpenClassMenu(x, cTeam);
					} 
				}
			}
		}
		RoundTime = GetGameTime();
		hRoundTimer = INVALID_HANDLE;
		KillTimer(timer);
	}
}

public Action:Dissolve(Handle:timer, any:Client)
{
	if (IsValidEntity(Client) && !IsPlayerAlive(Client))
	{
		DissolveRagdoll(Client);
	}
}

public Action:DecayZombie(Handle:timer, any:rDoll)
{
	if (IsValidEntity(rDoll))
	{
		AcceptEntityInput(rDoll, "Kill");
	}
}

public Action:SetCheatsOff(Handle:timer, any:Client)
{
	SendConVarValue(Client, g_hCheats, "0");
}