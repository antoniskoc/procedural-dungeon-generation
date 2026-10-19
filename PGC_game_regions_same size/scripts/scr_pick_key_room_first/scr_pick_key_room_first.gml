function scr_pick_key_room_first_half(){
	global.key_room_k = "";
	
	var start_k = "0,0";
	
	var first_half_end_k = global.end_room_k;
	
	// list of possible key rooms
	
	var candidates = ds_list_create();
	var k = ds_map_find_first(global.room_doors);
	
	while(!is_undefined(k))
	{
		//dont place the key in the start room
		if( k != start_k)
		{
			//dont place it in the first half of the rooms, so the player has to explore
			 if (k != first_half_end_k)
            {
                ds_list_add(candidates, k);
            }
			
		}
		k = ds_map_find_next(global.room_doors,k);
	}
	// if no candidates fai safely
	if(ds_list_size(candidates) == 0)
	{
		show_debug_message("[KEY] Failed: no valid first-half key room found.");

        ds_list_destroy(candidates);
        return false;
		
	}
	// pick a candidate randomly
	
	global.key_room_k = candidates[| irandom(ds_list_size(candidates) -1)];
	
	show_debug_message("[KEY] Key room selected: " + string(global.key_room_k));

    ds_list_destroy(candidates);

    return true;

}