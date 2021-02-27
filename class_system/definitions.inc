#define COMPARE_MATCH					0
#define PARALLEL_SIZE					10

#define NONE							0

#define PROP_NONE						-1
#define CLASS_NONE						-1

#define SPECTATOR						1
#define HUMAN							2
#define ZOMBIE							3
#define OBSERVER						4

#define MEDIC							0
#define	DEMOLITIONIST					1
#define CONSTRUCTOR						2
#define SHARPSHOOTER					3
#define BIOCHEMIST						4

#define HULKER							0
#define SHIFTER							1
#define LEAPER							2
#define FULMINATOR						3

#define CONSTRUCTOR_MAX_WT				3.5
#define WEAPON_COUNT					25

#define PROP_ENTITY						0
#define PROP_OWNER						1
#define	PROP_WEIGHT						2

#define PROP_WOODEN_BOX					0
#define PROP_DOUBLE_WOODEN_BOX			1
#define PROP_WOODEN_PALLET				2

#define MEDIC_MAX_MEDKITS				4
#define MEDIC_MAX_PAINKILLERS			6

#define CONSTRUCTOR_PROP				27001
#define IKAR_BOMB						27002
#define ACID_BOMB						27003

#define MINE_TRIP						0
#define MINE_REMOTE						1
#define MINE_PROXIMITY					2

#define LAST_CLASS						0

#define ROUND							0
#define MAP								1

#define MAX_PROPS						256

#define SKILL_1							1
#define SKILL_2							2

#define CLASS							0
#define CLASS_TEAM						1
#define	MAXHEALTH						2
#define SKILL1DATA_1					3
#define SKILL1DATA_2					4
#define SKILL1DATA_3					5
#define SKILL2DATA_1					6
#define SKILL2DATA_2					7
#define LAST_ATTACKER					8

#define SKILL1BOOL_1					0
#define SKILL2BOOL_1					1
#define IS_BANDAGED						2
#define IS_HOLDING_OBJECT				3
#define HAS_OVERLAY						4
#define IS_CARRIER						5
#define IS_WHITE_MODEL					6

#define FLOAT_SKILL_1_TIME				0
#define FLOAT_SKILL_1_DATA				1
#define FLOAT_SKILL_1_DATA_2			2
#define FLOAT_SKILL_2_TIME				3
#define FLOAT_SKILL_2_DATA				4
#define FLOAT_UNSTUCK_TIME				5
#define FLOAT_MENU_TIME					6
#define TIMER_REGEN						0
#define TIMER_REGEN_OFFSET				1
#define OPEN_TIMER						2
#define TIMER_SKILL_1					3
#define TIMER_SKILL_2					4
#define TIMER_UNSTUCK					5
#define TIMER_RESTRICT					6
#define TIMER_PUNCTURE					7
#define TIMER_HOLDING_OBJECT			8

#define VECTOR_SPAWN					0

#define NO_FADE							0
#define FADE_IN							1
#define FADE_OUT						2
#define FADE_OUT_STAY					10

#define SND_ARMOR1						"Items/Armor/Armor_Full-01.wav"
#define SND_ARMOR2						"Items/Armor/Armor_Full-02.wav"
#define SND_MEDIC_OKAY					"Humans/HumanMale-01/CommandMenu/StatusReport/StatusReport-03.wav"
#define SND_MEDIC_HELP					"Humans/HumanMale-01/CommandMenu/StatusReport/StatusReport-05.wav"
#define SND_DEMOLITIONIST_COMEON		"Humans/HumanMale-01/Taunts/Taunt-07.wav"
#define SND_DEMOLITIONIST_BREAK			"Humans/HumanMale-01/CommandMenu/Anger/Anger-01.wav"
#define SND_CONSTRUCTOR					"Humans/HumanMale-01/CommandMenu/Acknowledge/Acknowledge-03.wav"
#define SND_SHARPSHOOTER				"Humans/HumanMale-01/Taunts/Taunt-09.wav"
#define SND_BIOCHEMIST					"Humans/HumanMale-01/CommandMenu/PositiveStatus/PostitiveStatus-07.wav"
#define SND_HULKER_GROAN				"Zombies/Z_Male1Speech/NoAction/ZMale1_NoUse-03.wav"
#define SND_SHIFTER_GROAN				"ambient/creatures/town_scared_breathing1.wav"
#define SND_SHIFTER_SHADOWS				"ambient/wind/wind_snippet2.wav"
#define SND_LEAPER_GROAN				"Zombies/Z_Male1Speech/NoAction/ZMale1_NoUse-01.wav"
#define SND_LEAPER_PUNCTURE				"npc/stalker/go_alert2a.wav"
#define SND_MINE						"weapons/slam/mine_mode.wav"

#define MDL_LASER						"sprites/laser.vmt"
#define MDL_MINE						"models/weapons/w_slam.mdl"
#define MDL_IKARBOMB					"models/props_junk/glassjug01.mdl"
#define MDL_ACIDBOMB					"models/props_junk/glassbottle01a.mdl"

#define MDL_SCIENTIST					"models/kleiner.mdl"
#define MDL_DEMOLITIONIST				"models/humans/custom_c/h_demo.mdl"

#define WHITE_MODEL						"models/survivors/survivor1/survivor1.mdl"
#define BLACK_MODEL						"models/survivors/survivor2/survivor2.mdl"
#define CARRIER_MODEL					"models/zombies/zombie0/zombie0.mdl"

#define PROP_WOODEN_BOX_MODEL			"models/props_junk/wood_crate001a.mdl"
#define PROP_DOUBLE_WOODEN_BOX_MODEL	"models/props_junk/wood_crate002a.mdl"
#define PROP_WOODEN_PALLET_MODEL		"models/props_junk/wood_pallet001a.mdl"

stock AddFolderToDownloadTable(const String:Directory[], bool:recursive=false)
{    
	decl String:FileName[64], String:Path[512];
	new Handle:Dir = OpenDirectory(Directory), FileType:Type;
	while(ReadDirEntry(Dir, FileName, sizeof(FileName), Type))
	{
		if(Type == FileType_Directory && recursive)
		{
			FormatEx(Path, sizeof(Path), "%s/%s", Directory, FileName);
			AddFolderToDownloadTable(FileName); 
			continue;
		} 
		
		if (Type != FileType_File)
		{
			continue;
		}
		
		FormatEx(Path, sizeof(Path), "%s/%s", Directory, FileName);
		AddFileToDownloadsTable(Path);
	} 
	return;
}