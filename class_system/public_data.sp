stock g_Sprite1;
stock g_Sprite2;
stock g_Sprite3;
stock g_Sprite4;
stock g_Sprite5;
stock g_Sprite6;
stock g_Sprite7;
stock g_Sprite8;
stock g_Sprite9;

new g_hActiveWeapon;

new Float:RoundTime;

new bool:RoundStarted = false;

new String:CurrentMap[32];

new Handle:hRoundTimer = INVALID_HANDLE;

new pPlayerProps[256][3];
new hHeldEntities[256][1];
new hHumanRagdolls[256][2];

new Float:pPropsWeight[3][1] =
{
	{0.75}, // Wooden Box
	{1.00}, // Double Wooden Box
	{0.00}	// None
};

new bool:pDataBool[10][1][21] =
{
	{false},	// Skill_1 Bool 1
	{false},	// Skill_2 Bool 1
	{false},	// Is_Bandaged
	{false},	// Is_Holding_Object
	{false},	// Has_Overlay
	{false},	// Is_Carrier
	{false},	// Is_White_Model
	{false},
	{false},
	{false}	
};

new pDataInt[10][2][21] =
{
	{0, -1},	// Class - Last Class
	{0, 0},		// Class Team
	{0, 0},		// MaxHealth
	{0, 0},		// Skill_1 Data 1
	{0, 0},		// Skill_1 Data 2
	{0, 0},		// Skill_1 Data 3
	{0, 0},		// Skill_2 Data 1
	{0, 0},		// Skill_2 Data 2
	{0, 0},		// Last Attacker
	{0, 0}		
};

new Float:pDataFloat[10][1][21] =
{
	{0.0},	// Skill_1 Time
	{0.0},	// Skill_1 Float Data
	{0.0},	// Skill_1 Float Data_2
	{0.0},	// Skill_2 Time
	{0.0},	// Skill_2 Float Data
	{0.0},	// Unstuck Time
	{0.0},
	{0.0},
	{0.0},
	{0.0}
};

new Handle:pDataHandle[10][1][21] =
{
	{INVALID_HANDLE},	// Regen Timer
	{INVALID_HANDLE},	// Regen Offset Timer
	{INVALID_HANDLE},	// **Open Handle**
	{INVALID_HANDLE},	// Skill_1 Timer
	{INVALID_HANDLE},	// Skill_2 Timer
	{INVALID_HANDLE},	// Unstuck Timer
	{INVALID_HANDLE},	// Restrict Timer
	{INVALID_HANDLE},	// Puncture Timer
	{INVALID_HANDLE},	// Holding Object Timer
	{INVALID_HANDLE}
};

new Float:pDataVector[10][3][21] =
{
	{0.0, 0.0, 0.0},	// Spawn Coordinates
	{0.0, 0.0, 0.0},
	{0.0, 0.0, 0.0},
	{0.0, 0.0, 0.0},
	{0.0, 0.0, 0.0},
	{0.0, 0.0, 0.0},
	{0.0, 0.0, 0.0},
	{0.0, 0.0, 0.0},
	{0.0, 0.0, 0.0},
	{0.0, 0.0, 0.0}
};

new String:sClassName[5][2][32] =
{
	{"Medic", "Hulker"},
	{"Demolitionist", "Shifter"},
	{"Constructor", "Leaper"},
	{"Sharpshooter", "Fulminater"},
	{"Bio Chemist", "NONE"}
};

new Float:cBaseSpeed[10][2] =
{
	{1.00, 0.65},
	{1.00, 0.80},
	{1.00, 0.90},
	{1.00, 0.55},
	{0.80, 0.00},
	{0.00, 0.00},
	{0.00, 0.00},
	{0.00, 0.00},
	{0.00, 0.00},
	{0.00, 0.00}
};

new cBaseHealth[10][2] =
{	{100, 380},
	{100, 100},
	{100, 185},
	{100, 475},
	{100, 200},
	{100, 200},
	{100, 200},
	{100, 200},
	{100, 200},
	{100, 200}
};

new iClassLimit[6][2] =
{
	{3, 2},
	{2, 1},
	{2, 2},
	{1, 0},
	{1, 0},
	{0, 0}
};

new iClassLimitCurrent[5][2] =
{
	{0, 0},
	{0, 0},
	{0, 0},
	{0, 0},
	{0, 0}
};
new String:sRestricted[5][5][32] =
{
	{"weapon_ak47", "weapon_870", "weapon_revolver", "NONE", "NONE"},						// Medic
	{"weapon_mp5", "weapon_revolver", "NONE", "NONE", "NONE"},								// Demolition
	{"weapon_ak47", "weapon_mp5", "weapon_revolver", "NONE", "NONE"},						// Constructor
	{"weapon_ak47", "weapon_mp5", "weapon_870", "weapon_supershorty", "NONE"},				// Sharpshooter
	{"weapon_ak47", "weapon_revolver", "weapon_870", "weapon_supershorty", "weapon_mp5"}	// Bio Chemist
};

new String:sWeight[25][32] =
{
	{"weapon_ak47"},
	{"weapon_mp5"},
	{"weapon_870"},
	{"weapon_supershotty"},
	{"weapon_revolver"},
	{"weapon_glock"},
	{"weapon_glock18c"},
	{"weapon_usp"},
	{"weapon_ppk"},
	{"weapon_frag"},
	{"weapon_keyboard"},
	{"weapon_plank"},
	{"weapon_crowbar"},
	{"weapon_machete"},
	{"weapon_axe"},
	{"weapon_chair"},
	{"weapon_fryingpan"},
	{"weapon_golf"},
	{"weapon_hammer"},
	{"weapon_pipe"},
	{"weapon_pot"},
	{"weapon_shovel"},
	{"weapon_spanner"},
	{"weapon_sledgehammer"},
	{"weapon_tireiron"}
};

new Float:fWeight[25][1] =
{
	{27.00},
	{22.45},
	{23.83},
	{13.19},
	{15.74},
	{11.22},
	{11.22},
	{10.80},
	{9.12},
	{3.40},
	{4.25},
	{0.0},
	{0.0},
	{5.95},
	{9.35},
	{9.35},
	{8.5},
	{4.25},
	{7.65},
	{10.2},
	{5.95},
	{6.4},
	{6.8},
	{14.45},
	{8.5}
};

new const BOMB_WHITE[4] = {255, 255, 255, 255};
new const BOMB_GREEN[4] = {20, 120, 20, 255};