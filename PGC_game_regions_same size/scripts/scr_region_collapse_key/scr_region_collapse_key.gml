function scr_region_collapse_key(_k,_target_rooms,_region_map){
	// collapses one room in a regional wfc pass
	//_k the room ket to collapse
	//_target_rooms: how many rooms this region should contain
	//_region_map : a ds_map containing all rooms belonging to this WFC region
		
		
    //  If already collapsed, nothing to do
    if (ds_map_exists(global.wfc_done, _k))
    {
        return true;
    }
	 var dx = [0, 1, 0, -1];
     var dy = [-1, 0, 1, 0];
	 
	 // make sure the room has a wfc domain
	 // if no domain exists start with all archetypes allowed
	 
    if (!ds_map_exists(global.wfc_domain, _k))
    {
        ds_map_add(global.wfc_domain, _k, global.wfc_ALL);
    }
	// filter domian against external fixed rooms
	// this removes archetypes that would contradict already-existing rooms outside this region
	
	var dom = ds_map_find_value(global.wfc_domain, _k);
	
	dom = scr_region_filter_domain_for_key(_k,dom,_region_map);
	
	if (dom ==0)
	{
		return false;
		
	}
	ds_map_replace(global.wfc_domain, _k, dom);
	
	// read current room cords
	var xy = scr_room_xy_from_key(_k);
    var rx = xy[0];
    var ry = xy[1];
	// Region growth info
	var current_room_count = ds_map_size(_region_map);
    var remaining_rooms = _target_rooms - current_room_count;

    // Arrays used for weighted random selection.
    var possible_indices = [];
    var possible_weights = [];

    var possible_count = 0;
    var total_weight = 0;
	// eval each possible archetype
	
	for(var i =0; i < global.wfc_nArch; i++)
	{
		//skip archetypes not currently in domin
		if((dom& (1 << i )) == 0)
		{
			continue;
		}
		var mask = global.room_archetypes[i];
		
		var new_rooms_needed = 0;
		var touches_region = 0;
        var invalid = false;
		
		// check what this archetype would do
		// for each door in the mask it points to a room in the region 
		
		for(var dir =0; dir<4; dir++)
		{
			if((mask & (1 << dir)) ==0)
			{
				continue;
			}
			var nx = rx + dx[dir];
			var ny = ry + dy[dir];
			
			var nk = scr_room_key_from_xy(nx,ny);
			
			if(ds_map_exists(_region_map,nk))
			{
				
				touches_region+=1;
			}
			else if (ds_map_exists(global.room_doors,nk))
			{
				var neighbour_mask = ds_map_find_value(global.room_doors, nk);
				var opp = (dir + 2) & 3;
				if (( neighbour_mask & ( 1 << opp)) == 0 )
				{
					invalid = true;
					break;
				}
			}
			else
			{
				new_rooms_needed += 1;
			}
		}
		if(invalid)
		{
			continue;
		}
		//dont choose an archetype that would make this region larger than target room count
		if(current_room_count + new_rooms_needed > _target_rooms)
		{
			continue;
		}
		
		// calculate selection weights
		
		var w_style = scr_wfc_style_weight_for_mask(mask);
		var w_growth = 1.0;
		
		if(remaining_rooms >0)
		{
			w_growth = 1.0 + new_rooms_needed*global.wfc_growth_mult;
		}
		//Loop weight
		var w_loop = 1.0;
		
		if(current_room_count >= global.wfc_loop_start_rooms)
		{
			w_loop = 1.0 + touches_region * 2.0 * global.wfc_loopiness;
		}
		
		//finish weight
		var w_finish = 1.0;
		
		if(remaining_rooms <= global.wfc_finish_rooms)
		{
			w_finish = 1.0/ (1.0 + new_rooms_needed* global.wfc_finish_penalty);
		}
		var final_weight = w_style * w_growth * w_loop * w_finish;

        var final_weight_int = floor(final_weight * global.wfc_weight_scale);

        if (final_weight_int < 1)
        {
            final_weight_int = 1;
        }

        possible_indices[possible_count] = i;
        possible_weights[possible_count] = final_weight_int;

        possible_count += 1;
        total_weight += final_weight_int;
    }
	//if no valid archetypes remain, collapse failed
	
	if(possible_count <= 0)
	{
		return false;
	}
	
	// weighted random selection
	
	 var r = irandom(total_weight - 1);
    var picked_index = possible_indices[0];

    for (var j = 0; j < possible_count; j++)
    {
        r -= possible_weights[j];

        if (r < 0)
        {
            picked_index = possible_indices[j];
            break;
        }
    }
	
	// collapse this room to the selected archetype
	
	ds_map_replace(global.wfc_domain, _k, (1 << picked_index));
    ds_map_add(global.wfc_done, _k, true);

    var selected_mask = global.room_archetypes[picked_index];

    ds_map_replace(global.room_doors, _k, selected_mask);
	
	// add new neighbouring rooms created by this archetype
	 for (var dir2 = 0; dir2 < 4; dir2++)
    {
        if ((selected_mask & (1 << dir2)) == 0)
        {
            continue;
        }

        var nx2 = rx + dx[dir2];
        var ny2 = ry + dy[dir2];

        var nk2 = scr_room_key_from_xy(nx2, ny2);

        // Already part of this region.
        if (ds_map_exists(_region_map, nk2))
        {
            continue;
        }

        // Already exists outside this region.
        // Do not overwrite first-side rooms or gateway rooms.
        if (ds_map_exists(global.room_doors, nk2))
        {
            continue;
        }

        // Do not exceed region size.
        if (ds_map_size(_region_map) >= _target_rooms)
        {
            continue;
        }

        ds_map_add(_region_map, nk2, true);
        ds_map_add(global.wfc_domain, nk2, global.wfc_ALL);
        ds_list_add(global.wfc_keys, nk2);
    }

    return true;
			
			
			
	

}