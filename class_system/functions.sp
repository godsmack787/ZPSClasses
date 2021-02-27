HoldProp(Client, Entity)
{
	decl Float:Start[3], Float:Angle[3], Float:End[3];
	
	GetClientEyePosition(Client, Start);
	GetClientEyeAngles(Client, Angle);
	GetAngleVectors(Angle, End, NULL_VECTOR, NULL_VECTOR);
	
	for (new x = 0; x < 3; x++)
	{
		Start[x]=Start[x]+End[x]*30;
		End[x]=Start[x]+End[x]*30;
	}

	TR_TraceRayFilter(Start, End, MASK_SOLID, RayType_EndPoint, FilterSelf, Entity);
	TR_GetEndPosition(End, INVALID_HANDLE);

	Angle[0] = 90.0;
	Angle[2] = 0.0;
	
	TeleportEntity(Entity, End, Angle, NULL_VECTOR);
}

SpawnProp(Client, String:sModel2[128], Health, Prop, zMod)
{
	decl Float:fWeight2, Float:Start[3], Float:Angle[3], Float:End[3], Float:Normal[3], String:Temp[64], Entity;
	
	fWeight2 = pPropsWeight[Prop][ROUND];
	
	GetClientEyePosition( Client, Start );
	GetClientEyeAngles( Client, Angle );
	GetAngleVectors(Angle, End, NULL_VECTOR, NULL_VECTOR);
	NormalizeVector(End, End);
	
	for (new x = 0; x < 3; x++)
	{
		Start[x]=Start[x]+End[x]*40;
		End[x]=Start[x]+End[x]*40;
	}
	
	TR_TraceRayFilter(Start, End, MASK_SOLID, RayType_EndPoint, FilterProp, 0);
	
	TR_GetEndPosition(End, INVALID_HANDLE);
	TR_GetPlaneNormal(INVALID_HANDLE, Normal);
	GetVectorAngles(Normal, Normal);
		
	Normal[1] = Angle[1];
	
	if (Angle[0] < 100.0)
	{
		End[2] += zMod;
	}
	else if (Angle[0] < 330.0)
	{
		End[2] -= zMod;
	}
	
	Entity = CreateEntityByName("prop_physics");

	for (new i = NONE; i < MAX_PROPS; i++)
	{
		if (pPlayerProps[i][PROP_ENTITY] == NONE)
		{
			if ((fWeight2 + pDataFloat[FLOAT_SKILL_1_DATA][ROUND][Client]) <= pDataFloat[FLOAT_SKILL_1_DATA_2][ROUND][Client])
			{
				pPlayerProps[i][PROP_ENTITY] = Entity;
				pPlayerProps[i][PROP_OWNER] = Client;
				pPlayerProps[i][PROP_WEIGHT] = Prop;
				
				pDataInt[SKILL1DATA_1][ROUND][Client] = Entity;
				pDataFloat[FLOAT_SKILL_1_DATA][ROUND][Client] += fWeight2;
				pDataFloat[FLOAT_SKILL_1_TIME][ROUND][Client] = GetGameTime();
				
				SetEntityModel(Entity, sModel2);
				DispatchKeyValue(Entity, "StartDisabled", "false");
				
				IntToString(CONSTRUCTOR_PROP, Temp, sizeof(Temp));
				
				DispatchKeyValue(Entity, "targetname", Temp);
				DispatchKeyValue(Entity, "physicsmode", "1");
				DispatchKeyValueFloat(Entity, "massScale", 3.2);
				DispatchSpawn(Entity);
				SetEntProp(Entity, Prop_Data, "m_takedamage", 2);
				SetEntProp(Entity, Prop_Data, "m_iHealth", Health);			
				SetEntityMoveType(Entity, MOVETYPE_VPHYSICS);
				TeleportEntity(Entity, End, Normal, NULL_VECTOR);
			}
			else
			{
				PrintToChat(Client, "That object is too heavy.");
			}
			break;
		}
	}
}

ClearSingleProp(PropIndex)
{
	pPlayerProps[PropIndex][PROP_ENTITY] = NONE;
	pPlayerProps[PropIndex][PROP_OWNER] = NONE;
	pPlayerProps[PropIndex][PROP_WEIGHT] = NONE;
}

