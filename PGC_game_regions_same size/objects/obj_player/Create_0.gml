/// obj_player : Create

transition_cooldown = 0;

// how fast to slide to next tile (pixels per frame)
move_px_per_step = 4;

moving = false;

// We'll init tile_x/tile_y once obj_levelgen exists
needs_grid_init = true;

tile_x = 0;
tile_y = 0;

target_tile_x = 0;
target_tile_y = 0;

target_x = x;
target_y = y;

// ✅ FIX: hearts system (exactly 3 hits)
max_hp = 3;
hp = max_hp;

// ✅ keep game over flag sane
global.game_over = false;

// weapon system (default)
weapon_id = "knife";
facing_dir = 2; // DIR_S