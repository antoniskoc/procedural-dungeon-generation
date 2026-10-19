/// obj_player : Step
if (variable_global_exists("run_started") && !global.run_started) exit;

// If game over: freeze + allow restart
if (variable_global_exists("game_over") && global.game_over)
{
    if (keyboard_check_pressed(ord("R")))
        room_restart();
    exit;
}

if (transition_cooldown > 0) transition_cooldown--;

var gen = global.levelgen_id;
if (!instance_exists(gen)) exit;

// init when generator exists
if (needs_grid_init)
{
    tile_x = gen.grid_w div 2;
    tile_y = gen.grid_h div 2;

    x = tile_x * gen.tile_size + gen.tile_size * 0.5;
    y = tile_y * gen.tile_size + gen.tile_size * 0.5;

    target_tile_x = tile_x;
    target_tile_y = tile_y;
    target_x = x;
    target_y = y;

    moving = false;
    needs_grid_init = false;
    exit;
}

// finish movement
if (moving)
{
    x += clamp(target_x - x, -move_px_per_step, move_px_per_step);
    y += clamp(target_y - y, -move_px_per_step, move_px_per_step);

    if (abs(x - target_x) < 0.001 && abs(y - target_y) < 0.001)
    {
        x = target_x;
        y = target_y;

        moving = false;
        tile_x = target_tile_x;
        tile_y = target_tile_y;

        // Enemy turn after player step
        scr_enemies_take_turn();
    }
    exit;
}

// input
var dx = 0;
var dy = 0;

if (keyboard_check_pressed(vk_up)    || keyboard_check_pressed(ord("W"))) dy = -1;
else if (keyboard_check_pressed(vk_down)  || keyboard_check_pressed(ord("S"))) dy =  1;
else if (keyboard_check_pressed(vk_left)  || keyboard_check_pressed(ord("A"))) dx = -1;
else if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"))) dx =  1;

if (dx == 0 && dy == 0) exit;

// direction enum
var dir = -1;
if (dy == -1) dir = gen.DIR_N;
else if (dy == 1) dir = gen.DIR_S;
else if (dx == 1) dir = gen.DIR_E;
else if (dx == -1) dir = gen.DIR_W;

if (dir != -1) facing_dir = dir;

// Shift+direction = attack
if (keyboard_check(vk_shift))
{
    scr_player_use_weapon(dir);
    exit;
}

// attempt move
var ntx = tile_x + dx;
var nty = tile_y + dy;

if (ntx < 0 || ntx >= gen.grid_w || nty < 0 || nty >= gen.grid_h) exit;
if (gen.map[# ntx, nty] != gen.CELL_FLOOR) exit;

// Block walking into enemies
if (scr_enemy_at_tile(ntx, nty) != noone) exit;

target_tile_x = ntx;
target_tile_y = nty;

target_x = ntx * gen.tile_size + gen.tile_size * 0.5;
target_y = nty * gen.tile_size + gen.tile_size * 0.5;

moving = true;