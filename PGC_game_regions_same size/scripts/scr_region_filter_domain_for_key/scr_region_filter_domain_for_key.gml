function scr_region_filter_domain_for_key(_k,_dom,_region_map){
	// filters the possible archetypes for one roomin a wfc region
	//_k: the room being checked
	//_dom: current domain for possible archetypes of this room
	//_region_map: ds_map containing the rooms that belong to the region being generated
	// script removes archetypes that would conflict with existing rooms outsidethe region
	//If an existing outside room has a door into this room, this roommust have the matching oposite door
	
	var dx = [0,1,0,-1];
	var dy = [ -1, 0,1,0];
	
	var xy = scr_room_xy_from_key(_k);
	var rx = xy[0];
	var ry = xy[1];
	
	var new_dom = 0;
	
	// check possible room archetypes
	for (var i = 0; i < global.wfc_nArch; i++)
	{
		//If archetype i is not currently allowed, skip
		if ((_dom & (1 << i)) == 0)
        {
            continue;
        }
		var mask = global.room_archetypes[i];
		var valid = true;
		
		for(var dir =0; dir <4; dir++)
		{
			var nx = rx + dx[dir];
			var ny = ry + dy[dir];
			
			var nk = scr_room_key_from_xy(nx,ny);
			// if a neightbor exists already but is NOT part of this WFC region its an external constraint
			if(ds_map_exists(global.room_doors, nk))
			{
				if(!ds_map_exists(_region_map,nk))
				{
					var neighbor_mask = ds_map_find_value(global.room_doors, nk);
					var opp = (dir +2) & 3;
					
					var this_has = ((mask & (1 << dir)) !=0);
					var neighbor_has = (( neighbor_mask & (1 << opp)) !=0);
					 // Door compatibility rule:
                    // this room and the neighbouring room must agree.
                    //
                    // If this room has a door toward the neighbour,
                    // the neighbour must have a door back.
                    //
                    // If this room does not have a door toward the neighbour,
                    // the neighbour must not have a door back.
					if(this_has != neighbor_has)
					{
						
						valid = false;
						break;
					}
				}
			}
		}
		//keep archetype if it didnt violate exiting neightbours
		if (valid)
		{
			new_dom |= (1<<i);
			
			
		}
	}
	
		return new_dom;		
			
}
	

