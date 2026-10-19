function scr_wfc_generate_region(_seed_k, _target_rooms,_region_map)
{
// this script generates a new WFC based dungeon "region" starting from an existing room
//
// different to the main scr_wfc_generate_layout since:
// it doesnt clear glogla.room_doors
// doesnt have to start from 0.0
// doesnt overwrite rooms that exist
// generates new region from a seed room
// stores all rooms in _region_map
// for LOCKED GATEWAY MODE it will be used like this : First WFC Region -> gateway room -> second WFC dungeon
//_seed_k:
// The room key where the region starts
// _target_rooms:
//how many rooms this region should have
// _region_map:
// ds map that will store each generated room




// SAFETY CHECKS
  if (_seed_k == "")
    {
        show_debug_message("[REGION WFC] Failed: seed room key is empty.");
        return false;
    }

    // The seed room must already exist in the global dungeon.
    if (!ds_map_exists(global.room_doors, _seed_k))
    {
        show_debug_message("[REGION WFC] Failed: seed room does not exist in global.room_doors.");
        return false;
    }

    if (_target_rooms < 1)
    {
        show_debug_message("[REGION WFC] Failed: target room count too small.");
        return false;
    }

    // must give us a valid ds_map to store the rooms.
    if (!ds_exists(_region_map, ds_type_map))
    {
        show_debug_message("[REGION WFC] Failed: region map is not a valid ds_map.");
        return false;
    }
	
	//INITIALISE TEMPORARY WFC STATE
	scr_wfc_state_init();
	
	// SET MAX ROOMS FOR REGION
	var old_max_rooms = global.max_rooms;
	global.max_rooms = _target_rooms;
	// DIRECTION ARRAYS
	
    //Retry setting, retry when wfc constructs impossible layout
	
	var max_tries = 40;
	var safety_steps = 10000;
	
	if(_target_rooms >= 60)
	{
		max_tries =60;
		safety_steps = 6000;
	}
	 if (global.wfc_style == global.WFC_STYLE_BRANCHY)
    {
        max_tries += 40;
        safety_steps += 8000;
    }
	
	repeat(max_tries)
	{
		//reset temporary WFC state dor this region attempt.
		// temporary only for this region generation
		
		scr_wfc_state_init();
		
		ds_map_clear(_region_map);
        ds_map_add(_region_map, _seed_k, true);
		
		var seed_domain = scr_region_filter_domain_for_key(_seed_k, global.wfc_ALL,_region_map);
		
		if (seed_domain ==0)
		{
			continue
		}
		ds_map_add(global.wfc_domain, _seed_k, seed_domain);
		ds_list_add(global.wfc_keys, _seed_k);
		
		
		// WFC collapse loop
		
		// find room with lowest entropy collapse to 1 rooma rchetype, 
		//propagate constraints to neighbours,
		//add new rooms created
		
		var failed = false;
		var steps_left = safety_steps;
		
		while(steps_left > 0)
		{
			steps_left -= 1;
			
			
            var best_k = "";
            var best_entropy = 999999;
			
			 // Find the uncollapsed room with the lowest entropy
			 
            for (var i = 0; i < ds_list_size(global.wfc_keys); i++)
            {
                var k = ds_list_find_value(global.wfc_keys, i);

                if (ds_map_exists(global.wfc_done, k))
                {
                    continue;
                }

                if (!ds_map_exists(global.wfc_domain, k))
                {
                    continue;
                }

                var dom = ds_map_find_value(global.wfc_domain, k);
                var entropy = scr_bits_count(dom);

                if (entropy > 1 && entropy < best_entropy)
                {
                    best_entropy = entropy;
                    best_k = k;
                }
            }
			// If there is no multi-option room, collapse any remaining rooms
			 if (best_k == "")
            {
                var any_left = false;

                for (var j = 0; j < ds_list_size(global.wfc_keys); j++)
                {
                    var k2 = ds_list_find_value(global.wfc_keys, j);

                    if (ds_map_exists(global.wfc_done, k2))
                    {
                        continue;
                    }

                    if (!scr_region_collapse_key(k2, _target_rooms, _region_map))
                    {
                        failed = true;
                        break;
                    }

                    if (!scr_region_propagate_from(k2, _region_map))
                    {
                        failed = true;
                        break;
                    }

                    any_left = true;
                }

                if (failed)
                {
                    break;
                }

                if (!any_left)
                {
                    break;
                }

                continue;
            }
			
			// collapse selected lowest entropy room
			   if (!scr_region_collapse_key(best_k, _target_rooms, _region_map))
            {
                failed = true;
                break;
			}
			// Propagate constraints after the collapse

            if (!scr_region_propagate_from(best_k, _region_map))
            {
                failed = true;
                break;
            }
			 // Stop condition
			  // If the region has reached the target size, we check whether
            // all known region rooms have been collapsed.
			 if (ds_map_size(_region_map) >= _target_rooms)
            {
                var all_done = true;

                for (var done_i = 0; done_i < ds_list_size(global.wfc_keys); done_i++)
                {
                    var dk = ds_list_find_value(global.wfc_keys, done_i);

                    if (!ds_map_exists(global.wfc_done, dk))
                    {
                        all_done = false;
                        break;
                    }
                }

                if (all_done)
                {
                    break;
                }
            }
        }
		 // 5. Check if this attempt succeeded
		   if (!failed && ds_map_size(_region_map) == _target_rooms)
        {
            // ------------------------------------------------------------
            // Pick a final end room inside this regio
            // Preferred final end room:
            // farthest dead-end in the region.
            // Fallback:
            // farthest room in the region.

            var dist_map = ds_map_create();
            var q = ds_queue_create();

            ds_map_add(dist_map, _seed_k, 0);
            ds_queue_enqueue(q, _seed_k);

            var dx = [0, 1, 0, -1];
            var dy = [-1, 0, 1, 0];

            while (ds_queue_size(q) > 0)
            {
                var cur_k = ds_queue_dequeue(q);
                var cur_d = ds_map_find_value(dist_map, cur_k);

                var cur_xy = scr_room_xy_from_key(cur_k);
                var cur_x = cur_xy[0];
                var cur_y = cur_xy[1];

                var cur_mask = ds_map_find_value(global.room_doors, cur_k);

                for (var dir = 0; dir < 4; dir++)
                {
                    if ((cur_mask & (1 << dir)) == 0)
                    {
                        continue;
                    }

                    var nx = cur_x + dx[dir];
                    var ny = cur_y + dy[dir];

                    var nk = scr_room_key_from_xy(nx, ny);

                    // Only calculate distance within this generated region.
                    if (!ds_map_exists(_region_map, nk))
                    {
                        continue;
                    }

                    if (!ds_map_exists(dist_map, nk))
                    {
                        ds_map_add(dist_map, nk, cur_d + 1);
                        ds_queue_enqueue(q, nk);
                    }
                }
            }
			 // Prefer farthest dead-end room
			var best_k = "";
            var best_d = -1;

            var rk = ds_map_find_first(_region_map);

            while (!is_undefined(rk))
            {
                if (rk != _seed_k)
                {
                    if (ds_map_exists(dist_map, rk))
                    {
                        var mask_r = ds_map_find_value(global.room_doors, rk);
                        var doors_r = scr_bits_count(mask_r);
                        var dist_r = ds_map_find_value(dist_map, rk);

                        if (doors_r == 1 && dist_r > best_d)
                        {
                            best_d = dist_r;
                            best_k = rk;
                        }
                    }
                }

                rk = ds_map_find_next(_region_map, rk);
            }
			 if (best_k == "")
            {
                rk = ds_map_find_first(_region_map);

                while (!is_undefined(rk))
                {
                    if (rk != _seed_k)
                    {
                        if (ds_map_exists(dist_map, rk))
                        {
                            var dist_r2 = ds_map_find_value(dist_map, rk);

                            if (dist_r2 > best_d)
                            {
                                best_d = dist_r2;
                                best_k = rk;
                            }
                        }
                    }

                    rk = ds_map_find_next(_region_map, rk);
                }
            }
			
            if (best_k != "")
            {
                global.end_room_k = best_k;

                var end_xy = scr_room_xy_from_key(best_k);
                global.end_room_x = end_xy[0];
                global.end_room_y = end_xy[1];
                global.end_room_dist = best_d;

                show_debug_message("[REGION WFC] Generated region from " + string(_seed_k) +
                                   " rooms=" + string(ds_map_size(_region_map)) +
                                   " end=" + string(global.end_room_k));

                ds_map_destroy(dist_map);
                ds_queue_destroy(q);

                global.max_rooms = old_max_rooms;
                return true;
            }

            ds_map_destroy(dist_map);
            ds_queue_destroy(q);
        }
    }

    // 6. Failed after all retries

    global.max_rooms = old_max_rooms;

    show_debug_message("[REGION WFC] Failed after retries. Seed=" + string(_seed_k) +
                       " target=" + string(_target_rooms));

    return false;


		
		
	
}