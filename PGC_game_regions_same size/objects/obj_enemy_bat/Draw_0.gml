/// obj_enemy_bat : Draw

// sprite safety
if (sprite_index == -1)
{
    if (variable_instance_exists(id, "spr_normal") && spr_normal != -1)
        sprite_index = spr_normal;
    else
        exit;
}

draw_self();

// no ghost while moving
if (moving) exit;

var gen = global.levelgen_id;
if (!instance_exists(gen)) exit;

var ply = instance_find(obj_player, 0);
if (!instance_exists(ply)) exit;

// If bat is in PREPARE state, show ghost at planned destination
// ✅ We only show the ghost when intent_valid is true
if (!intent_valid) exit;

if (intent_dx == 0 && intent_dy == 0) exit;
if (intent_len <= 0) exit;

var dest_tx = tile_x + intent_dx * intent_len;
var dest_ty = tile_y + intent_dy * intent_len;

if (dest_tx < 0 || dest_ty < 0 || dest_tx >= gen.grid_w || dest_ty >= gen.grid_h) exit;

// convert to pixel
var tpx = dest_tx * gen.tile_size + gen.tile_size * 0.5;
var tpy = dest_ty * gen.tile_size + gen.tile_size * 0.5;

// draw a dashed-looking line (simple line + ghost)
var old_col = draw_get_color();
var old_a = draw_get_alpha();

draw_set_color(c_white);
draw_set_alpha(0.35);
draw_line(x, y, tpx, tpy);

// ghost bat at destination
var ghost_spr = spr_normal;
if (ghost_spr == -1) ghost_spr = sprite_index;
if (ghost_spr == -1)
{
    draw_set_alpha(old_a);
    draw_set_color(old_col);
    exit;
}

draw_sprite_ext(ghost_spr, 0, tpx, tpy, 1, 1, 0, c_white, 0.35);

draw_set_alpha(old_a);
draw_set_color(old_col);