bool:CheckSightPath(Client, Target)
{
	decl Float:Start[3], Float:Angle[3];
	
	GetClientEyePosition(Client, Start);
	GetClientEyeAngles( Client, Angle );

	TR_TraceRayFilter(Start, Angle, MASK_PLAYERSOLID, RayType_Infinite, FilterSelf, Client);
	
	if (TR_DidHit(INVALID_HANDLE))
	{
		if (TR_GetEntityIndex(INVALID_HANDLE) == Target)
		{
			return true;
		}
	}

	return false;
}

bool:CheckDistance(Entity, Target, MaxDistance)
{
	if (GetVectorDistance(GetEntityOrigin(Entity), GetEntityOrigin(Target)) <= MaxDistance)
	{
		return true;
	}

	return false;
}

bool:IsPlayer(Entity)
{
	if ((Entity > MaxClients || Entity < 1)) return false;
	
	return true;
}

HandleChemistBombs(Entity, Owner, Type)
{
	switch (Type)
	{
		case IKAR_BOMB:
		{
			decl Float:EntityOrigin[3], String:Temp[64];

			GetEntPropVector(Entity, Prop_Send, "m_vecOrigin", EntityOrigin);
			TE_SetupEnergySplash(EntityOrigin, EntityOrigin, true);
			TE_SendToAll();
											
			Format(Temp, sizeof(Temp), "weapons/underwater_explode%i.wav", GetRandomInt(3, 4));
			PlaySoundToAll(Temp, Entity, 1.0, 125);
						
			TE_SetupBeamRingPoint(EntityOrigin, 1.0, 130.0, g_Sprite1, g_Sprite1, 0, 20, 0.6, 22.0, 0.1, BOMB_WHITE, 10, 0);
			TE_SendToAll();
											
			for (new o = 1; o <= MaxClients; o++)
			{
				if (IsClientInGame(o) && IsPlayerAlive(o) && GetClientTeam(o) == ZOMBIE)
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
								SetLastAttacker(o, Owner);
								KillPlayer(o);
								DissolveRagdoll(o);
							}
						}
					}
				}
			}
			
			AcceptEntityInput(Entity, "kill");
		}
		case ACID_BOMB:
		{
			decl Float:EntityOrigin[3], String:Temp[64];

			GetEntPropVector(Entity, Prop_Send, "m_vecOrigin", EntityOrigin);
										
			Format(Temp, sizeof(Temp), "weapons/underwater_explode%i.wav", GetRandomInt(3, 4));
			PlaySoundToAll(Temp, Entity, 0.5, 175);
						
			TE_SetupBeamRingPoint(EntityOrigin, 1.0, 180.0, g_Sprite1, g_Sprite1, 0, 20, 0.7, 15.0, 0.1, BOMB_GREEN, 15, 0);
			TE_SendToAll();
											
			for (new o = 1; o <= MaxClients; o++)
			{
				if (IsClientInGame(o) && IsPlayerAlive(o) && (GetClientTeam(o) == ZOMBIE || GetConVarInt(g_hFriendlyFire)))
				{
					if (CheckDistance(o, Entity, 185))
					{
						decl Float:cPosition[3];
						GetClientEyePosition(o, cPosition);
														
						TR_TraceRayFilter(EntityOrigin, cPosition, MASK_PLAYERSOLID, RayType_EndPoint, FilterNonPlayer, o);
														
						if (TR_DidHit(INVALID_HANDLE))
						{
							if (TR_GetEntityIndex(INVALID_HANDLE) == o)
							{
								SetLastAttacker(o, Owner);
								DamagePlayer(o, GetRandomInt(75, 125), true);
							}
						}
					}
				}
			}
			
			AcceptEntityInput(Entity, "kill");
		}
	}
}

KillPlayer(Client)
{
	if (IsClientInGame(Client) && IsPlayerAlive(Client))
	{
		decl String:dName[32], Entity;
		Format(dName, sizeof(dName), "pd_%d", Client);
 
		Entity = CreateEntityByName("env_entity_dissolver");
		
		if (Entity)
		{
			DispatchKeyValue(Client, "targetname", dName);
			DispatchKeyValue(Entity, "target", dName);
			
			AcceptEntityInput(Entity, "Dissolve");
			AcceptEntityInput(Entity, "kill");
		}
	}
}

