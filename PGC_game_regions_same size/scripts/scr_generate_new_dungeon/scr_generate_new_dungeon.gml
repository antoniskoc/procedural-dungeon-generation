function scr_generate_new_dungeon()
{
    // ONLY accept a dungeon if it contains a valid END ROOM that:
    // is a dead-end, or at least a valid far room selected by scr_pick_end_room()
    // If generation fails, discard and retry.

    var MAX_ATTEMPTS = 80;
    var attempt = 0;

    var MIN_ROOMS = 20;
	// In normal mode use  norma global max rooms
	//in locked gateway mode, first wfc region should be smaller
	var original_max_rooms = global.max_rooms;
	if(global.use_locked_gateway)
	{
		if (global.wfc_big_map)
       {
        global.max_rooms = 45;
        MIN_ROOMS = 45;
       }
	   else
	   {
		   global.max_rooms =10;
		   MIN_ROOMS = 10;
	   }
	 	
	}

    while (attempt < MAX_ATTEMPTS)
    {
        attempt += 1;

        // Reset start position + counters
        global.room_x = 0;
        global.room_y = 0;
        global.room_count = 0;

        // Destroy old maps
        if (variable_global_exists("room_doors"))
        {
            if (ds_exists(global.room_doors, ds_type_map)) ds_map_destroy(global.room_doors);
        }

        if (variable_global_exists("room_done"))
        {
            if (ds_exists(global.room_done, ds_type_map)) ds_map_destroy(global.room_done);
        }

        if (variable_global_exists("room_geom"))
        {
            if (ds_exists(global.room_geom, ds_type_map)) ds_map_destroy(global.room_geom);
        }

        // Recreate maps
        global.room_doors = ds_map_create();
        global.room_done  = ds_map_create();
        global.room_geom  = ds_map_create();

        // Reset locked gateway data
        global.gateway_entry_room_k = "";
        global.gateway_room_k = "";
        global.gateway_exit_dir = -1;
        global.first_half_end_room_k = "";
        global.second_start_room_k = "";

        global.locked_door_a = "";
        global.locked_door_b = "";
        global.locked_door_opened = false;

        global.player_has_key = false;
        global.key_collected = false;
        global.key_room_k = "";
		if (variable_global_exists("second_side_rooms"))
        {
         if (ds_exists(global.second_side_rooms, ds_type_map))
        {
         ds_map_destroy(global.second_side_rooms);
        }
        }

global.second_side_rooms = ds_map_create();

        // Generate first dungeon layout via WFC
        var ok = scr_wfc_generate_layout();

        if (!ok)
        {
            show_debug_message("[GEN] ATTEMPT " + string(attempt) + " Rejected WFC failed");
            continue;
        }

        // Ensure start exists
        var start_k = "0,0";

        if (!ds_map_exists(global.room_doors, start_k))
        {
            show_debug_message("[GEN] Attempt " + string(attempt) + " rejected: start room missing");
            continue;
        }

        // Check minimum room count for the first dungeon
        var V = ds_map_size(global.room_doors);

        if (V < MIN_ROOMS)
        {
            show_debug_message("[GEN] Attempt " + string(attempt) + " rejected: too few rooms V=" + string(V) +
                               " (<" + string(MIN_ROOMS) + ")");
            continue;
        }
		var first_side_room_count = V;

        // Pick the end room of the first dungeon
        var end_ok = scr_pick_end_room();

        if (!end_ok)
        {
            show_debug_message("[GEN] Attempt " + string(attempt) + " rejected: no valid far dead-end end room.");
            continue;
        }

        // Optional locked gateway mode
        // Pick a key room in the first dungeon
        // Add a gateway corridor after the first dungeon's end room
        //  Add the second-side start room after the gateway
        //  Grow a second-side dungeon from that second-side start room
        // The final end room is moved into the second-side dungeon.

        if (global.use_locked_gateway)
{
    var key_room_ok = scr_pick_key_room_first_half();

    if (!key_room_ok)
    {
        show_debug_message("[GEN] Attempt " + string(attempt) + " rejected: could not pick key room.");
        continue;
    }

    var gateway_ok = scr_add_gateway_corridor_after_end();

    if (!gateway_ok)
    {
        show_debug_message("[GEN] Attempt " + string(attempt) + " rejected: could not add gateway corridor.");
        continue;
    }

    var second_start_ok = scr_create_second_start_after_gateway();

    if (!second_start_ok)
    {
        show_debug_message("[GEN] Attempt " + string(attempt) + " rejected: could not add second-side start room.");
        continue;
    }

    var second_region_ok = scr_wfc_generate_region(
        global.second_start_room_k,
        first_side_room_count,	
        global.second_side_rooms
    );

    if (!second_region_ok)
    {
        show_debug_message("[GEN] Attempt " + string(attempt) + " rejected: could not generate second WFC region.");
        continue;
    }

    show_debug_message("[GEN] Locked gateway mode is ON.");
    show_debug_message("[GEN] First side rooms: " + string(first_side_room_count));
    show_debug_message("[GEN] Second side rooms: " + string(ds_map_size(global.second_side_rooms)));
}

       
          
        

        // Recalculate room count after optional gateway generation
        V = ds_map_size(global.room_doors);

        show_debug_message("[GEN] Dungeon accepted on attempt " + string(attempt) +
                           " | V=" + string(V) +
                           " | end=" + string(global.end_room_k) +
                           " | dist=" + string(global.end_room_dist));
        global.max_rooms = original_max_rooms;
        return true;
    }

    show_debug_message("[GEN] ERROR: Failed to generate valid dungeon after " + string(MAX_ATTEMPTS) + " attempts.");

    // Make sure end-room is unset
    global.end_room_k = "";
    global.end_room_x = 0;
    global.end_room_y = 0;
    global.end_room_dist = -1;
    global.max_rooms = original_max_rooms;
    return false;
}