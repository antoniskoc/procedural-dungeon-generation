function scr_room_obstacles_get(_room_k, _gw, _gh, _tx1, _tx2, _ty1, _ty2)
{


    if (!ds_exists(global.room_geom, ds_type_map))
        global.room_geom = ds_map_create();

    // If already generated for this room, reuse it (persistent)
    if (ds_map_exists(global.room_geom, _room_k))
        return ds_map_find_value(global.room_geom, _room_k);

    // --------- Randomised counts (tweak later) ----------
    var rock_count    = irandom_range(2, 6); // 1x1 rocks
    var boulder_count = irandom_range(0, 2); // 2x2 boulders

    var occ = ds_map_create(); // key "tx,ty" -> 1

    var obs = [];


    var placed_b = 0;
    var tries_b = 200;

    while (placed_b < boulder_count && tries_b > 0)
    {
        tries_b--;

        // top-left of 2x2 must stay inside interior
        var tx = irandom_range(1, _gw - 3);
        var ty = irandom_range(1, _gh - 3);

        var ok = true;

        // check the 4 tiles of the 2x2 block
        for (var dy_i = 0; dy_i < 2; dy_i++)
        {
            for (var dx_i = 0; dx_i < 2; dx_i++)
            {
                var ttx = tx + dx_i;
                var tty = ty + dy_i;

    
                var reserved = false;

                if (ttx == _tx1 || ttx == _tx2) reserved = true;
                if (tty == _ty1 || tty == _ty2) reserved = true;

                // centre safe zone
                if (ttx >= _tx1 - 1 && ttx <= _tx2 + 1 && tty >= _ty1 - 1 && tty <= _ty2 + 1)
                    reserved = true;

                if (reserved) { ok = false; break; }

                var kk = string(ttx) + "," + string(tty);
                if (ds_map_exists(occ, kk)) { ok = false; break; }
            }
            if (!ok) break;
        }

        if (!ok) continue;

        // mark occupancy for all 4 tiles
        for (var dy_j = 0; dy_j < 2; dy_j++)
        {
            for (var dx_j = 0; dx_j < 2; dx_j++)
            {
                var ox = tx + dx_j;
                var oy = ty + dy_j;
                ds_map_add(occ, string(ox) + "," + string(oy), 1);
            }
        }

        // store boulder definition (top-left)
        array_push(obs, { type: 2, tx: tx, ty: ty });
        placed_b++;
    }


    var placed_r = 0;
    var tries_r = 300;

    while (placed_r < rock_count && tries_r > 0)
    {
        tries_r--;

        var txr = irandom_range(1, _gw - 2);
        var tyr = irandom_range(1, _gh - 2);


        var reserved_r = false;

        if (txr == _tx1 || txr == _tx2) reserved_r = true;
        if (tyr == _ty1 || tyr == _ty2) reserved_r = true;

        if (txr >= _tx1 - 1 && txr <= _tx2 + 1 && tyr >= _ty1 - 1 && tyr <= _ty2 + 1)
            reserved_r = true;

        if (reserved_r) continue;

        var k2 = string(txr) + "," + string(tyr);
        if (ds_map_exists(occ, k2)) continue;

        ds_map_add(occ, k2, 1);

        array_push(obs, { type: 1, tx: txr, ty: tyr });
        placed_r++;
    }

    ds_map_destroy(occ);

    // Save for this room so it stays consistent on re-entry
    ds_map_add(global.room_geom, _room_k, obs);

    return obs;
}