DamagePlayer(Client, Amount, bool:dSound)
{
	decl Health;
	Health = GetClientHealth(Client);
	
	if ((Health - Amount) <= NONE)
	{
		SDKCall(hDamageEffect, Client, 0.0, 1);
		KillPlayer(Client);
	}
	else
	{
		SDKCall(hDamageEffect, Client, 0.0, 1);
		
		if (dSound)
		{
			SDKCall(hDamageEffect, Client, 0.0, 2);
		}
		
		SetEntityHealth(Client, (Health - Amount));
	}
}

SetSpawnWeapons(Client, String:sWep[3][1][64])
{
	decl Weapon;
	
	DropAllWeapons(Client);	

	for (new i = NONE; i < 3 ; i++)
	{
		Weapon = CreateEntityByName(sWep[i][ROUND]);
		if (IsValidEdict(Weapon))
		{
			DispatchSpawn(Weapon);
			SDKCall(hPickupItem, Client, Weapon);
			if (i == NONE)
			{
				SDKCall(hSwitchWeapon, Client, Weapon, NONE, NONE);
			}
		}
	}
}

SpawnSkillItem(Client, String:iName[64], String:sModel[128], Float:Position[3], Float:Angles[3], Float:Velocity[3], String:Color[32])
{
	decl Entity;
	for (new i = NONE; i < MAX_PROPS; i++)
	{
		if (pPlayerProps[i][PROP_ENTITY] == NONE)
		{		
			Entity = CreateEntityByName(iName);
			if (IsValidEdict(Entity))
			{
				DispatchKeyValue(Entity, "rendercolor", Color);
				
				if (sModel[0] != 0)
				{
					SetEntityModel(Entity, sModel);
				}
				
				pPlayerProps[i][PROP_ENTITY] = Entity;
				pPlayerProps[i][PROP_OWNER] = Client;	
				
				DispatchSpawn(Entity);
				TeleportEntity(Entity, Position, Angles, Velocity);
			}			
			break;
		}
	}
	
	return Entity;
}

Float:GetWeight(String:wName[32])
{
	for (new i = NONE; i < WEAPON_COUNT; i++)
	{
		switch (strcmp(wName,sWeight[i][ROUND],false))
		{
			case COMPARE_MATCH:
			{
				return fWeight[i][ROUND];
			}
		}
	}
	
	return 0.0;
}

DropAllWeapons(Client)
{
	for (new r = 1; r <= 5; r++)
	{
		DropWeapon(Client, r);
	} 
}

DropWeapon(Client, Weapon, bool:IsSlot = true)
{
	decl Entity;
	
	switch (IsSlot)
	{
		case false:
		{
			Entity = Weapon;
		}
		case true:
		{
			Entity = GetPlayerWeaponSlot(Client, Weapon);
		}
	}
	
	if (IsValidEntity(Entity))
	{
		if (!CompareEntityClass(Entity, "worldspawn"))
		{
			decl Float:Position[3], String:sName[32];

			GetEdictClassname(Entity, sName, sizeof(sName));
			GetClientEyePosition(Client, Position);
				
			SDKCall(hDropWeapon, Client, Entity, Position, Position);
			SDKCall(hRemoveWeight, Client, GetWeight(sName));
		}
	}
}

DissolveRagdoll(Client)
{
	new rDoll = GetEntPropEnt(Client, Prop_Send, "m_hRagdoll");
	
	if (rDoll > 0)
	{
		decl String:dName[32];
		Format(dName, sizeof(dName), "dis_%d", Client);
 
		decl Entity;
		Entity = CreateEntityByName("env_entity_dissolver");
		
		if (Entity)
		{
			DispatchKeyValue(rDoll, "targetname", dName);
			DispatchKeyValue(Entity, "dissolvetype", "2");
			DispatchKeyValue(Entity, "target", dName);
			AcceptEntityInput(Entity, "Dissolve");
			AcceptEntityInput(Entity, "kill");
		}
	}
}

