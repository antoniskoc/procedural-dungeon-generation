function scr_build_room(_gen_inst)
{
    with (_gen_inst)
    {
        // 1) Reset base map: border walls + interior floor
        for (var gy = 0; gy < grid_h; gy++)
        {
            for (var gx = 0; gx < grid_w; gx++)
            {
                var is_border = (gx == 0) || (gy == 0) || (gx == grid_w - 1) || (gy == grid_h - 1);
                map[# gx, gy] = is_border ? CELL_WALL : CELL_FLOOR;
            }
        }

        var mid_tx = grid_w div 2;
        var mid_ty = grid_h div 2;

        // Current room key and door mask
        var k = string(global.room_x) + "," + string(global.room_y);
        var door_mask = ds_map_find_value(global.room_doors, k);

        // These define the 2-tile-wide “middle” door positions
        var tx1 = clamp(mid_tx - 1, 1, grid_w - 2);
        var tx2 = clamp(mid_tx,     1, grid_w - 2);
        var ty1 = clamp(mid_ty - 1, 1, grid_h - 2);
        var ty2 = clamp(mid_ty,     1, grid_h - 2);

        // 2) Carve door openings (border tiles become floor)
        if (door_mask & (1 << DIR_N)) { map[# tx1, 0] = CELL_FLOOR; map[# tx2, 0] = CELL_FLOOR; }
        if (door_mask & (1 << DIR_S)) { map[# tx1, grid_h-1] = CELL_FLOOR; map[# tx2, grid_h-1] = CELL_FLOOR; }
        if (door_mask & (1 << DIR_E)) { map[# grid_w-1, ty1] = CELL_FLOOR; map[# grid_w-1, ty2] = CELL_FLOOR; }
        if (door_mask & (1 << DIR_W)) { map[# 0, ty1] = CELL_FLOOR; map[# 0, ty2] = CELL_FLOOR; }


        var obs = scr_room_obstacles_get(k, grid_w, grid_h, tx1, tx2, ty1, ty2);

        for (var i = 0; i < array_length(obs); i++)
        {
            var o = obs[i];

            if (o.type == 1)
            {
                // 1x1 rock blocks this single tile
                if (map[# o.tx, o.ty] == CELL_FLOOR)
                    map[# o.tx, o.ty] = CELL_ROCK_1X1;
            }
            else if (o.type == 2)
            {
                // 2x2 boulder blocks 4 tiles
                // top-left marker
                if (map[# o.tx, o.ty] == CELL_FLOOR)
                    map[# o.tx, o.ty] = CELL_BOULDER_TL;

                // fill tiles (no sprite)
                if (map[# o.tx+1, o.ty] == CELL_FLOOR)
                    map[# o.tx+1, o.ty] = CELL_BOULDER_FILL;

                if (map[# o.tx, o.ty+1] == CELL_FLOOR)
                    map[# o.tx, o.ty+1] = CELL_BOULDER_FILL;

                if (map[# o.tx+1, o.ty+1] == CELL_FLOOR)
                    map[# o.tx+1, o.ty+1] = CELL_BOULDER_FILL;
            }
        }

        // 5) Clear old instances
        with (obj_brickwall) instance_destroy();
        with (obj_door)      instance_destroy();

        with (obj_rock_1x1) instance_destroy();
        with (obj_boulder_2x2) instance_destroy();

        var layer_name = "Instances";

        // 6) Spawn walls and obstacles
        for (var sy = 0; sy < grid_h; sy++)
        {
            for (var sx = 0; sx < grid_w; sx++)
            {
                var cell = map[# sx, sy];

                if (cell == CELL_WALL)
                {
                    var px = sx * tile_size + tile_size * 0.5;
                    var py = sy * tile_size + tile_size * 0.5;
                    instance_create_layer(px, py, layer_name, obj_brickwall);
                }
                else if (cell == CELL_ROCK_1X1)
                {
                    var rx = sx * tile_size + tile_size * 0.5;
                    var ry = sy * tile_size + tile_size * 0.5;
                    instance_create_layer(rx, ry, layer_name, obj_rock_1x1);
                }
                else if (cell == CELL_BOULDER_TL)
                {

                    var bx = (sx + 1) * tile_size;
                    var by = (sy + 1) * tile_size;
                    instance_create_layer(bx, by, layer_name, obj_boulder_2x2);
                }
            }
        }


       var d;
var door_px_h = tx1 * tile_size + tile_size;
var door_py_v = ty1 * tile_size + tile_size;
var room_dx = [0, 1, 0, -1];
var room_dy = [-1, 0, 1, 0];

// NORTH DOOR
if (door_mask & (1 << DIR_N))
{
    d = instance_create_layer(door_px_h, 0 * tile_size + tile_size * 0.5, layer_name, obj_door);
    d.door_dir = DIR_N;

    // Work out which room this north door leads to.
    var north_target_k = scr_room_key_from_xy(global.room_x + room_dx[DIR_N], global.room_y + room_dy[DIR_N]);

    // This door is locked if:
    // 1. locked gateway mode is enabled
    // 2. the locked door has not been opened yet
    // 3. this door connects the two locked-door rooms
    d.is_locked =
        global.use_locked_gateway &&
        !global.locked_door_opened &&
        (
            (k == global.locked_door_a && north_target_k == global.locked_door_b) ||
            (k == global.locked_door_b && north_target_k == global.locked_door_a)
        );

    // Use a special sprite when locked, otherwise normal door sprite.
    d.sprite_index = d.is_locked ? spr_door_h_locked : spr_door_h;
    d.mask_index   = d.sprite_index;
}

// EAST DOOR
if (door_mask & (1 << DIR_E))
{
    d = instance_create_layer((grid_w - 1) * tile_size + tile_size * 0.5, door_py_v, layer_name, obj_door);
    d.door_dir = DIR_E;

    var east_target_k = scr_room_key_from_xy(global.room_x + room_dx[DIR_E], global.room_y + room_dy[DIR_E]);

    d.is_locked =
        global.use_locked_gateway &&
        !global.locked_door_opened &&
        (
            (k == global.locked_door_a && east_target_k == global.locked_door_b) ||
            (k == global.locked_door_b && east_target_k == global.locked_door_a)
        );

    d.sprite_index = d.is_locked ? spr_door_v_locked: spr_door_v;
    d.mask_index   = d.sprite_index;
}

// SOUTH DOOR
if (door_mask & (1 << DIR_S))
{
    d = instance_create_layer(door_px_h, (grid_h - 1) * tile_size + tile_size * 0.5, layer_name, obj_door);
    d.door_dir = DIR_S;

    var south_target_k = scr_room_key_from_xy(global.room_x + room_dx[DIR_S], global.room_y + room_dy[DIR_S]);

    d.is_locked =
        global.use_locked_gateway &&
        !global.locked_door_opened &&
        (
            (k == global.locked_door_a && south_target_k == global.locked_door_b) ||
            (k == global.locked_door_b && south_target_k == global.locked_door_a)
        );

    d.sprite_index = d.is_locked ? spr_door_h_locked : spr_door_h;
    d.mask_index   = d.sprite_index;
}
// WEST DOOR
if (door_mask & (1 << DIR_W))
{
    d = instance_create_layer(0 * tile_size + tile_size * 0.5, door_py_v, layer_name, obj_door);
    d.door_dir = DIR_W;

    var west_target_k = scr_room_key_from_xy(global.room_x + room_dx[DIR_W], global.room_y + room_dy[DIR_W]);

    d.is_locked =
        global.use_locked_gateway &&
        !global.locked_door_opened &&
        (
            (k == global.locked_door_a && west_target_k == global.locked_door_b) ||
            (k == global.locked_door_b && west_target_k == global.locked_door_a)
        );

    d.sprite_index = d.is_locked ? spr_door_v_locked : spr_door_v;
    d.mask_index   = d.sprite_index;
}
}
}