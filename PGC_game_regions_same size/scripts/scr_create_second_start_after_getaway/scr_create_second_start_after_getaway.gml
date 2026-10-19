function scr_create_second_start_after_gateway(){
	// add the first room of the second dngeon after the gateway
	// first half dungeon -> gateway -> second half dungeon
	// returns true - second-side start room created
	// SAFETY CHECKSS
	if (!variable_global_exists("gateway_room_k"))
    {
        show_debug_message("[GATEWAY] Failed: global.gateway_room_k does not exist.");
        return false;
    }

    if (!variable_global_exists("gateway_exit_dir"))
    {
        show_debug_message("[GATEWAY] Failed: global.gateway_exit_dir does not exist.");
        return false;
    }

    if (global.gateway_room_k == "")
    {
        show_debug_message("[GATEWAY] Failed: global.gateway_room_k is empty.");
        return false;
    }

    if (!ds_map_exists(global.room_doors, global.gateway_room_k))
    {
        show_debug_message("[GATEWAY] Failed: gateway room does not exist in global.room_doors.");
        return false;
    }

	// DIRECTIONS
	var dx = [0, 1, 0, -1];
    var dy = [-1, 0, 1, 0];
	
	var exit_dir = global.gateway_exit_dir;
	
	if (exit_dir < 0 || exit_dir > 3)
    {
        show_debug_message("[GATEWAY] Failed: invalid gateway_exit_dir: " + string(exit_dir));
        return false;
    }
	
	// get gateway room cords
	var gateway_xy = scr_room_xy_from_key(global.gateway_room_k);

    var gateway_x = gateway_xy[0];
    var gateway_y = gateway_xy[1];
	
	// find where the second room start room should be
	var second_x = gateway_x + dx[exit_dir];
    var second_y = gateway_y + dy[exit_dir];
	var second_room_k = scr_room_key_from_xy(second_x, second_y);

    // ensure its empty
	if (ds_map_exists(global.room_doors, second_room_k))
    {
        show_debug_message("[GATEWAY] Failed: second-side start position already occupied: " + string(second_room_k));
        return false;
    }

	// connect gateway corridor to second start room
	// adds one door from the gateway to second start side
	// one door from second start to gateway
	
	var connected = scr_add_two_way_door(global.gateway_room_k, second_room_k);
	
    if (!connected)
    {
        show_debug_message("[GATEWAY] Failed: could not connect gateway to second-side start.");
        return false;
    }
	
	// store second side start room
	global.second_start_room_k = second_room_k;

	//store the locked door edge
	global.locked_door_a = global.gateway_room_k;
    global.locked_door_b = global.second_start_room_k;
    global.locked_door_opened = false;
	
	global.player_has_key = false;
    global.key_collected = false;

    show_debug_message("[GATEWAY] Created second-side start room.");
    show_debug_message("[GATEWAY] Gateway room: " + string(global.gateway_room_k));
    show_debug_message("[GATEWAY] Second-side start room: " + string(global.second_start_room_k));
	show_debug_message("[LOCK] Locked door edge: " + string(global.locked_door_a) + " -> " + string(global.locked_door_b));

    return true;
}