stock HandleHumanRagdoll(Client, Killer)
{
	decl OldRagdoll, Entity, String:pModel[128], Float:pOrigin[3], Float:pAngles[3], Float:pVelocity[3], Float:kAngles[3];
	
	OldRagdoll = GetEntPropEnt(Client, Prop_Send, "m_hRagdoll");
	
	if (OldRagdoll > 0)
	{
		RemoveEdict(OldRagdoll);
	}

	SetEntPropEnt(Client, Prop_Send, "m_hRagdoll", -1);

	GetClientModel(Client, pModel, sizeof(pModel));
	GetClientEyeAngles(Client, pAngles);
	GetClientEyeAngles(Killer, kAngles);
	GetClientEyePosition(Client, pOrigin);
	GetAngleVectors(kAngles, pVelocity, NULL_VECTOR, NULL_VECTOR);
	
	pOrigin[2] -= 30;
									
	for (new x = 0; x < 3; x++)
	{
		pVelocity[x] = pVelocity[x]*2000;
	}
	
	Entity = CreateEntityByName("prop_ragdoll");
	SetEntityModel(Entity, pModel);
	DispatchKeyValue(Entity, "spawnflags", "8196");
	DispatchKeyValue(Entity, "rendercolor", "225 225 255");
	DispatchSpawn(Entity);
	TeleportEntity(Entity, pOrigin, pAngles, pVelocity);
	
	AddRagdoll(Entity);
}

Bleed(Entity, Flags, cTeam, bool:IsRandom, Float:zMod = 0.0)
{
	decl String:sAngles[64];
	decl Blood, String:sFlags[16];
	
	Blood = CreateEntityByName("env_blood");
	
	switch (IsValidEdict(Blood))
	{
		case true:
		{
			DispatchSpawn(Blood);
		
			switch (cTeam) 
			{
				case HUMAN:
				{
					DispatchKeyValue(Blood, "color", "0");
				}
				case ZOMBIE:
				{
					DispatchKeyValue(Blood, "color", "1");
				}
			}
			
			DispatchKeyValue(Blood, "amount", "5000");
			
			IntToString(Flags, sFlags, sizeof(sFlags)) 	;
			DispatchKeyValue(Blood, "spawnflags", sFlags);
			
			switch (IsRandom)
			{
				case false:
				{
					decl Float:fOrigin[3];
					fOrigin = GetEntityOrigin(Entity);
					fOrigin[2] += zMod;
					TeleportEntity(Blood, fOrigin, NULL_VECTOR, NULL_VECTOR);
				}
				case true:
				{
					Format(sAngles, sizeof(sAngles), "%f %f %f", GetRandomFloat(-320.0, 320.0), GetRandomFloat(-320.0, 320.0), -(120.0));
					DispatchKeyValue(Blood, "spraydir", sAngles);	
				}
			}


			AcceptEntityInput(Blood, "EmitBlood", Entity);
			AcceptEntityInput(Blood, "Kill");
		}
	}
}

any:GetEntityOrigin(Entity)
{
	decl Float:TargetOrigin[3];
				
	switch (IsPlayer(Entity))
	{
		case true:
		{
			GetClientAbsOrigin(Entity, TargetOrigin);
		}
		case false:
		{
			GetEntPropVector(Entity, Prop_Send, "m_vecOrigin", TargetOrigin);
		}
	}
	
	return TargetOrigin;
}

SetClientOverlay(Client, String:sOverlay[128])
{
	decl String:Temp[128];
	Format(Temp, sizeof(Temp), "r_screenoverlay %s", sOverlay);
	
	SendConVarValue(Client, g_hCheats, "1");
	ClientCommand(Client, Temp);
	CreateTimer(0.2, SetCheatsOff, Client);
}

RemoveClientOverlay(Client)
{
	SendConVarValue(Client, g_hCheats, "1");
	ClientCommand(Client, "r_screenoverlay 0");
	CreateTimer(0.2, SetCheatsOff, Client);
} 

bool:CompareEntityClass(Entity, String:sName[32])
{
	if (Entity > 0)
	{
		decl String:iName[64];
		GetEdictClassname(Entity, iName, sizeof(iName));
		
		switch(strcmp(iName, sName, false))
		{
			case COMPARE_MATCH:
			{
				return true;
			}
		}
	}

	return false;
}

any:ConvertFloatToText(Float:fValue)
{
	decl String:sValue[16];
	FloatToString(fValue, sValue, sizeof(sValue));
	SplitString(sValue, ".", sValue, sizeof(sValue));
	
	return sValue;
}

stock PlaySoundToAll(String:Sound[], Client, Float:Volume, Pitch)
{
	EmitSoundToAll(Sound, Client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, Volume, Pitch, Client, NULL_VECTOR, NULL_VECTOR, true, 0.0);
}

stock PlaySoundToClient(String:Sound[], Client, Float:Volume, Pitch)
{
	EmitSoundToClient(Client, Sound, Client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, Volume, Pitch, Client, NULL_VECTOR, NULL_VECTOR, true, 0.0);
}

stock FindResourceEntity()
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