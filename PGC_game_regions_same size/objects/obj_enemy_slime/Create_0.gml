/// obj_enemy_slime : Create

hp = 2;

tile_x = 0;
tile_y = 0;

moving = false;
move_px_per_step = 4;

target_x = x;
target_y = y;

// bump-attack bounce state
bounce = false;
bounce_stage = 0; // 0 none, 1 into player, 2 back home
home_tile_x = tile_x;
home_tile_y = tile_y;

// Intent system (for preview)
intent_dx = 0;
intent_dy = 0;
intent_valid = false;

// Sprite refs
spr_normal = sprite_index;
spr_angry  = spr_slime_angry; // you created this