SetHumanClass(Client, Class)
{
	switch(Class)
	{
		case MEDIC:
		{
			new String:sMedicWeapons[3][1][64] =
			{	
				{"weapon_supershorty"},
				{"weapon_glock"},
				{"weapon_shovel"}
			};

			SetSpawnWeapons(Client, sMedicWeapons);

			SDKCall(hGiveAmmo, Client, 10, 1, 0);
			
			pDataInt[SKILL1DATA_1][ROUND][Client] = GetRandomInt(2, 3);
			pDataInt[SKILL1DATA_2][ROUND][Client] = GetRandomInt(2, 4);
			
			SetEntProp(Client, Prop_Data, "m_ArmorValue", 25, 1);	
			
			SetClassModel(Client, MEDIC, HUMAN);
			
			switch (GetRandomInt(1, 2))
			{
				case 1:
				{
					PlaySoundToAll(SND_ARMOR1, Client, 0.8, 106);
					PlaySoundToAll(SND_MEDIC_OKAY, Client, 0.8, 106);
				}

				case 2:
				{
					PlaySoundToAll(SND_ARMOR2, Client, 0.8, 106);
					PlaySoundToAll(SND_MEDIC_HELP, Client, 0.8, 106);
				}	
			}	
		}
		
		case DEMOLITIONIST:
		{
			new String:sDemolitionWeapons[3][1][64] =
			{	
				{"weapon_supershorty"},
				{"weapon_glock18c"},
				{"weapon_sledgehammer"}
			};

			SetSpawnWeapons(Client, sDemolitionWeapons);
			
			SDKCall(hGiveAmmo, Client, 10, 1, 0);
			
			pDataInt[SKILL1DATA_1][ROUND][Client] = GetRandomInt(3, 6);
			//pDataInt[SKILL1DATA_2][ROUND][Client] = GetRandomInt(1, 3);
			pDataInt[SKILL1DATA_3][ROUND][Client] = GetRandomInt(2, 3);
			
			SetEntProp(Client, Prop_Data, "m_ArmorValue", 35, 1);
			
			SetClassModel(Client, DEMOLITIONIST, HUMAN);

			switch (GetRandomInt(1, 2))
			{
				case 1:
				{
					PlaySoundToAll(SND_ARMOR1, Client, 0.9, 90);
					PlaySoundToAll(SND_DEMOLITIONIST_COMEON, Client, 0.9, 90);
				}
				case 2:
				{
					PlaySoundToAll(SND_ARMOR2, Client, 0.9, 90);
					PlaySoundToAll(SND_DEMOLITIONIST_BREAK, Client, 0.9, 90);
				}
			}
		}
									
		case CONSTRUCTOR:
		{
			new String:sConstructorWeapons[3][1][64] =
			{	
				{"weapon_supershorty"},
				{"weapon_usp"},
				{"weapon_hammer"}
			};

			SetSpawnWeapons(Client, sConstructorWeapons);
			
			SDKCall(hGiveAmmo, Client, 10, 1, 0);
	
			pDataFloat[FLOAT_SKILL_1_DATA_2][ROUND][Client] = CONSTRUCTOR_MAX_WT;
	
			SetEntProp(Client, Prop_Data, "m_ArmorValue", 15, 1);
			
			SetClassModel(Client, CONSTRUCTOR, HUMAN);
			
			switch (GetRandomInt(1, 2))
			{
				case 1:
				{
					PlaySoundToAll(SND_ARMOR1, Client, 0.9, 90);
					PlaySoundToAll(SND_CONSTRUCTOR, Client, 0.9, 90);
				}

				case 2:
				{
					PlaySoundToAll(SND_ARMOR2, Client, 0.9, 90);
					PlaySoundToAll(SND_CONSTRUCTOR, Client, 0.9, 90);
				}
			}
		}
				
		case SHARPSHOOTER:
		{
			new String:sSharpshooterWeapons[3][1][64] =
			{	
				{"weapon_revolver"},
				{"weapon_usp"},
				{"weapon_machete"}
			};

			SetSpawnWeapons(Client, sSharpshooterWeapons);
			
			SDKCall(hGiveAmmo, Client, 10, 1, 0);
			SDKCall(hGiveAmmo, Client, 6, 2, 0);
			
			SetEntProp(Client, Prop_Data, "m_ArmorValue", 10, 1);
			pDataInt[SKILL1DATA_1][ROUND][Client] = GetRandomInt(3, 4);

			PlaySoundToAll(SND_SHARPSHOOTER, Client, 0.9, 95);

			switch (GetRandomInt(1, 2))
			{
				case 1:
				{
					PlaySoundToAll(SND_ARMOR1, Client, 0.9, 90);
				}
				case 2:
				{
					PlaySoundToAll(SND_ARMOR2, Client, 0.9, 90);
				}
			}
		}
		case BIOCHEMIST:
		{
			new String:sBioChemistWeapons[3][1][64] =
			{	
				{"weapon_usp"},
				{"weapon_glock"},
				{"weapon_plank"}
			};

			SetSpawnWeapons(Client, sBioChemistWeapons);
			
			SDKCall(hGiveAmmo, Client, 25, 1, 0);
	
			pDataInt[SKILL1DATA_1][ROUND][Client] = GetRandomInt(18, 28);
			pDataInt[SKILL2DATA_1][ROUND][Client] = GetRandomInt(1, 3);
			
			SetEntityModel(Client, MDL_SCIENTIST);
					
			PlaySoundToAll(SND_BIOCHEMIST, Client, 0.9, 105);
		}
	}
	
	pDataInt[CLASS][ROUND][Client] = Class;
	pDataInt[CLASS_TEAM][ROUND][Client] = HUMAN;
	
	if (pDataHandle[TIMER_RESTRICT][ROUND][Client] == INVALID_HANDLE)
	{
		pDataHandle[TIMER_RESTRICT][ROUND][Client] = CreateTimer(1.0, Restrict, Client, TIMER_REPEAT);
	}
			
	pDataInt[LAST_CLASS][MAP][Client] = Class;
	
	SetDefaultSpeed(Client, Class, HUMAN);
	SetDefaultHealth(Client, Class, HUMAN);
	
	iClassLimitCurrent[Class][HUMAN - 2]++;
}

