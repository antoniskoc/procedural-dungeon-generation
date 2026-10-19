function scr_grow_second_side_dungeon(_target_rooms)
{
    if (!variable_global_exists("second_start_room_k"))
    {
        show_debug_message("[SECOND] Failed: global.second_start_room_k does not exist.");
        return false;
    }

    if (global.second_start_room_k == "")
    {
        show_debug_message("[SECOND] Failed: global.second_start_room_k is empty.");
        return false;
    }

    if (!ds_map_exists(global.room_doors, global.second_start_room_k))
    {
        show_debug_message("[SECOND] Failed: second start room is not in global.room_doors.");
        return false;
    }
	if (_target_rooms < 1)
    {
        show_debug_message("[SECOND] Failed: target room count too small.");
        return false;
    }

    if (variable_global_exists("second_side_rooms"))
    {
        if (ds_exists(global.second_side_rooms, ds_type_map))
        {
            ds_map_destroy(global.second_side_rooms);
        }
    }
	global.second_side_rooms = ds_map_create();
	
	var dx = [0, 1, 0, -1];
    var dy = [-1, 0, 1, 0];
	
	var second_rooms = ds_list_create();
	
	ds_list_add(second_rooms, global.second_start_room_k);
	ds_map_add(global.second_side_rooms, global.second_start_room_k, true);
	
	var safety = 3000;
	
	while (ds_list_size(second_rooms) < _target_rooms && safety >0)
	{
		safety -= 1;
		
		var base_i = irandom(ds_list_size(second_rooms) -1);
		var base_k = second_rooms[| base_i];
		
		var base_xy = scr_room_xy_from_key(base_k);
        var base_x = base_xy[0];
        var base_y = base_xy[1];

        var possible_dirs = ds_list_create();
		
		for(var dir =0; dir <4; dir++)
		{
			var nx = base_x + dx[dir];
            var ny = base_y + dy[dir];
            var nk = scr_room_key_from_xy(nx, ny);

            if (!ds_map_exists(global.room_doors, nk))
            {
                ds_list_add(possible_dirs, dir);
            }
			
		}
		if(ds_list_size(possible_dirs) > 0)
		{
			var pick_dir = possible_dirs[| irandom(ds_list_size(possible_dirs) - 1)];
			
			var new_x = base_x +dx[pick_dir];
			var new_y = base_y +dy[pick_dir];
			var new_k = scr_room_key_from_xy(new_x,new_y);
			
			var connected = scr_add_two_way_door(base_k, new_k);
			
			if (connected)
			{
			 ds_list_add(second_rooms, new_k);
              ds_map_add(global.second_side_rooms, new_k, true);
				
			}
		}
		ds_list_destroy(possible_dirs);
			
		}
		if(ds_list_size(second_rooms) < _target_rooms)
		{
			show_debug_message("[SECOND] Failed: could only grow " + string(ds_list_size(second_rooms)) +
                           " rooms out of " + string(_target_rooms));

        ds_list_destroy(second_rooms);

        return false;
    }

    var dist_map = ds_map_create();
    var q = ds_queue_create();

    ds_map_add(dist_map, global.second_start_room_k, 0);
    ds_queue_enqueue(q, global.second_start_room_k);

    while (!ds_queue_empty(q))
    {
        var cur_k = ds_queue_dequeue(q);
        var cur_d = ds_map_find_value(dist_map, cur_k);

        var cur_xy = scr_room_xy_from_key(cur_k);
        var cur_x = cur_xy[0];
        var cur_y = cur_xy[1];

        var cur_mask = ds_map_find_value(global.room_doors, cur_k);

        for (var d = 0; d < 4; d++)
        {
            if ((cur_mask & (1 << d)) == 0)
            {
                continue;
            }

            var nrx = cur_x + dx[d];
            var nry = cur_y + dy[d];
            var nk2 = scr_room_key_from_xy(nrx, nry);

            if (!ds_map_exists(global.second_side_rooms, nk2))
            {
                continue;
            }

            if (!ds_map_exists(dist_map, nk2))
            {
                ds_map_add(dist_map, nk2, cur_d + 1);
                ds_queue_enqueue(q, nk2);
            }
        }
    }

    var best_k = "";
    var best_d = -1;

    for (var i = 0; i < ds_list_size(second_rooms); i++)
    {
        var room_k = second_rooms[| i];

        if (room_k == global.second_start_room_k)
        {
            continue;
        }

        var mask = ds_map_find_value(global.room_doors, room_k);
        var door_count = scr_bits_count(mask);

        if (door_count == 1)
        {
            var room_d = ds_map_find_value(dist_map, room_k);

            if (room_d > best_d)
            {
                best_d = room_d;
                best_k = room_k;
            }
        }
    }

    if (best_k == "")
    {
        for (var j = 0; j < ds_list_size(second_rooms); j++)
        {
            var room_k2 = second_rooms[| j];

            if (room_k2 == global.second_start_room_k)
            {
                continue;
            }

            var room_d2 = ds_map_find_value(dist_map, room_k2);

            if (room_d2 > best_d)
            {
                best_d = room_d2;
                best_k = room_k2;
            }
        }
    }

    if (best_k == "")
    {
        show_debug_message("[SECOND] Failed: could not choose final end room.");

        ds_list_destroy(second_rooms);
        ds_map_destroy(dist_map);
        ds_queue_destroy(q);

        return false;
    }

    global.end_room_k = best_k;

    var end_xy = scr_room_xy_from_key(best_k);
    global.end_room_x = end_xy[0];
    global.end_room_y = end_xy[1];
    global.end_room_dist = best_d;

    show_debug_message("[SECOND] Grown second-side dungeon with " + string(ds_list_size(second_rooms)) + " rooms.");
    show_debug_message("[SECOND] Final end room: " + string(global.end_room_k));

    ds_list_destroy(second_rooms);
    ds_map_destroy(dist_map);
    ds_queue_destroy(q);

    return true;
}