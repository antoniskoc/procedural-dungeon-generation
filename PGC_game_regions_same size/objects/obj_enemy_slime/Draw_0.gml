/// obj_enemy_slime : Draw

draw_self();

// Don't show intent while moving/bouncing
if (moving || bounce_stage != 0) exit;

var gen = global.levelgen_id;
if (!instance_exists(gen)) exit;

var ply = instance_find(obj_player, 0);
if (!instance_exists(ply)) exit;

// Adjacent check
var ddx_adj = ply.tile_x - tile_x;
var ddy_adj = ply.tile_y - tile_y;
var is_adjacent = (abs(ddx_adj) + abs(ddy_adj) == 1);

// Angry sprite when about to attack
if (is_adjacent)
{
    if (sprite_index != spr_angry) sprite_index = spr_angry;
}
else
{
    if (sprite_index != spr_normal) sprite_index = spr_normal;
}

// Need an intent to draw
if (!intent_valid) exit;

var mdx = intent_dx;
var mdy = intent_dy;

// If adjacent, force preview onto player tile (attack)
if (is_adjacent)
{
    mdx = ddx_adj;
    mdy = ddy_adj;
}

if (mdx == 0 && mdy == 0) exit;

var ntx = tile_x + mdx;
var nty = tile_y + mdy;

if (ntx < 0 || nty < 0 || ntx >= gen.grid_w || nty >= gen.grid_h) exit;
if (gen.map[# ntx, nty] == gen.CELL_WALL) exit;

var tpx = ntx * gen.tile_size + gen.tile_size * 0.5;
var tpy = nty * gen.tile_size + gen.tile_size * 0.5;

var tint = c_white;
if (ntx == ply.tile_x && nty == ply.tile_y) tint = c_red;

var old_col = draw_get_color();
var old_a = draw_get_alpha();

draw_set_color(tint);
draw_set_alpha(0.35);
draw_line(x, y, tpx, tpy);

draw_sprite_ext(sprite_index, image_index, tpx, tpy, 1, 1, 0, tint, 0.35);

draw_set_alpha(old_a);
draw_set_color(old_col);