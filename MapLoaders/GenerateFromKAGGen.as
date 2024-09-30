// generates from a KAGGen config
// fileName is "" on client!

#include "LoadPNGMap.as";
#include "MinimapHook.as";

enum BiomeType{
	Forest = 0,
	Desert,
	Meadow,
	Swamp,
	Caves,
};

bool loadMap( CMap@ _map, const string& in filename)
{
	CMap@ map = _map;

	// MiniMap::Initialise();

	if (!getNet().isServer() || filename == "")
	{
		SetupMap(map, 0, 0);
		SetupBackgrounds(map);
		return true;
	}


	Random@ map_random = Random(map.getMapSeed());
	
	Noise@ map_noise = Noise(map_random.Next());
	
	Noise@ material_noise = Noise(map_random.Next());
	
	for(int i = 0;i < Time() % 10000;i++)XORRandom(100);

	//read in our config stuff -----------------------------

	ConfigFile cfg = ConfigFile(filename);

	//boring vars
	s32 width = cfg.read_s32("m_width", m_width);
	s32 height = cfg.read_s32("m_height", m_height);

	s32 MaxLandHeight = cfg.read_s32("land_max_height", 10);
	s32 MinFloorHeight = height-cfg.read_s32("land_min_height", 10);

	int SeaLevel = height/4*3;
	
	//done with vars! --------------------------------

	SetupMap(map, width, height);

	//gen heightmap
	array<int> heightmap(width);
	
	const int BiomeTypes = 4;
	array<int> biome(width);
	//0 - forest/normal (grass/trees/bushes/ect)
	//1 - desert (grain/more gold)
	//2 - meadow (grass/flowers)
	//3 - Swamp (land inline with sea, lots of shallow water)
	//4 - Caves (Big overhead cave/cliff)

	for(int dbl = 0; dbl < 2; dbl += 1){ getNet().server_KeepConnectionsAlive();
		int LastHeight = height*3/5;
		
		int Straight = 4;
		int Crazy = 0;
		int Uphill = 0;
		int Downhill = 0;
		int CliffUp = 0;
		int CliffDown = 0;
		int ToSeaLevel = 0;
		
		int CliffChange = -XORRandom(10);
		
		int LastType = 0;
		
		int CurrentBiome = 2; //Always start with meadow
		int CaveLengthBuffer = 0; //This is to force caves to be above 50 wide
		int SwampDip = 0;
		
		
		int start = width/2;
		int add = 1;
		if(dbl > 0)add = -1;
		for (int x = start; true; x += add){ getNet().server_KeepConnectionsAlive();
			if(x >= width || x < 0)break;
			
			CaveLengthBuffer += 1;
			
			if(Straight == 0 && Crazy == 0 && Uphill == 0 && Downhill == 0 && CliffUp == 0 && CliffDown == 0 && ToSeaLevel == 0){
				
				if(LastType == 0)
					if(XORRandom(10) == 0){
						CurrentBiome = BiomeType::Caves;
						CaveLengthBuffer = 0;
					}
					
				if(CaveLengthBuffer > 50+XORRandom(50) && CurrentBiome == BiomeType::Caves){
					CurrentBiome = XORRandom(BiomeType::Caves);
					CaveLengthBuffer = 0;
				}
				
				if(CurrentBiome == BiomeType::Swamp && LastHeight != SeaLevel)LastType = 5; //Jump to sea level if swamp
				else if(LastType == 0)LastType = XORRandom(4); //If last was stright, anything but cliff
				else if(LastType == 4)LastType = 1+XORRandom(3); //If last was cliff, anything but cliffs and straights
				else if(CurrentBiome == BiomeType::Caves)LastType = XORRandom(4); //If cave biome, anything but cliff
				else LastType = XORRandom(5); // RANDOM!!!!1!
				
				switch(LastType){
					case 0:{
						Straight = 1+XORRandom(9);
					break;}
					case 1:{
						Crazy = XORRandom(20);
					break;}
					case 2:{
						Uphill = 2+XORRandom(13);
					break;}
					case 3:{
						Downhill = 5+XORRandom(15);
					break;}
					case 4:{
						
						CurrentBiome = XORRandom(BiomeType::Caves); //Cliffs are a good time to do biome changes ;)
						
						if(CurrentBiome != BiomeType::Swamp){
							if(CliffChange == 0){
								if(XORRandom(2) == 0)CliffUp = 2+XORRandom(8);
								else CliffDown = 5+XORRandom(10);
							}
							if(CliffChange > 0){
								CliffDown = 5+XORRandom(10);
							}
							if(CliffChange < 0){
								CliffUp = 2+XORRandom(8);
							}
							
							CliffChange += CliffUp-CliffDown;
						} else {
							ToSeaLevel = 100; //Swamps get thier own special cliff code
						}

					break;}
					case 5:{
						ToSeaLevel = 100;
					break;}
				}
			}
			
			if(Straight > 0){
				heightmap[x] = LastHeight;
				if(Straight > 4)if(XORRandom(3) == 0)heightmap[x] += XORRandom(3)-1;
				Straight--;
			} else
			if(Uphill > 0){
				heightmap[x] = LastHeight;
				if(XORRandom(3) == 0)heightmap[x] -= XORRandom(2);
				Uphill--;
			} else
			if(Downhill > 0){
				heightmap[x] = LastHeight;
				if(XORRandom(3) == 0)heightmap[x] += XORRandom(2);
				Downhill--;
			} else
			if(CliffDown > 0){
				heightmap[x] = LastHeight+(XORRandom(4)+1);
				CliffDown--;
			} else
			if(CliffUp > 0){
				heightmap[x] = LastHeight-(XORRandom(4)+1);
				CliffUp--;
			} else
			if(ToSeaLevel > 0){
				if(LastHeight > SeaLevel-2 && LastHeight < SeaLevel+2){
					ToSeaLevel = 0;
					heightmap[x] = SeaLevel;
				} else {
					if(LastHeight > SeaLevel)heightmap[x] = LastHeight-(XORRandom(4)+1);
					else heightmap[x] = LastHeight+(XORRandom(4)+1);
					ToSeaLevel--;
				}
			} else {
				heightmap[x] = LastHeight;
				if(XORRandom(2) == 0)heightmap[x] += XORRandom(3)-1;
				if(Crazy > 0)Crazy--;
			}
			
			if(ToSeaLevel == 0 && CurrentBiome == BiomeType::Swamp){
				heightmap[x] = SeaLevel+SwampDip;
				if(XORRandom(8) == 0)SwampDip = XORRandom(2);
			}
			
			LastHeight = heightmap[x];
			if(LastHeight < MaxLandHeight+1)LastHeight += XORRandom(3)+1;
			if(LastHeight > MinFloorHeight-1)LastHeight -= XORRandom(5)+1;
			biome[x] = CurrentBiome;
		}
	}
	
	//server_CreateBlob("ruins", -1, Vec2f(width/2*8,heightmap[width/2]*8-32));
	
	s16[][] World;
	
	for(int i = 0; i < width; i += 1){ //Init world grid
		s16[] temp;
		for(int j = 0; j < height; j += 1){ getNet().server_KeepConnectionsAlive();
			temp.push_back(0);
		}
		World.push_back(temp);
	}
	
	int CaveHeight = 4+XORRandom(12);
	
	for(int i = 0; i < width; i += 1){ getNet().server_KeepConnectionsAlive();//Dirty stones!
		for(int j = 0; j < height; j += 1){ 
			
			int FakeCaveHeightMap = heightmap[i];
			
			if(biome[i] == BiomeType::Caves){ //Caves need special code~
				//On second note, this code is evil beyond all belief, don't touch it.
				f32 Divide = 1;
				
				if(i > 3)if(biome[i-4] != BiomeType::Caves)Divide = 0.8;
				if(i > 2)if(biome[i-3] != BiomeType::Caves)Divide = 0.6;
				if(i > 1)if(biome[i-2] != BiomeType::Caves)Divide = 0.4;
				if(i > 0)if(biome[i-1] != BiomeType::Caves)Divide = 0.2;

				if(i < width-4)if(biome[i+4] != BiomeType::Caves)Divide = 0.8;
				if(i < width-3)if(biome[i+3] != BiomeType::Caves)Divide = 0.6;
				if(i < width-2)if(biome[i+2] != BiomeType::Caves)Divide = 0.4;
				if(i < width-1)if(biome[i+1] != BiomeType::Caves)Divide = 0.2;
				
				int Change = 5+XORRandom(2);
				Change += Maths::Abs(12-(i % 24));
				Change = Change/4;
				
				FakeCaveHeightMap = (heightmap[i]-CaveHeight)-(Change*Divide)-5*Divide+1;
				
				if(j > (heightmap[i]-CaveHeight)-(Change*Divide)-5*Divide && j < (heightmap[i]-CaveHeight)+((Change*2+XORRandom(4))*Divide)-5*Divide)
					World[i][j] = CMap::tile_ground;
				else
					if(j >= (heightmap[i]-CaveHeight)+((Change*2)*Divide)-5*Divide){
						int Top = (heightmap[i]-CaveHeight)+((Change*2)*Divide)-5*Divide;
						int Bottom = heightmap[i];
						int Length = Bottom-Top;
						if(j <= Top+((Divide)*(Length/2+1)) || j >= Bottom-((Divide)*(Length/2+1))){
							World[i][j] = CMap::tile_ground_back;
						}
					}
						
			} else {
				CaveHeight = 10+XORRandom(6);
			}
			
			int Depth = j-FakeCaveHeightMap;
			
			if(heightmap[i] <= j){
				World[i][j] = CMap::tile_ground;
			}
			if(World[i][j] == CMap::tile_ground){
				if(Depth > 3){
					if(XORRandom(2) == 0){
						switch(XORRandom(3)){
							case 0: {
								World[i][j] = CMap::tile_stone;
							break;}
							case 1: {
								World[i][j] = CMap::tile_stone_d1;
							break;}
							case 2: {
								World[i][j] = CMap::tile_stone_d0;
							break;}
						}
					}
					else {
						const f32 material_frac = (material_noise.Fractal(i*0.1f,j*0.05f) - 0.5f) * 2.0f;
						if (material_frac > 0.4) {
							World[i][j] = CMap::tile_ironore;
						}
						else if (material_frac < -0.4) {
							World[i][j] = CMap::tile_coal;
						}
					}
				}
				
				if(Depth > 6){
					if(XORRandom(3) == 0){
						switch(XORRandom(3)){
							case 0: {
								World[i][j] = CMap::tile_thickstone;
							break;}
							case 1: {
								World[i][j] = CMap::tile_thickstone_d1;
							break;}
							case 2: {
								World[i][j] = CMap::tile_thickstone_d0;
							break;}
						}
					}
					else {
						const f32 material_frac = (material_noise.Fractal(i*0.1f,j*0.05f) - 0.5f) * 2.0f;
						if (material_frac > 0.3) {
							World[i][j] = CMap::tile_ironore;
						}
						else if (material_frac < -0.3) {
							World[i][j] = CMap::tile_coal;
						}
					}
				}
				
				if(j > SeaLevel){
					if(XORRandom(10) == 0){
						World[i][j] = CMap::tile_gold;
					} else if(biome[i] == BiomeType::Desert)
					if(XORRandom(3) == 0){
						World[i][j] = CMap::tile_gold;
					}
				}
			}
		}
	}
	
	
	for(int i = 1; i < width-1; i += 1){ getNet().server_KeepConnectionsAlive();//Set up the world for some corrosion, to remove dirt points
		for(int j = 1; j < height-1; j += 1){
			if(World[i][j] == CMap::tile_ground){
				if(World[i][j-1] == 0){
					if(World[i-1][j] == 0 || World[i+1][j] == 0){
						World[i][j] = -1;
					}
				}
			}
		}
	}
	for(int i = 1; i < width-1; i += 1){ getNet().server_KeepConnectionsAlive();//Corrode dirt points
		for(int j = 1; j < height-1; j += 1){ 
			if(World[i][j] == -1)World[i][j] = 0;
		}
	}
	
	
	
	int FakeCaveTile = 137;
	int FakeCaveTile2 = 138;
	
	for(int i = 0; i < width; i += 1)
	if(XORRandom(3) == 0){
		int plusY = XORRandom(height);
		if(World[i][plusY] != CMap::tile_empty)World[i][plusY] = FakeCaveTile;
	}
	
	for(int i = 0; i < 5; i++){
		Vec2f WormPos = Vec2f(XORRandom(width),height/2);
		Vec2f WormDir = Vec2f(1,0);
		WormDir.RotateBy(45+XORRandom(45));
		
		for(int j = 0; j < 200+XORRandom(200); j += 1){
		
			WormDir.RotateBy(XORRandom(41)-20);
		
			WormPos = WormPos+WormDir;
		
			if(WormPos.y < 1 || WormPos.y > height-1 || WormPos.x < 1 || WormPos.x > width-1)break;
			
			if(World[u16(WormPos.x)][u16(WormPos.y)] != 0)World[u16(WormPos.x)][u16(WormPos.y)] = FakeCaveTile2;
		}
	}
	
	for(int i = 2; i < width-2; i += 1) //Expand caves a bit
		for(int j = 2; j < height-2; j += 1){ getNet().server_KeepConnectionsAlive();
		if(World[i][j] == FakeCaveTile){
			for(int k = 0;k < 10; k += 1){
				int plusX = XORRandom(5)-2;
				int plusY = XORRandom(5)-2;
				if(World[i+plusX][j+plusY] != CMap::tile_empty)World[i+plusX][j+plusY] = FakeCaveTile2;
			}
		}
	}
	
	for(int i = 2; i < width-2; i += 1) //Expand caves a bit Mooore
		for(int j = 2; j < height-2; j += 1){ getNet().server_KeepConnectionsAlive();
		if(World[i][j] == FakeCaveTile2){
			for(int k = 0;k < 10; k += 1){
				int plusX = XORRandom(5)-2;
				int plusY = XORRandom(5)-2;
				if(World[i+plusX][j+plusY] != CMap::tile_empty)if(World[i+plusX][j+plusY] != FakeCaveTile2)World[i+plusX][j+plusY] = FakeCaveTile;
			}
		}
	}
	
	for(int i = 0; i < width; i += 1) //Replace caves with thier actual backgrounds
		for(int j = 0; j < height; j += 1){ getNet().server_KeepConnectionsAlive();
			if(World[i][j] == FakeCaveTile || World[i][j] == FakeCaveTile2){
				World[i][j] = CMap::tile_ground_back;
				//if(XORRandom(100) == 0 && j >= SeaLevel && j < height-7)map.server_setFloodWaterWorldspace(Vec2f(i*8,j*8),true);
			}
	}
	
	
	int bed_start = 6;
	for(int i = 0; i < width; i += 1)
	for(int j = height - bed_start; j < height; j += 1){ getNet().server_KeepConnectionsAlive();
		float r = j + (map_noise.Fractal(i / 2.0f, j / 2.0f) * 2 - 1) * 3;
		if (r > height - bed_start) {
			World[i][j] = CMap::tile_bedrock;
		}
	}


	//////////////Unnatural structures/////////////////////////////////////////
	
	int NodeOffset = -2-XORRandom(3);
	int NodeSize = 7;
	
	int SewerLine = (Maths::Floor(height/NodeSize)-1)*NodeSize+5+NodeOffset;
	
	for(int i = 0; i < width; i += 1)
	if(World[i][SewerLine] != 0){
		World[i][SewerLine] = GetRandomTunnelBackground();
	}
	
	bool[][] Nodes;
	
	for(int i = 0; i < width/NodeSize; i += 1){ //Init underground tunnel node grid
		bool[] temp;
		for(int j = 0; j < height/NodeSize; j += 1){
			temp.push_back(false);
		}
		Nodes.push_back(temp);
	}
	
	for(int i = 1; i < width/NodeSize-1; i += 1) //Find random suitable nodes
		for(int j = 1; j < height/NodeSize; j += 1){
			Nodes[i][j] = false;
			
			if(XORRandom(j) > (f32(height/NodeSize)*0.7f) || XORRandom(15) == 0)
			if(World[i*NodeSize][j*NodeSize+NodeOffset] != 0 && World[i*NodeSize][j*NodeSize+NodeOffset] != CMap::tile_ground_back)
			if(World[i*NodeSize+1][j*NodeSize+NodeOffset] != 0 && World[i*NodeSize+1][j*NodeSize+NodeOffset] != CMap::tile_ground_back)
			if(World[i*NodeSize+1][j*NodeSize+1+NodeOffset] != 0 && World[i*NodeSize+1][j*NodeSize+1+NodeOffset] != CMap::tile_ground_back)
			if(World[i*NodeSize][j*NodeSize+1+NodeOffset] != 0 && World[i*NodeSize][j*NodeSize+1+NodeOffset] != CMap::tile_ground_back){
				Nodes[i][j] = true;
			}
		}
	
	for(int i = 2; i < width/NodeSize-2; i += 1) //Extend nodes left or right
		for(int j = 1; j < height/NodeSize; j += 1){
			if(Nodes[i][j]){
				if(XORRandom(2) == 0){
					if(World[(i-1)*NodeSize][j*NodeSize+NodeOffset] != 0 && World[(i-1)*NodeSize][j*NodeSize+NodeOffset] != CMap::tile_ground_back)
					if(World[(i-1)*NodeSize+1][j*NodeSize+NodeOffset] != 0 && World[(i-1)*NodeSize+1][j*NodeSize+NodeOffset] != CMap::tile_ground_back)
					if(World[(i-1)*NodeSize+1][j*NodeSize+1+NodeOffset] != 0 && World[(i-1)*NodeSize+1][j*NodeSize+1+NodeOffset] != CMap::tile_ground_back)
					if(World[(i-1)*NodeSize][j*NodeSize+1+NodeOffset] != 0 && World[(i-1)*NodeSize][j*NodeSize+1+NodeOffset] != CMap::tile_ground_back)
					Nodes[i-1][j] = true;
				} else {
					if(World[(i+1)*NodeSize][j*NodeSize+NodeOffset] != 0 && World[(i+1)*NodeSize][j*NodeSize+NodeOffset] != CMap::tile_ground_back)
					if(World[(i+1)*NodeSize+1][j*NodeSize+NodeOffset] != 0 && World[(i+1)*NodeSize+1][j*NodeSize+NodeOffset] != CMap::tile_ground_back)
					if(World[(i+1)*NodeSize+1][j*NodeSize+1+NodeOffset] != 0 && World[(i+1)*NodeSize+1][j*NodeSize+1+NodeOffset] != CMap::tile_ground_back)
					if(World[(i+1)*NodeSize][j*NodeSize+1+NodeOffset] != 0 && World[(i+1)*NodeSize][j*NodeSize+1+NodeOffset] != CMap::tile_ground_back)
					Nodes[i+1][j] = true;
				}
			}
		}
	
	for(int i = 1; i < width/NodeSize-1; i += 1){getNet().server_KeepConnectionsAlive(); //Kill any singleton nodes with no connectors :(
		for(int j = 1; j < height/NodeSize; j += 1){
			if(Nodes[i][j]){
				if(j < height/NodeSize-1){
					if(!Nodes[i-1][j])
					if(!Nodes[i+1][j])
					if(!Nodes[i][j-1])
					if(!Nodes[i][j+1])
					Nodes[i][j] = false;
				} else {
					if(!Nodes[i-1][j])
					if(!Nodes[i+1][j])
					if(!Nodes[i][j-1])
					Nodes[i][j] = false;
				}
			}
		}
	}
		
	for(int i = 1; i < width/NodeSize-1; i += 1){getNet().server_KeepConnectionsAlive(); //Build tunnels from nodes.
		for(int j = 1; j < height/NodeSize; j += 1){
			if(Nodes[i][j]){
				World[i*NodeSize][j*NodeSize+NodeOffset] = GetRandomTunnelBackground();
				World[i*NodeSize+1][j*NodeSize+NodeOffset] = GetRandomTunnelBackground();
				World[i*NodeSize][j*NodeSize+1+NodeOffset] = GetRandomTunnelBackground();
				World[i*NodeSize+1][j*NodeSize+1+NodeOffset] = GetRandomTunnelBackground();
				
				World[i*NodeSize-1][j*NodeSize+NodeOffset] = GetRandomCastleTile();
				World[i*NodeSize-1][j*NodeSize+NodeOffset+1] = GetRandomCastleTile();
				World[i*NodeSize+2][j*NodeSize+NodeOffset] = GetRandomCastleTile();
				World[i*NodeSize+2][j*NodeSize+NodeOffset+1] = GetRandomCastleTile();
				World[i*NodeSize][j*NodeSize+NodeOffset-1] = GetRandomCastleTile();
				World[i*NodeSize+1][j*NodeSize+NodeOffset-1] = GetRandomCastleTile();
				World[i*NodeSize][j*NodeSize+NodeOffset+2] = GetRandomCastleTile();
				World[i*NodeSize+1][j*NodeSize+NodeOffset+2] = GetRandomCastleTile();
			}
		}
	}
		
	for(int i = 1; i < width/NodeSize-1; i += 1){ getNet().server_KeepConnectionsAlive();//Build tunnels from nodes.
		for(int j = 1; j < height/NodeSize; j += 1){
			if(Nodes[i][j]){
				if(Nodes[i+1][j])
				for(int k = 0; k < NodeSize-2; k += 1){
					World[i*NodeSize+k+2][j*NodeSize+NodeOffset] = GetRandomTunnelBackground();
					World[i*NodeSize+k+2][j*NodeSize+1+NodeOffset] = GetRandomTunnelBackground();
					
					if(XORRandom(3) != 0)World[i*NodeSize+k+2][j*NodeSize+2+NodeOffset] = GetRandomCastleTile();
					if(XORRandom(3) != 0)World[i*NodeSize+k+2][j*NodeSize-1+NodeOffset] = GetRandomCastleTile();
				}
				
				if(j < height/NodeSize-1){
					if(Nodes[i][j+1])
					for(int k = 0; k < NodeSize-2; k += 1){
						World[i*NodeSize][j*NodeSize+k+2+NodeOffset] = GetRandomTunnelBackground();
						World[i*NodeSize+1][j*NodeSize+k+2+NodeOffset] = GetRandomTunnelBackground();
						
						if(XORRandom(3) != 0)World[i*NodeSize-1][j*NodeSize+k+2+NodeOffset] = GetRandomCastleTile();
						if(XORRandom(3) != 0)World[i*NodeSize+2][j*NodeSize+k+2+NodeOffset] = GetRandomCastleTile();
					}
				} else if(XORRandom(5) == 0){ //Drain thing that leads to sewers, only spawns on the lowest tunnels.
					int temp = XORRandom(NodeSize-2);
					
					World[i*NodeSize-1][j*NodeSize+NodeOffset+2] = CMap::tile_castle;
					World[i*NodeSize+1][j*NodeSize+NodeOffset+2] = CMap::tile_castle;
					World[i*NodeSize-2][j*NodeSize+NodeOffset+2] = CMap::tile_castle;
					World[i*NodeSize+2][j*NodeSize+NodeOffset+2] = CMap::tile_castle;
					World[i*NodeSize-1][j*NodeSize+NodeOffset+3] = CMap::tile_castle_moss;
					World[i*NodeSize+1][j*NodeSize+NodeOffset+3] = CMap::tile_castle_moss;
					
					for(int k = j*NodeSize+NodeOffset+2; k < SewerLine; k += 1){
						World[i*NodeSize][k] = CMap::tile_castle_back_moss;
					}
				}
			}
		}
	}
		
	array<bool> SurfacePlanner(width); //The surface planner
	//Basically, if a building is generated, it sets the area in surface planner to false, so other buildings won't build there.
	//Almost all buildings won't build on/in cave biomes, cause that will heavily screw things up.
	for(int i = 1; i < width; i += 1)SurfacePlanner[i] = true;
	
	
	//////Piers
	/*
	for(int i = 10; i < width-10; i += 1)if(XORRandom(10) == 0){
		if(World[i][SeaLevel] == 0)
		if(World[i-1][SeaLevel] == CMap::tile_ground || World[i+1][SeaLevel] == CMap::tile_ground){
			for(int j = -5; j <= 5; j += 1)if(World[i+j][SeaLevel] == 0){
				World[i+j][SeaLevel] = CMap::tile_wood;
				if(j == 4 || j == -4){
					if(World[i+j][SeaLevel-1] == 0)World[i+j][SeaLevel-1] = CMap::tile_wood_back;
					if(XORRandom(2) == 0)if(World[i+j][SeaLevel-2] == 0)World[i+j][SeaLevel-2] = CMap::tile_wood_back;
				}
				
				if(Maths::Abs(j)%2 == 0){
					for(int k = 1; k < 5+XORRandom(10); k += 1){
						if(World[i+j][SeaLevel+k] == 0)World[i+j][SeaLevel+k] = CMap::tile_wood_back;
					}
				}
			}
		}
	}*/
	
	
	//////Wells
	for(int times = 0; times < 3+XORRandom(2); times += 1) //Try making wells
	for(int i = 1; i < width/NodeSize-1; i += 1){
		bool CanBuild = (XORRandom(20) == 0); //I know this is bad code, don't judge me;
		
		for(int j = -2; j < 4; j += 1){
			if(!SurfacePlanner[i*NodeSize+j] || biome[i*NodeSize+j] == BiomeType::Caves)CanBuild = false;
		}
		
		if(CanBuild){
			
			int Highest = height;
			
			for(int j = -2; j < 4; j += 1)if(Highest > heightmap[i*NodeSize+j])Highest = heightmap[i*NodeSize+j];
			
			if(Highest >= SeaLevel)continue; //Hell no.
			
			for(int j = 0; j < 5; j += 1){
				World[i*NodeSize-1][Highest+j-1] = CMap::tile_castle;
				World[i*NodeSize+2][Highest+j-1] = CMap::tile_castle;
				World[i*NodeSize][Highest+j-1] = CMap::tile_castle_back;
				World[i*NodeSize+1][Highest+j-1] = CMap::tile_castle_back;
			}
			
			for(int j = Highest+2; j < height; j += 1){
				if(World[i*NodeSize][j] == CMap::tile_bedrock || World[i*NodeSize+1][j] == CMap::tile_bedrock)break;
				if(j < Highest+((height-Highest)/2) || XORRandom(3) > 0)World[i*NodeSize][j] = GetRandomTunnelBackground();
				if(j < Highest+((height-Highest)/2) || XORRandom(3) > 0)World[i*NodeSize+1][j] = GetRandomTunnelBackground();
				if(XORRandom(3) == 0)World[i*NodeSize-1][j] = GetRandomCastleTile();
				if(XORRandom(3) == 0)World[i*NodeSize+2][j] = GetRandomCastleTile();
				
				if(j >= SeaLevel){
					map.server_setFloodWaterWorldspace(Vec2f((i*NodeSize)*8,j*8),true);
					map.server_setFloodWaterWorldspace(Vec2f((i*NodeSize+1)*8,j*8),true);
				}
			}
			
			if(XORRandom(2) == 0){	//Do we have a lid? As in, has the well been decommisioned?
			
				World[i*NodeSize][Highest-1] = CMap::tile_wood;
				World[i*NodeSize+1][Highest-1] = CMap::tile_wood;
				
				if(XORRandom(2) == 0)server_CreateBlob("bucket",-1,Vec2f((i*NodeSize+1)*8,(Highest-2)*8)); //Place bucket on lid or it's lost :(
			
			} else { //Other wise, make a pretty roof!
			
				int RoofType = CMap::tile_castle;
				if(XORRandom(2) == 0)RoofType = CMap::tile_wood;
				int PillarType = CMap::tile_castle_back;
				if(XORRandom(2) == 0)PillarType = CMap::tile_wood_back;
				
				World[i*NodeSize-1][Highest-2] = PillarType;
				World[i*NodeSize-1][Highest-3] = PillarType;
				World[i*NodeSize+2][Highest-2] = PillarType;
				World[i*NodeSize+2][Highest-3] = PillarType;
				
				for(int j = 0; j < 4; j += 1){
					World[i*NodeSize-1+j][Highest-4] = RoofType;
				}
				
				int bucketPos = -2;
				if(XORRandom(2) == 0)bucketPos = 4;
				
				server_CreateBlob("bucket",-1,Vec2f((i*NodeSize+bucketPos)*8,(Highest-1)*8));
			
			}
		
			for(int j = -2; j < 4; j += 1){
				SurfacePlanner[i*NodeSize+j] = false;
			}
			
			break;
		}
	}
	
	///////////////////////////////////////////Nature/////////////////////////////////////////////////
	
	for(int i = 0; i < width; i += 1) //Plants \o/
		for(int j = 0; j < height-1; j += 1){ getNet().server_KeepConnectionsAlive();
			if(World[i][j] == 0 && World[i][j+1] == CMap::tile_ground){
				if(biome[i] == BiomeType::Swamp){
					if(XORRandom(3) == 0){
						string tree_str = "tree_bushy";
						if(XORRandom(2) == 0)tree_str = "tree_large";
						CBlob@ tree = server_CreateBlobNoInit(tree_str);
						if (tree !is null)
						{
							tree.Tag("startbig");
							tree.setPosition(Vec2f(i*8,j*8));
							tree.Init();
						}
					}
					if(XORRandom(2) == 0){
						if(XORRandom(2) == 0){
							CBlob@ plant1 = server_CreateBlobNoInit("bush");
							if (plant1 !is null)
							{
								plant1.Tag("instant_grow");
								plant1.setPosition(Vec2f(i*8,j*8));
								plant1.Init();
							}
						} else {
						
							CBlob@ plant = server_CreateBlobNoInit("bush");
							if (plant !is null)
							{
								plant.Tag("instant_grow");
								plant.setPosition(Vec2f(i*8,j*8));
								plant.Init();
							}
						
						}
					}
				}
				
				if(j < SeaLevel){
					if(biome[i] == BiomeType::Forest || biome[i] == BiomeType::Caves){ //Grass
						if(XORRandom(2) == 0){
							World[i][j] = CMap::tile_grass + XORRandom(4);
						}
					}
					if(biome[i] == BiomeType::Meadow || biome[i] == BiomeType::Swamp){ //Grass
						World[i][j] = CMap::tile_grass + XORRandom(4);
					}
					
					if(biome[i] == BiomeType::Forest || biome[i] == BiomeType::Caves) //Trees
					if(XORRandom(6) == 0){
						string tree_str = (j < height/3) ? "tree_pine" : "tree_bushy";
						CBlob@ tree = server_CreateBlobNoInit(tree_str);
						if (tree !is null)
						{
							tree.Tag("startbig");
							tree.setPosition(Vec2f(i*8,j*8));
							tree.Init();
						}
					}
					
					if(biome[i] == BiomeType::Meadow) //Rare chance for trees in meadows. This is incase world gen screws up and decides only meadows.
					if(XORRandom(30) == 0){
						CBlob@ tree = server_CreateBlobNoInit((j < height/3) ? "tree_pine" : "tree_bushy");
						if (tree !is null)
						{
							tree.Tag("startbig");
							tree.setPosition(Vec2f(i*8,j*8));
							tree.Init();
						}
					}
					
					if(biome[i] == BiomeType::Forest || biome[i] == BiomeType::Caves)if(XORRandom(20) == 0){ //Flowers
						CBlob@ plant = server_CreateBlobNoInit("flowers");
						if (plant !is null)
						{
							plant.Tag("instant_grow");
							plant.setPosition(Vec2f(i*8,j*8));
							plant.Init();
						}
					}
					
					if(biome[i] == BiomeType::Forest || biome[i] == BiomeType::Caves)if(XORRandom(3) == 0){ //Bushes
						
						if(XORRandom(5) == 0){
							CBlob@ plant1 = server_CreateBlobNoInit("bush");
							if (plant1 !is null)
							{
								plant1.Tag("instant_grow");
								plant1.setPosition(Vec2f(i*8,j*8));
								plant1.Init();
							}
						} else {
						
							CBlob@ plant = server_CreateBlobNoInit("bush");
							if (plant !is null)
							{
								plant.Tag("instant_grow");
								plant.setPosition(Vec2f(i*8,j*8));
								plant.Init();
							}
						
						}
						
						if(XORRandom(10) == 0){
							CBlob@ plant1 = server_CreateBlobNoInit("flowers");
							if (plant1 !is null)
							{
								plant1.Tag("instant_grow");
								plant1.setPosition(Vec2f(i*8,j*8));
								plant1.Init();
							}
						}
					}
					
					if(biome[i] == BiomeType::Desert || XORRandom(3) == 0) if (XORRandom(10) == 0) { //Grain grows in the desert cause it's hipster like that.
						CBlob@ plant = server_CreateBlobNoInit("grain_plant");
						if (plant !is null)
						{
							plant.Tag("instant_grow");
							plant.setPosition(Vec2f(i*8,j*8));
							plant.Init();
						}
					}
					
					if(biome[i] == BiomeType::Meadow)if(XORRandom(3) == 0){ //LOTSA FLOWERS!! @.@
						CBlob@ plant = server_CreateBlobNoInit("flowers");
						if (plant !is null)
						{
							plant.Tag("instant_grow");
							plant.setPosition(Vec2f(i*8,j*8));
							plant.Init();
						}
						
						if(XORRandom(5) == 0){
							CBlob@ plant2 = server_CreateBlobNoInit("bush");
							if (plant2 !is null)
							{
								plant2.Tag("instant_grow");
								plant2.setPosition(Vec2f(i*8,j*8));
								plant2.Init();
							}
						}
					}
				} else if(j == SeaLevel) {
					if(biome[i] == BiomeType::Swamp){ //Grass
						World[i][j] = CMap::tile_grass + XORRandom(4);
						map.server_setFloodWaterWorldspace(Vec2f(i*8,j*8),true);
					}
				}
				
				break;
			}
		}
	
	for(int i = 0; i < width; i += 1) //Start water dirt
		for(int j = 0; j < height; j += 1){ getNet().server_KeepConnectionsAlive();
			if(World[i][j] == 0 && j >= SeaLevel){
				if(i > 0)if(World[i-1][j] != 0 && World[i-1][j] != CMap::tile_ground_back)if(XORRandom(2) == 0)World[i][j] = CMap::tile_ground_back;
				if(j < height-2)if(World[i][j+1] != 0 && World[i][j+1] != CMap::tile_ground_back)if(XORRandom(2) == 0)World[i][j] = CMap::tile_ground_back;
				if(i < width-2)if(World[i+1][j] != 0 && World[i+1][j] != CMap::tile_ground_back)if(XORRandom(2) == 0)World[i][j] = CMap::tile_ground_back;
			}
	}
	
	for(int k = 0; k < 8; k += 1)
	for(int i = 1; i < width-1; i += 1) //Grow dirt in water
		for(int j = SeaLevel+1; j < height-1; j += 1){ getNet().server_KeepConnectionsAlive();
			if(World[i][j] == CMap::tile_ground_back)if(XORRandom(4) == 0){
				if(World[i-1][j] == 0)if(XORRandom(2) == 0)World[i-1][j] = CMap::tile_ground_back;
				if(World[i][j+1] == 0)if(XORRandom(2) == 0)World[i][j+1] = CMap::tile_ground_back;
				if(World[i+1][j] == 0)if(XORRandom(2) == 0)World[i+1][j] = CMap::tile_ground_back;
				if(World[i][j-1] == 0)if(XORRandom(2) == 0)World[i][j-1] = CMap::tile_ground_back;
				if(World[i][j+1] != 0 && World[i][j+1] != CMap::tile_ground_back)
				if(World[i][j-1] == 0 || World[i][j-2] == 0 || World[i][j-3] == 0 || World[i][j-4] == 0 || World[i][j-5] == 0)
				if(XORRandom(7) == 0){ //Small chance for bushes "seaweed"
					CBlob@ plant = server_CreateBlobNoInit("bush");
					if (plant !is null)
					{
						plant.Tag("instant_grow");
						plant.setPosition(Vec2f(i*8,j*8));
						plant.Init();
					}
					if(XORRandom(10) == 0){ //Small chance for shark, otherwise, fishies!
						server_CreateBlob("shark",-1,Vec2f(i*8,j*8));
					} else {
						server_CreateBlob("fishy",-1,Vec2f(i*8,j*8));
					}
					map.server_setFloodWaterWorldspace(Vec2f(i*8,j*8),true);
				}
			}
	}
	
	

	
	for(int i = 0; i < width; i += 1) //Set world
		for(int j = 0; j < height; j += 1){ getNet().server_KeepConnectionsAlive();
			map.server_SetTile(Vec2f(i*8,j*8), World[i][j]);
			if(World[i][j] == 0 && j >= SeaLevel){
				map.server_setFloodWaterWorldspace(Vec2f(i*8,j*8),true);
				if(i > 0)if(World[i-1][j] != 0 && World[i-1][j] != CMap::tile_ground_back)if(XORRandom(2) == 0)map.server_SetTile(Vec2f(i*8,j*8), CMap::tile_ground_back);
				if(j < height-2)if(World[i][j+1] != 0 && World[i][j+1] != CMap::tile_ground_back)if(XORRandom(2) == 0)map.server_SetTile(Vec2f(i*8,j*8), CMap::tile_ground_back);
				if(i < width-2)if(World[i+1][j] != 0 && World[i+1][j] != CMap::tile_ground_back)if(XORRandom(2) == 0)map.server_SetTile(Vec2f(i*8,j*8), CMap::tile_ground_back);
			}
	}
	
	
	
	SetupBackgrounds(map);
	return true;
}