SetZombieClass(Client, Class)
{
	switch(Class)
	{
		case HULKER:
		{
			SetEntityRenderColor(Client, 150, 90, 90, 255);
			
			PlaySoundToAll(SND_HULKER_GROAN, Client, 1.0, 100);
		}
									
		case SHIFTER:
		{
			SetClientOverlay(Client, "debug/yuv");
			SetEntityRenderMode(Client, RENDER_TRANSALPHA);
			SetEntityRenderColor(Client, 20, 20, 20, 55);

			PlaySoundToAll(SND_SHIFTER_GROAN, Client, 0.25, 85);
			
			pDataHandle[TIMER_REGEN_OFFSET][ROUND][Client] = CreateTimer(1.0, OffsetNaturalRegen, Client, TIMER_REPEAT);
		}
									
		case LEAPER:
		{
			SetEntityRenderColor(Client, 155, 140, 235, 255);
			
			PlaySoundToAll(SND_LEAPER_GROAN, Client, 0.7, 80);
			
			pDataHandle[TIMER_REGEN_OFFSET][ROUND][Client] = CreateTimer(1.0, OffsetNaturalRegen, Client, TIMER_REPEAT);
		}

		case FULMINATOR:
		{
		}
	}
	
	pDataInt[CLASS][ROUND][Client] = Class;
	pDataInt[CLASS_TEAM][ROUND][Client] = ZOMBIE;
	
	SetDefaultHealth(Client, Class, ZOMBIE);
	SetDefaultSpeed(Client, Class, ZOMBIE);
	
	iClassLimitCurrent[Class][ZOMBIE - 2]++;
}
