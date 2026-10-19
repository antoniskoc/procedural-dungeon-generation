function scr_wfc_generate_layout()
{
    scr_wfc_state_init();

    // Output maps should exist already (you create them in scr_generate_new_dungeon)
    ds_map_clear(global.room_doors);
    ds_map_clear(global.room_done);

    if (global.wfc_nArch <= 0) return false;

    var start = scr_wfc_key(0, 0);
    // dynamic WFC effort based on 
    var tries = 40;
	var safety = 10000;
	
	if(global.max_rooms >= 60)
	{
		
		tries = 90;
		safety = 60000;
		
	}
	// BRANCHY needs more efford
	if (global.wfc_style == global.WFC_STYLE_BRANCHY)
	{
		tries += 50;
		safety += 4000;
		
	}

    repeat (tries)
    {
        ds_map_clear(global.wfc_domain);
        ds_map_clear(global.wfc_done);
        ds_list_clear(global.wfc_keys);
        ds_map_clear(global.room_doors);

        ds_map_add(global.wfc_domain, start, global.wfc_ALL);
        ds_list_add(global.wfc_keys, start);

        var steps_left = safety;
        var failed = false;

        while (steps_left-- > 0)
        {
            // pick lowest entropy key not done
            var best_k = "";
            var best_e = 999999;

            for (var i = 0; i < ds_list_size(global.wfc_keys); i++)
            {
                var k = ds_list_find_value(global.wfc_keys, i);
                if (ds_map_exists(global.wfc_done, k)) continue;

                var d = ds_map_find_value(global.wfc_domain, k);
                var e = scr_bits_count(d);

                if (e > 1 && e < best_e)
                {
                    best_e = e;
                    best_k = k;
                }
            }

            // if none >1, collapse remaining
            if (best_k == "")
            {
                var anyLeft = false;

                for (var j = 0; j < ds_list_size(global.wfc_keys); j++)
                {
                    var k2 = ds_list_find_value(global.wfc_keys, j);
                    if (ds_map_exists(global.wfc_done, k2)) continue;

                    if (!scr_wfc_collapse_key(k2)) { failed = true; break; }
                    if (!scr_wfc_propagate_from(k2)) { failed = true; break; }
                    anyLeft = true;
                }

                if (failed) break;
                if (!anyLeft) break; // finished
                continue;
            }

            if (!scr_wfc_collapse_key(best_k)) { failed = true; break; }
            if (!scr_wfc_propagate_from(best_k)) { failed = true; break; }
        }

        if (!failed)
        {
            global.room_count = ds_map_size(global.wfc_domain);
            return true;
        }
    }

    return false;
}