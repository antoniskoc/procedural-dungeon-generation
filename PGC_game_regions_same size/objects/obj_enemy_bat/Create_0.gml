hp = 1;

tile_x = 0;
tile_y = 0;

moving = false;
move_px_per_step = 12; //fast slide
target_x = x;
target_y = y;


// bat states
//0 = prepare
//1 = move
//2 = rest

bat_state = 0;
bat_rest_turns = 0;
//planned dash
plan_dx =0;
plan_dy =0;
plan_len = 0;

// intent preview
intent_dx = 0;
intent_dy = 0;
intent_len =0;
intent_valid = false;
// sprite safety
spr_normal = sprite_index;
if (spr_normal == -1)
{
    spr_normal = spr_bat;     // fallback
    sprite_index = spr_normal;
}

spr_angry = spr_bat_angry;
if (spr_angry == -1) spr_angry = spr_normal;;