//spawn functions
CBlob@ SpawnBush(CMap@ map, Vec2f pos)
{
	return server_CreateBlob("bush", -1, pos);
}

CBlob@ SpawnTree(CMap@ map, Vec2f pos, bool high_altitude)
{
	CBlob@ tree = server_CreateBlobNoInit(high_altitude ? "tree_pine" : "tree_bushy");
	if (tree !is null)
	{
		tree.Tag("startbig");
		tree.setPosition(pos);
		tree.Init();
	}
	return tree;
}

int GetRandomTunnelBackground(){

	switch(XORRandom(4)){
	
	case 0: return CMap::tile_ground_back;
	case 1: return CMap::tile_ground_back;
	case 2: return CMap::tile_castle_back;
	case 3: return CMap::tile_castle_back_moss;
	
	}
	return CMap::tile_ground_back;
}

int GetRandomCastleTile(){

	switch(XORRandom(2)){
	
	case 0: return CMap::tile_castle;
	case 1: return CMap::tile_castle_moss;
	
	}
	return CMap::tile_castle;
}

void SetupMap(CMap@ map, int width, int height)
{
	map.CreateTileMap(width, height, 8.0f, "Sprites/world.png");
}

void SetupBackgrounds(CMap@ map)
{
	// sky
	map.CreateSky(color_black, Vec2f(1.0f, 1.0f), 200, "Sprites/Back/cloud", 0);
	map.CreateSkyGradient("Sprites/skygradient.png");   // override sky color with gradient

	// plains
	map.AddBackground("Sprites/Back/BackgroundPlains.png", Vec2f(0.0f, -50.0f), Vec2f(0.06f, 20.0f), color_white);
	map.AddBackground("Sprites/Back/BackgroundTrees.png", Vec2f(0.0f,  -220.0f), Vec2f(0.18f, 70.0f), color_white);
	//map.AddBackground( "Sprites/Back/BackgroundIsland.png", Vec2f(0.0f, 50.0f), Vec2f(0.5f, 0.5f), color_white ); 
	map.AddBackground("Sprites/Back/BackgroundCastle.png", Vec2f(0.0f, -580.0f), Vec2f(0.3f, 180.0f), color_white);

	// fade in
	SetScreenFlash(255, 0, 0, 0);

	SetupBlocks(map);
}

void SetupBlocks(CMap@ map)
{
	
}

bool LoadMap( CMap@ map, const string& in fileName )
{
    print("GENERATING KAGGen MAP " + fileName );
   	
    return loadMap(map, fileName);
}





