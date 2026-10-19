function scr_wfc_collapse_key(_k)
{
    if (ds_map_exists(global.wfc_done, _k)) return true;

    if (!ds_map_exists(global.wfc_domain, _k))
        ds_map_add(global.wfc_domain, _k, global.wfc_ALL);

    var dom = ds_map_find_value(global.wfc_domain, _k);
    if (dom == 0) return false;

    var xy = scr_wfc_key_to_xy(_k);
    var tx = xy[0];
    var ty = xy[1];

    var nArch = global.wfc_nArch;
    var curRooms = ds_map_size(global.wfc_domain);
    var remaining = global.max_rooms - curRooms;

    // Weighted choice among allowed archetypes
    var idxs = [];
    var weights = [];
    var count = 0;
    var totalW = 0;

    // Forced door estimation (used for corridor straightness bonus)
    var forced = 0;
    for (var dirf = 0; dirf < 4; dirf++)
    {
        var all_have = true;

        for (var ii = 0; ii < nArch; ii++)
        {
            if (!(dom & (1 << ii))) continue;

            var m0 = global.room_archetypes[ii];
            if ((m0 & (1 << dirf)) == 0)
            {
                all_have = false;
                break;
            }
        }

        if (all_have) forced |= (1 << dirf);
    }

    for (var i = 0; i < nArch; i++)
    {
        if (!(dom & (1 << i))) continue;

        var mask = global.room_archetypes[i];

        // needed = how many NEW rooms this choice would create
        // touch_existing = doors that connect to already existing rooms in domain
        var needed = 0;
        var touch_existing = 0;

        for (var dir = 0; dir < 4; dir++)
        {
            if (!(mask & (1 << dir))) continue;

            var nk = scr_wfc_key(tx + global.wfc_dx[dir], ty + global.wfc_dy[dir]);

            if (ds_map_exists(global.wfc_domain, nk)) touch_existing++;
            else needed++;
        }

        // Room budget check
        if (curRooms + needed > global.max_rooms) continue;

        // Base growth preference
        var w_base = 1.0;
        if (curRooms < global.max_rooms) w_base = 1.0 + needed * global.wfc_growth_multi;

        // Style weights
        var w_style = scr_wfc_style_weight_for_mask(mask);

        // Corridor straightness bonus
        var w_straight = 1.0;
        if (global.wfc_style == global.WFC_STYLE_CORRIDOR && global.wfc_straight_bonus > 0)
        {
            if ((forced & (1 << 3)) && (mask & (1 << 1))) w_straight += global.wfc_straight_bonus;
            if ((forced & (1 << 1)) && (mask & (1 << 3))) w_straight += global.wfc_straight_bonus;

            if ((forced & (1 << 0)) && (mask & (1 << 2))) w_straight += global.wfc_straight_bonus;
            if ((forced & (1 << 2)) && (mask & (1 << 0))) w_straight += global.wfc_straight_bonus;
        }

        // ✅ CHANGED: LOOPINESS delayed until after growth phase
        var w_loop = 1.0;
        if (curRooms >= global.wfc_loop_start_rooms)
        {
            var loop_strength = 2.0 * global.wfc_loopiness;
            w_loop = 1.0 + touch_existing * loop_strength;
        }

        // ✅ NEW: ENDGAME CAP MODE
        // When we are close to max_rooms, we strongly prefer choices that do NOT create new rooms.
        // This prevents BRANCHY from creating huge "frontier pressure" that leads to WFC failure.
        var w_finish = 1.0;
        if (remaining <= global.wfc_finish_rooms)
        {
            // needed=0 is best; needed>0 gets punished hard
            w_finish = 1.0 / (1.0 + needed * global.wfc_finish_penalty);
        }

        var weight = w_base * w_style * w_straight * w_loop * w_finish;

        // Convert to int
        var w_int = floor(weight * global.wfc_weight_scale);
        if (w_int < 1) w_int = 1;

        idxs[count] = i;
        weights[count] = w_int;
        count++;
        totalW += w_int;
    }

    if (count <= 0) return false;

    // Weighted random pick
    var r = irandom(totalW - 1);
    var pick = idxs[0];

    for (var j = 0; j < count; j++)
    {
        r -= weights[j];
        if (r < 0) { pick = idxs[j]; break; }
    }

    // Collapse
    ds_map_replace(global.wfc_domain, _k, (1 << pick));
    ds_map_add(global.wfc_done, _k, 1);

    var door_mask = global.room_archetypes[pick];
    ds_map_replace(global.room_doors, _k, door_mask);

    // Create neighbor variables for open doors
    for (var dir2 = 0; dir2 < 4; dir2++)
    {
        if (!(door_mask & (1 << dir2))) continue;

        var nk2 = scr_wfc_key(tx + global.wfc_dx[dir2], ty + global.wfc_dy[dir2]);

        if (!ds_map_exists(global.wfc_domain, nk2))
        {
            ds_map_add(global.wfc_domain, nk2, global.wfc_ALL);
            ds_list_add(global.wfc_keys, nk2);
        }
    }

    return true;
}