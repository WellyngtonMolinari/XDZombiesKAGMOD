// CommonBuilderBlocks.as

//////////////////////////////////////
// Builder menu documentation
//////////////////////////////////////

// To add a new page;

// 1) initialize a new BuildBlock array,
// example:
// BuildBlock[] my_page;
// blocks.push_back(my_page);

// 2)
// Add a new string to PAGE_NAME in
// BuilderInventory.as
// this will be what you see in the caption
// box below the menu

// 3)
// Extend BuilderPageIcons.png with your new
// page icon, do note, frame index is the same
// as array index

// To add new blocks to a page, push_back
// in the desired order to the desired page
// example:
// BuildBlock b(0, "name", "icon", "description");
// blocks[3].push_back(b);

#include "BuildBlock.as"
#include "Requirements.as"
#include "Costs.as"
#include "TeamIconToken.as"
#include "CustomTiles.as"
#include "Zombie_Translation.as"

const string blocks_property = "blocks";
const string inventory_offset = "inventory offset";

void addCommonBuilderBlocks(BuildBlock[][]@ blocks, int team_num = 0, const string&in gamemode_override = "")
{
	InitCosts();
	CRules@ rules = getRules();

	AddIconToken("$iron_block_ZF$", "World.png", Vec2f(8, 8), CMap::tile_iron);
	AddIconToken("$biron_block_ZF$", "World.png", Vec2f(8, 8), CMap::tile_biron);
	AddIconToken("$iron_platform_ZF$", "IronPlatform.png", Vec2f(8, 8), 0);
	AddIconToken("$obstructor_ZF$", "Obstructor.png", Vec2f(8, 8), 8);

	BuildBlock[] page_0;
	blocks.push_back(page_0);
	{
		BuildBlock b(CMap::tile_castle, "stone_block", "$stone_block$", "Stone Block\nBasic building block");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", BuilderCosts::stone_block);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_castle_back, "back_stone_block", "$back_stone_block$", "Back Stone Wall\nExtra support");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", BuilderCosts::back_stone_block);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "stone_door", getTeamIcon("stone_door", "1x1StoneDoor.png", team_num, Vec2f(16, 8)), "Stone Door\nPlace next to walls");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", BuilderCosts::stone_door);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_wood, "wood_block", "$wood_block$", "Wood Block\nCheap block\nwatch out for fire!");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", BuilderCosts::wood_block);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_wood_back, "back_wood_block", "$back_wood_block$", "Back Wood Wall\nCheap extra support");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", BuilderCosts::back_wood_block);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "wooden_door", getTeamIcon("wooden_door", "1x1WoodDoor.png", team_num, Vec2f(16, 8)), "Wooden Door\nPlace next to walls");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", BuilderCosts::wooden_door);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "trap_block", getTeamIcon("trap_block", "TrapBlock.png", team_num), "Trap Block\nOnly enemies can pass");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", BuilderCosts::trap_block);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "bridge", getTeamIcon("bridge", "Bridge.png", team_num), "Trap Bridge\nOnly your team can stand on it");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", BuilderCosts::bridge);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "ladder", "$ladder$", "Ladder\nAnyone can climb it");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", BuilderCosts::ladder);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "wooden_platform", "$wooden_platform$", "Wooden Platform\nOne way platform");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", BuilderCosts::wooden_platform);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "building", "$building$", "Workshop\nStand in an open space\nand tap this button.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", CTFCosts::workshop_wood);
		b.buildOnGround = true;
		b.size.Set(40, 24);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "spikes", "$spikes$", "Spikes\nPlace on Stone Block\nfor Retracting Trap");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", BuilderCosts::spikes);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_iron, "iron_block_ZF", "$iron_block_ZF$", Translate::IronBlock);
		AddRequirement(b.reqs, "blob", "mat_ironingot", "Iron Ingot", 2);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_biron, "biron_block_ZF", "$biron_block_ZF$", Translate::IronBlockBack);
		AddRequirement(b.reqs, "blob", "mat_ironingot", "Iron Ingot", 1);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "iron_door", getTeamIcon("iron_door", "1x1IronDoor.png", team_num, Vec2f(16, 8)), Translate::IronDoor);
		AddRequirement(b.reqs, "blob", "mat_ironingot", "Iron Ingot", 4);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "iron_platform", "$iron_platform_ZF$", Translate::IronPlatform);
		AddRequirement(b.reqs, "blob", "mat_ironingot", "Iron Ingot", 3);
		blocks[0].push_back(b);
	}
	//lantern is useful enough. no real reason to add the fireplace
	/*{
		BuildBlock b(0, "fireplace", "$fireplace$", "Campfire");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 50);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 100);
		b.buildOnGround = true;
		b.size.Set(16, 16);
		blocks[0].push_back(b);
	}*/
	
	BuildBlock[] page_1;
	blocks.push_back(page_1);
	{
		BuildBlock b(0, "windmill", getTeamIcon("windmill", "WindMill.png", team_num, Vec2f(64, 102), 1), Translate::Windmill);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 200);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 250);
		b.buildOnGround = true;
		b.size.Set(32, 72);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "kitchen", getTeamIcon("kitchen", "Kitchen.png", team_num, Vec2f(40, 32)), Translate::Kitchen);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 100);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 100);
		b.buildOnGround = true;
		b.size.Set(40, 32);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "forge", getTeamIcon("forge", "Forge.png", team_num, Vec2f(56, 40)), Translate::Forge);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 300);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 200);
		b.buildOnGround = true;
		b.size.Set(56, 40);
		blocks[1].push_back(b);
	}	
	{
		BuildBlock b(0, "nursery", getTeamIcon("nursery", "Nursery.png", team_num, Vec2f(40, 32)), Translate::Nursery);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood\n", 400);
		AddRequirement(b.reqs, "blob", "seed", "Seed", 1);
		b.buildOnGround = true;
		b.size.Set(40, 32);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "armory", getTeamIcon("armory", "Armory.png", team_num, Vec2f(56, 40)), Translate::Armory);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood\n", 300);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 200);
		b.buildOnGround = true;
		b.size.Set(56, 40);
		blocks[1].push_back(b);
	}
	/*{
		BuildBlock b(0, "library", getTeamIcon("library", "LibraryIcon.png", team_num, Vec2f(32, 19)), Translate::Library);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood\n", 300);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 150);
		AddRequirement(b.reqs, "blob", "mat_gold", "Gold", 50);
		b.buildOnGround = true;
		b.size.Set(56, 40);
		blocks[1].push_back(b);
	}*/

	BuildBlock[] page_2;
	blocks.push_back(page_2);
	{
		BuildBlock b(0, "wire", "$wire$", "Wire");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "elbow", "$elbow$", "Elbow");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "tee", "$tee$", "Tee");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "junction", "$junction$", "Junction");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 20);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "diode", "$diode$", "Diode");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "resistor", "$resistor$", "Resistor");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "inverter", "$inverter$", "Inverter");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 20);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "oscillator", "$oscillator$", "Oscillator");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "transistor", "$transistor$", "Transistor");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "toggle", "$toggle$", "Toggle");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 20);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "randomizer", "$randomizer$", "Randomizer");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 20);
		blocks[2].push_back(b);
	}

	// BuildBlock[] page_3;
	// blocks.push_back(page_3);
	{
		BuildBlock b(0, "lever", "$lever$", "Lever");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "push_button", "$pushbutton$", "Button");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 40);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "coin_slot", "$coin_slot$", "Coin Slot");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 40);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "pressure_plate", "$pressureplate$", "Pressure Plate");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "sensor", "$sensor$", "Motion Sensor");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 40);
		blocks[2].push_back(b);
	}

	// BuildBlock[] page_4;
	// blocks.push_back(page_4);
	{
		BuildBlock b(0, "lamp", "$lamp$", "Lamp");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "emitter", "$emitter$", "Emitter");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "receiver", "$receiver$", "Receiver");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "magazine", "$magazine$", "Magazine");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 20);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "bolter", "$bolter$", "Bolter");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "dispenser", "$dispenser$", "Dispenser");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "obstructor", "$obstructor$", "Obstructor");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 40);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "spiker", "$spiker$", "Spiker");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 40);
		blocks[2].push_back(b);
	}
}

ConfigFile@ openBlockBindingsConfig()
{
	ConfigFile cfg = ConfigFile();
	if (!cfg.loadFile("../Cache/BlockBindings.cfg"))
	{
		// write EmoteBinding.cfg to Cache
		cfg.saveFile("BlockBindings.cfg");

	}

	return cfg;
}

u8 read_block(ConfigFile@ cfg, string name, u8 default_value)
{
	u8 read_val = cfg.read_u8(name, default_value);
	return read_val;
}
