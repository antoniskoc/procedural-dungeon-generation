function scr_add_two_way_door(_room_a,_room_b){
	// Adds a two-way connection between neightbouring rooms
	// Find which direction room B is from A
	
	var dir_ab = scr_dir_between_rooms(_room_a, _room_b);

    // If the rooms are not direct neighbours, we cannot connect them.
    if (dir_ab == -1)
    {
        show_debug_message("[DOOR] Could not connect non-neighbour rooms: " + string(_room_a) + " -> " + string(_room_b));
        return false;
    }
	// opposite direction is +2 wrapped
	var dir_ba = (dir_ab + 2) & 3;
	
	// if room a or b is not yet in room_doors, create it with no doors
	if (!ds_map_exists(global.room_doors, _room_a))
    {
        ds_map_add(global.room_doors, _room_a, 0);
    }
    if (!ds_map_exists(global.room_doors, _room_b))
    {
        ds_map_add(global.room_doors, _room_b, 0);
    }
    // Read current door masks.
    var mask_a = ds_map_find_value(global.room_doors, _room_a);
    var mask_b = ds_map_find_value(global.room_doors, _room_b);

    // Add the correct door bit to each room.
    mask_a = mask_a | (1 << dir_ab);
    mask_b = mask_b | (1 << dir_ba);

    // Save updated masks back into the map.
    ds_map_replace(global.room_doors, _room_a, mask_a);
    ds_map_replace(global.room_doors, _room_b, mask_b);

    return true;

}