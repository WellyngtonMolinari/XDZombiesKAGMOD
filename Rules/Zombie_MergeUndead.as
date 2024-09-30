// Zombie Fortress undead merging
// primitive script that 'merges' zombies together when there is too many on the map

#define SERVER_ONLY;

const int merge_seconds = 5;
u16 merge_zombies = 300;

void onInit(CRules@ this)
{
	ConfigFile cfg;
	if (cfg.loadFile("Zombie_Vars.cfg"))
	{
		merge_zombies = cfg.exists("merge_zombies") ? cfg.read_u16("merge_zombies") : 400;
		if (merge_zombies == u16(-1))
		{
			this.RemoveScript(getCurrentScriptName());
		}
	}
}

void onTick(CRules@ this)
{
	if (getGameTime() % (30*merge_seconds) != 0) return;

	if (this.get_u16("undead count") < merge_zombies) return;

	CBlob@[] skeletons; getBlobsByName("skeleton", @skeletons);
	CBlob@[] zombies;   getBlobsByName("zombie", @zombies);
	CBlob@[] zombie_knights;   getBlobsByName("zombieknight", @zombie_knights);
	u16 skeles = skeletons.length;
	u16 zombs = zombies.length;
	u16 zks = zombie_knights.length;

	print(skeles + " skeletons...");
	print(zombs + " zombies...");
	print(zks + " zombie knights...");
	u16 skele_idx = 0;
	u16 zomb_idx = 0;
	u16 zk_idx = 0;
	for (u8 iter = 0; iter < 15; iter++) 
	{
		u16 total_count = this.get_u16("undead count");
		if ((skeles < 4 && zombs < 2 && zks < 25) || total_count < merge_zombies) 
		{
			print("Terminating merge...");
			break;
		}

		if (skeles > zombs && skeles > 3 && total_count - 4 > merge_zombies)
		{
			Vec2f pos = skeletons[skele_idx].getPosition();

			for (u8 i = 0; i < 4; i++)
			{
				CBlob@ skeleton = skeletons[skele_idx];
				skeleton.SetPlayerOfRecentDamage(null, 1.0f);
				skeleton.server_Die();
				skele_idx += 1;
				skeles -= 1;
			}
			server_CreateBlob("wraith", -1, pos);
		}
		else if (zombs > zks && zombs > 1 && total_count - 2 > merge_zombies)
		{
			Vec2f pos = zombies[zomb_idx].getPosition();

			for (u8 i = 0; i < 2; i++)
			{
				CBlob@ zombie = zombies[zomb_idx];
				zombie.SetPlayerOfRecentDamage(null, 1.0f);
				zombie.server_Die();
				zomb_idx += 1;
				zombs -= 1;
			}
			server_CreateBlob("zombieknight", -1, pos);
		}
		else if (zks > 25 && total_count - 25 > merge_zombies) 
		{
			Vec2f pos = zombie_knights[zk_idx].getPosition();
			for (u8 i = 0; i < 25; i++)
			{
				CBlob@ zombie_knight = zombie_knights[zk_idx];
				zombie_knight.SetPlayerOfRecentDamage(null, 1.0f);
				zombie_knight.server_Die();
				zk_idx += 1;
				zks -= 1;
			}
			server_CreateBlob("skelepede", -1, pos);
		}
	}

	print(skele_idx + " skeletons consumed...");
	print(zomb_idx + " zombies consumed...");
	print(zk_idx + " zombie knights consumed...");
}
