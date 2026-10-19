function scr_region_reduce_neighbor(_a_key,_b_key,_dir,_opp){
	// reduce the WFC domain of room B using the domain of A.
	//_a_key: first room key
	//_b_key: the neighbouring room key whos domain is to be reduced
	//_dir: direction from A to B
	//_opp: oposite direction from B to A
	// Return values : 0 - Bs domain didnt change, 1 - Bs domain was reduced, -1 - contradictionB has no achetypes left
	
	// if either room has no domain we cant reduce
	if (!ds_map_exists(global.wfc_domain, _a_key))
    {
        return 0;
    }

    if (!ds_map_exists(global.wfc_domain, _b_key))
    {
        return 0;
    }

    var dom_a = ds_map_find_value(global.wfc_domain, _a_key);
    var dom_b = ds_map_find_value(global.wfc_domain, _b_key);

    var new_dom_b = 0;
	// check possible archetypes of B
	
	for (var b = 0; b < global.wfc_nArch; b++)
	{
		//skip archetypes not allowed for b
		if ((dom_b & (1 << b)) ==0)
		{
			continue;
		}
		var mask_b = global.room_archetypes[b];
		
		// Does B have a door back towards A?
		var b_has = ((mask_b & (1<< _opp)) !=0);
		
		var compatible_with_a = false;
		// see if b archetype is compatible with at least one possible archetype in A
		
		for (var a = 0; a < global.wfc_nArch; a++)
		{
			// Skip archetypes that arent allowed for A
			if ((dom_a & (1 << a)) == 0)
			{
				continue;
			}
			var mask_a = global.room_archetypes[a];
			
			// does a have a door towards b
			var a_has = ((mask_a & (1 << _dir))) !=0;
			
			// A and B must agree about the connection between them
			if (a_has == b_has)
			{
				
				compatible_with_a = true;
				break;
			}
		}
		// Keep B's archetype if it is compatible with A.
        if (compatible_with_a)
        {
            new_dom_b |= (1 << b);
        }
    }

    // If B has no valid options left, this is a WFC contradiction.
    if (new_dom_b == 0)
    {
        return -1;
    }

    // If B's domain changed, store the reduced domain.
    if (new_dom_b != dom_b)
    {
        ds_map_replace(global.wfc_domain, _b_key, new_dom_b);
        return 1;
    }

    return 0;
}

