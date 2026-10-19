function scr_room_ensure_and_assign(_rx, _ry)
{
    if (!ds_exists(global.room_doors, ds_type_map)) global.room_doors = ds_map_create();
    if (!ds_exists(global.room_done, ds_type_map))  global.room_done  = ds_map_create();

    var k = string(_rx) + "," + string(_ry);

    if (!ds_map_exists(global.room_doors, k)) {
        ds_map_add(global.room_doors, k, 0);
        global.room_count += 1;
    }

    if (ds_map_exists(global.room_done, k)) exit;

    var forced_mask = ds_map_find_value(global.room_doors, k);

    // find compatible archetypes
    var candidates = [];
    var cand_count = 0;
    var arch_count = array_length(global.room_archetypes);

    for (var i = 0; i < arch_count; i++) {
        var candidate = global.room_archetypes[i];

        // must contain all forced doors
        if ((candidate & forced_mask) != forced_mask) continue;

        // how many new rooms this candidate would create
        var needed = 0;

        for (var dir = 0; dir < 4; dir++) {
            if (candidate & (1 << dir)) {
                var nx = _rx;
                var ny = _ry;

                if (dir == 0) ny -= 1;
                else if (dir == 2) ny += 1;
                else if (dir == 1) nx += 1;
                else nx -= 1;

                var nk = string(nx) + "," + string(ny);

                if (!ds_map_exists(global.room_doors, nk)) needed += 1;
            }
        }

        if (global.room_count + needed > global.max_rooms) continue;

        candidates[cand_count] = candidate;
        cand_count += 1;
    }

    // If no archetype matches, only use forced doors
    var final_mask = forced_mask;

    // Otherwise pick a random archetype from candidates
    if (cand_count > 0) {
        final_mask = candidates[irandom(cand_count - 1)];
    }

    ds_map_replace(global.room_doors, k, final_mask);

    /// mark as collapsed/done 
    ds_map_add(global.room_done, k, 1);

    //  create neighbors + force opposite doors
    for (var dir2 = 0; dir2 < 4; dir2++) {
        if (final_mask & (1 << dir2)) {

            var nx2 = _rx;
            var ny2 = _ry;

            if (dir2 == 0) ny2 -= 1;
            else if (dir2 == 2) ny2 += 1;
            else if (dir2 == 1) nx2 += 1;
            else nx2 -= 1;

            var nk2 = string(nx2) + "," + string(ny2);

            if (!ds_map_exists(global.room_doors, nk2)) {
                ds_map_add(global.room_doors, nk2, 0);
                global.room_count += 1;
            }

            var nmask = ds_map_find_value(global.room_doors, nk2);

            var opp = 0;
            if (dir2 == 0) opp = 2;
            else if (dir2 == 2) opp = 0;
            else if (dir2 == 1) opp = 3;
            else opp = 1;

           nmask |= (1 << opp);
            ds_map_replace(global.room_doors, nk2, nmask);
        }
    }
}