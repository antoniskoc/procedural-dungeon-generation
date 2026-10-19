/// obj_levelgen : Create

randomize();

tile_size = 16;
grid_w = 16;
grid_h = 16;

CELL_FLOOR = 0;
CELL_WALL  = 1;
CELL_ROCK_1X1      = 2; // blocks movement
CELL_BOULDER_TL    = 3; // top-left marker for 2x2 boulder (we spawn 1 sprite here)
CELL_BOULDER_FILL  = 4; // the other 3 tiles of the 2x2 (blocking, but no sprite)

map = ds_grid_create(grid_w, grid_h);

global.levelgen_id = id;

// directions
DIR_N = 0;
DIR_E = 1;
DIR_S = 2;
DIR_W = 3;

// room archetypes 
// max_rooms is controlable via a "big map" toggle
global.max_rooms_small =20;
global.max_rooms_big   = 90;
global.wfc_big_map     = true;  
global.max_rooms = global.max_rooms_big;

var bN = (1 << DIR_N);
var bE = (1 << DIR_E);
var bS = (1 << DIR_S);
var bW = (1 << DIR_W);

global.room_archetypes = [
    bN, bE, bS, bW,
    bN|bS,
    bW|bE,
    bN|bE,
    bE|bS,
    bS|bW,
    bW|bN,
    bN|bE|bW,
    bN|bE|bS,
    bE|bS|bW,
    bN|bS|bW,
    bN|bE|bS|bW
];
// style constraints
global.WFC_STYLE_CORRIDOR = 0;
global.WFC_STYLE_BRANCHY  = 1;
global.WFC_STYLE_VERTICAL = 2;

global.wfc_style = global.WFC_STYLE_CORRIDOR;
scr_wfc_set_style(global.wfc_style);

global.run_started = false;
global.pending_generate = true;

global.show_minimap = true;

// Ensure these maps exist so other code doesn’t crash before generation
global.room_doors = ds_map_create();
global.room_done  = ds_map_create();
global.room_geom  = ds_map_create();
global.eval_min_rooms_frac = 0.80; // keep only dungeons with >= 80% of max_rooms
global.eval_max_tries_per_style = 500; // safety limit so it can’t loop forever



global.room_enemy_defs = ds_map_create();
// Locked door + key progression
global.locked_door_a = "";
global.locked_door_b = "";
global.locked_door_dir_from_a = -1;
global.locked_door_opened = false;
//Locked door generation toggle
global.use_locked_gateway = false ;

global.key_room_k = "";
global.key_collected = false;
global.player_has_key = false;

// Game over default
global.game_over = false;

var a = instance_find(obj_ui_anchor_hearts, 0);
if (instance_exists(a))
{
    global.hp_ui_x = a.x;
    global.hp_ui_y = a.y;
}
else
{
    // fallback if you forgot to place anchor
    global.hp_ui_x = 8;
    global.hp_ui_y = grid_h * tile_size + 8;
}