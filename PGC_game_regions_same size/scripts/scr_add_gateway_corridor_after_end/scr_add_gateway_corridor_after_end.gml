function scr_add_gateway_corridor_after_end(){
	//Adds a forced gateway coridor room after the end room
	// idea is - first dungeon -> first end room -> gateway controll room
	// script finds the current end room, chooses a free neightbouring position, creates a locked gateway
	// connects the old end room to gateway room
	//returns true - gateway was created, false -gateway wasn't created
	
	// SAFETY CHECKS
	 if (!variable_global_exists("end_room_k"))
    {
        show_debug_message("[GATEWAY] Failed: global.end_room_k does not exist.");
        return false;
    }

    if (global.end_room_k == "")
    {
        show_debug_message("[GATEWAY] Failed: global.end_room_k is empty.");
        return false;
    }

    if (!ds_map_exists(global.room_doors, global.end_room_k))
    {
        show_debug_message("[GATEWAY] Failed: end room does not exist in global.room_doors.");
        return false;
    }
	//DIR SETUP
	var DIR_N = 0;
    var DIR_E = 1;
    var DIR_S = 2;
    var DIR_W = 3;

    var dx = [0, 1, 0, -1];
    var dy = [-1, 0, 1, 0];
	
	// read current end room position(in this code its the entry room)
	var entry_room_k = global.end_room_k;

    var entry_xy = scr_room_xy_from_key(entry_room_k);
    var entry_x = entry_xy[0];
    var entry_y = entry_xy[1];

    var entry_mask = ds_map_find_value(global.room_doors, entry_room_k);
	
	// choose the best direction to place a gateway, end room is a deadend if the door is to the west then place the door to the east etc
	var preferred_dir = -1;
	
	var door_count = 0;
	var only_door_dir = -1;
	for (var d = 0; d < 4; d++)
    {
        if ((entry_mask & (1 << d)) != 0)
        {
            door_count += 1;
            only_door_dir = d;
        }
    }
	
	// check if end room is a dead end (just in case)
	  if (door_count == 1)
    {
        preferred_dir = (only_door_dir + 2) & 3;
    }
	// Build a list of possible directions
	
	var possible_dirs = ds_list_create();
	//try preffered direction first
	if(preferred_dir != -1)
	{
		var px = entry_x + dx[preferred_dir];
		var py = entry_y + dy[preferred_dir];
        var pk = scr_room_key_from_xy(px, py);
		
		if (!ds_map_exists(global.room_doors, pk))
        {
            ds_list_add(possible_dirs, preferred_dir);
        }
		
	}
	// then try other directions
	 for (var dir = 0; dir < 4; dir++)
    {
        // Do not add preferred direction twice.
        if (dir == preferred_dir)
        {
            continue;
        }

        var nx = entry_x + dx[dir];
        var ny = entry_y + dy[dir];
        var nk = scr_room_key_from_xy(nx, ny);

        //  onlyplace the gateway in an empty room position.
        if (!ds_map_exists(global.room_doors, nk))
        {
            ds_list_add(possible_dirs, dir);
        }
    }
	// if there is no  free neighbouring positions, we cant place a gateway.
	if(ds_list_size(possible_dirs) == 0)
	{
		 show_debug_message("[GATEWAY] Failed: no free space next to end room.");

        ds_list_destroy(possible_dirs);
        return false;
		
	}
	// PICK Direction if the preffered dir is valid index at 0;
	var gateway_dir = possible_dirs[| 0];
	ds_list_destroy(possible_dirs);
	
	// create the gateway room key
	
	var gateway_x = entry_x + dx[gateway_dir];
	var gateway_y = entry_y + dy[gateway_dir];

    var gateway_room_k = scr_room_key_from_xy(gateway_x, gateway_y);
	
	//connect current end room to gateway room
	// adds a door to the end room
	// adds a door from gateway to end room back
	
	var connected = scr_add_two_way_door(entry_room_k,gateway_room_k);
	if (!connected)
    {
        show_debug_message("[GATEWAY] Failed: could not connect end room to gateway.");
        return false;
    }
   // store gateway global info
    global.gateway_entry_room_k = entry_room_k;
    global.gateway_room_k = gateway_room_k;
    global.gateway_exit_dir = gateway_dir;
	
	//old end room is no longer the real final end room
	global.first_half_end_room_k = entry_room_k;
	
	show_debug_message("[GATEWAY] Created gateway corridor.");
    show_debug_message("[GATEWAY] Entry room: " + string(global.gateway_entry_room_k));
    show_debug_message("[GATEWAY] Gateway room: " + string(global.gateway_room_k));
    show_debug_message("[GATEWAY] Exit direction: " + string(global.gateway_exit_dir));

    return true;




}