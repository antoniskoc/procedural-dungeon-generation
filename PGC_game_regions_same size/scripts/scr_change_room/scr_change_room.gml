function scr_change_room(_gen_inst, _dir, _ply_inst)
{
    with (_gen_inst)
    {
        var tx = global.room_x;
        var ty = global.room_y;

        if (_dir == DIR_N) ty -= 1;
        if (_dir == DIR_S) ty += 1;
        if (_dir == DIR_E) tx += 1;
        if (_dir == DIR_W) tx -= 1;

        var tk = string(tx) + "," + string(ty);


        var ck = string(global.room_x) + "," + string(global.room_y);
        if (ds_map_exists(global.room_doors, ck))
        {
            var cmask = ds_map_find_value(global.room_doors, ck);
            if ((cmask & (1 << _dir)) == 0)
            {
                show_debug_message("WARNING: Door desync? current=" + ck +
                                   " mask=" + string(cmask) +
                                   " dir=" + string(_dir));
                // do NOT exit; door object existence is enough to allow move
            }
        }
        else
        {
            show_debug_message("WARNING: current room key missing in room_doors: " + ck);
            // do NOT exit; still allow move if target exists
        }

        // Target must exist (this is the real reason doors “do nothing”)
        if (!ds_map_exists(global.room_doors, tk))
        {
            show_debug_message("BLOCKED: target room missing key " + tk + " (dir=" + string(_dir) + ")");
            exit;
        }
		
		
		// locked gateway check
		if(global.use_locked_gateway)
		{
			//only check this if the locked door hasnt been pened before
			if(!global.locked_door_opened)
			{
				var trying_locked_door = false;
				//ck - current room, tk - target room
				if (ck == global.locked_door_a && tk == global.locked_door_b)
			   {
					trying_locked_door = true;
					
			   }
				 if (ck == global.locked_door_b && tk == global.locked_door_a)
               {
                    trying_locked_door = true;
               }
			   //if transision blocked require key
			   if(trying_locked_door)
			   {
				   if(!global.player_has_key)
				   {
					   show_debug_message("[LOCK] Door is locked. Find the key first.");
                       exit;  
				   }
				   // if player has the key consume it and open the door
				   global.player_has_key = false;
                   global.locked_door_opened = true;
            show_debug_message("[LOCK] Used key. Locked gateway opened.");
			}
		}
			
	}

        if (_dir == DIR_N) global.room_y -= 1;
        if (_dir == DIR_S) global.room_y += 1;
        if (_dir == DIR_E) global.room_x += 1;
        if (_dir == DIR_W) global.room_x -= 1;

        scr_build_room(id);
		scr_room_on_enter();

        var mid_tx = grid_w div 2;
        var mid_ty = grid_h div 2;

        with (_ply_inst)
        {
            if (_dir == other.DIR_N) {
                x = mid_tx * other.tile_size + other.tile_size * 0.5;
                y = (other.grid_h - 2) * other.tile_size + other.tile_size * 0.5;
            }
            if (_dir == other.DIR_S) {
                x = mid_tx * other.tile_size + other.tile_size * 0.5;
                y = 1 * other.tile_size + other.tile_size * 0.5;
            }
            if (_dir == other.DIR_E) {
                x = 1 * other.tile_size + other.tile_size * 0.5;
                y = mid_ty * other.tile_size + other.tile_size * 0.5;
            }
            if (_dir == other.DIR_W) {
                x = (other.grid_w - 2) * other.tile_size + other.tile_size * 0.5;
                y = mid_ty * other.tile_size + other.tile_size * 0.5;
            }
			
			 tile_x = round((x - other.tile_size * 0.5) / other.tile_size);
            tile_y = round((y - other.tile_size * 0.5) / other.tile_size);

            target_tile_x = tile_x;
            target_tile_y = tile_y;

            target_x = x;
            target_y = y;

            moving = false; 

            transition_cooldown = 10;
        }
    }
}