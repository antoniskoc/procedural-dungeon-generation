function scr_pick_end_room()
{
   
    // - must be dead-end (1 door)
    // - must be far from start
    // - uses mutual door connectivity
    // - rejects dungeon if no candidate exists

    global.end_room_k = "";
    global.end_room_x = 0;
    global.end_room_y = 0;
    global.end_room_dist = -1;

    if (!ds_exists(global.room_doors, ds_type_map)) return false;

    var start_k = "0,0";
    if (!ds_map_exists(global.room_doors, start_k)) return false;

    var DIR_N = 0, DIR_E = 1, DIR_S = 2, DIR_W = 3;
    var dx = [0, 1, 0, -1];
    var dy = [-1, 0, 1, 0];

    var dist_map = ds_map_create();
    var q = ds_queue_create();

    ds_map_add(dist_map, start_k, 0);
    ds_queue_enqueue(q, start_k);

    while (!ds_queue_empty(q))
    {
        var cur_k  = ds_queue_dequeue(q);
        var cur_xy = scr_room_xy_from_key(cur_k);
        var cur_rx = cur_xy[0];
        var cur_ry = cur_xy[1];

        var cur_d   = ds_map_find_value(dist_map, cur_k);
        var cur_mask = ds_map_find_value(global.room_doors, cur_k);

        for (var dir = 0; dir < 4; dir++)
        {
            if ((cur_mask & (1 << dir)) == 0) continue;

            var nrx = cur_rx + dx[dir];
            var nry = cur_ry + dy[dir];
            var nk  = scr_room_key_from_xy(nrx, nry);

            if (!ds_map_exists(global.room_doors, nk)) continue;

            
            var nmask = ds_map_find_value(global.room_doors, nk);
            var opp = (dir + 2) & 3;
            if ((nmask & (1 << opp)) == 0) continue;

            if (!ds_map_exists(dist_map, nk))
            {
                ds_map_add(dist_map, nk, cur_d + 1);
                ds_queue_enqueue(q, nk);
            }
        }
    }

  
    var total_rooms = ds_map_size(global.room_doors);
    var reachable   = ds_map_size(dist_map);

    if (reachable != total_rooms)
    {
        show_debug_message("[END] Reject: disconnected dungeon reachable=" + string(reachable) +
                           " total=" + string(total_rooms));
        ds_map_destroy(dist_map);
        ds_queue_destroy(q);
        return false;
    }

    // find max distance
    var max_dist_all = 0;
    var k = ds_map_find_first(dist_map);
    while (!is_undefined(k))
    {
        var d = ds_map_find_value(dist_map, k);
        if (d > max_dist_all) max_dist_all = d;
        k = ds_map_find_next(dist_map, k);
    }

   
    // Corridor can be stricter, Branchy needs wider zone or it rejects forever.
    var far_frac = 0.80; // default

    if (variable_global_exists("wfc_style"))
    {
        if (global.wfc_style == 0) far_frac = 0.85; // CORRIDOR (stricter)
        if (global.wfc_style == 1) far_frac = 0.70; // BRANCHY (wider)
        if (global.wfc_style == 2) far_frac = 0.75; // VERTICAL
    }

    var min_dist = 4;
    var threshold = floor(max_dist_all * far_frac);
    if (threshold < min_dist) threshold = min_dist;

    // collect dead-end candidates in far zone
    var candidates = ds_list_create();
    var cand_dists = ds_list_create();

    k = ds_map_find_first(dist_map);
    while (!is_undefined(k))
    {
        if (k != start_k)
        {
            var dist = ds_map_find_value(dist_map, k);

            if (dist >= threshold)
            {
                var mask = ds_map_find_value(global.room_doors, k);
                var doors = scr_bits_count(mask);

                if (doors == 1)
                {
                    ds_list_add(candidates, k);
                    ds_list_add(cand_dists, dist);
                }
            }
        }
        k = ds_map_find_next(dist_map, k);
    }

    if (ds_list_size(candidates) == 0)
    {
        show_debug_message("[END] Reject: no far dead-end. max_dist=" + string(max_dist_all) +
                           " threshold=" + string(threshold));
        ds_map_destroy(dist_map);
        ds_queue_destroy(q);
        ds_list_destroy(candidates);
        ds_list_destroy(cand_dists);
        return false;
    }

    // random pick among far dead-ends
    var pick_i = irandom(ds_list_size(candidates) - 1);
    var end_k = ds_list_find_value(candidates, pick_i);
    var end_d = ds_list_find_value(cand_dists, pick_i);

    global.end_room_k = end_k;

    var end_xy = scr_room_xy_from_key(end_k);
    global.end_room_x = end_xy[0];
    global.end_room_y = end_xy[1];
    global.end_room_dist = end_d;

    show_debug_message("[END] Picked end=" + end_k + " dist=" + string(end_d) +
                       " max=" + string(max_dist_all) +
                       " threshold=" + string(threshold) +
                       " far_frac=" + string(far_frac));

    ds_map_destroy(dist_map);
    ds_queue_destroy(q);
    ds_list_destroy(candidates);
    ds_list_destroy(cand_dists);

    return true;
}