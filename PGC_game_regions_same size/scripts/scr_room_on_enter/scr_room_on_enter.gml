function scr_room_on_enter()
{
    // Remove old enemies
    with (obj_enemy_slime) instance_destroy();
    with (obj_enemy_bat) instance_destroy();
	with (obj_key_pickup) instance_destroy();

    var gen = global.levelgen_id;
    if (!instance_exists(gen)) exit;
	// Read obj_levelgen variables
	var grid_w    = variable_instance_get(gen, "grid_w");
    var grid_h    = variable_instance_get(gen, "grid_h");
    var tile_size = variable_instance_get(gen, "tile_size");

    var map_grid  = variable_instance_get(gen, "map");

    var CELL_FLOOR = variable_instance_get(gen, "CELL_FLOOR");


    var room_k = string(global.room_x) + "," + string(global.room_y);
	
	var is_start_room = (global.room_x ==0 && global.room_y == 0);
	    // No enemies in start room
	if (!is_start_room)
	{
		 if (!ds_map_exists(global.room_enemy_defs, room_k))
    {
        var target = scr_enemy_target_for_room(room_k);
        var lst = scr_enemy_wfc_generate(room_k, target);
        ds_map_add(global.room_enemy_defs, room_k, lst);
    }
		
	}
	
    var defs = ds_map_find_value(global.room_enemy_defs, room_k);
    if (ds_exists(defs, ds_type_list)){

    var n = ds_list_size(defs);

    for (var ii = 0; ii < n; ii++)
    {
        var e = defs[| ii];

        var px = e.tx * gen.tile_size + gen.tile_size * 0.5;
        var py = e.ty * gen.tile_size + gen.tile_size * 0.5;

        if (e.type == 1)
        {
            var inst1 = instance_create_layer(px, py, "Instances", obj_enemy_slime);
            inst1.tile_x = e.tx;
            inst1.tile_y = e.ty;
            inst1.x = px; inst1.y = py;
            inst1.target_x = px; inst1.target_y = py;
            inst1.moving = false;
            inst1.bounce = false;
            inst1.bounce_stage = 0;
            inst1.intent_valid = false;
            inst1.intent_dx = 0;
            inst1.intent_dy = 0;
        }
        else if (e.type == 2)
        {
            var inst2 = instance_create_layer(px, py, "Instances", obj_enemy_bat);
            inst2.tile_x = e.tx;
            inst2.tile_y = e.ty;
            inst2.x = px; inst2.y = py;
            inst2.target_x = px; inst2.target_y = py;
            inst2.moving = false;

         
            inst2.bat_state = 0;       // start in PREPARE
            inst2.bat_rest_turns = 0;

            inst2.plan_dx = 0;
            inst2.plan_dy = 0;
            inst2.plan_len = 0;

            inst2.intent_valid = false;
            inst2.intent_dx = 0;
            inst2.intent_dy = 0;
            inst2.intent_len = 0;

            // sprite safety
            inst2.sprite_index = inst2.spr_normal;
        }
    }
}


// Spawn Gateway Key
if(global.use_locked_gateway)
{
	//dont spawn again if key collected
	if(!global.key_collected)
	{
		//only spawn key in selected key room.
		if(room_k == global.key_room_k)
		{
			var key_tx = -1;
			var key_ty = -1;
			// find a valid random floor tile for the key (avoid enemy spawns doors and walls)
			repeat(100)
			{
				 var tx = irandom_range(2, grid_w - 3);
                 var ty = irandom_range(2, grid_h - 3);
				 
				 if (ds_grid_get(map_grid, tx, ty) == CELL_FLOOR)
				 {
					 if(scr_enemy_at_tile(tx,ty) == noone)
					 {
						 key_tx = tx;
						 key_ty = ty;
						 break;
						 
				
				
		}
			
	}
}
	
	
// FALLBACK if random placements fail, scan the room until we find first valid floortile
if(key_tx ==-1)
{
	for(var sy =2; sy <= grid_h -3; sy++)
	{
		 for(var sx =2; sy <= grid_w -3; sx++)
	       {
			   if(ds_grid_get(map_grid, sx,sy) == CELL_FLOOR)
			   {
				   if(scr_enemy_at_tile(sx,sy) == noone)
				   {
					   key_tx =sx;
					   key_ty = sy;
					   break;
				   }
			   }
		   }
		   if(key_tx != -1)
		   {
			break;   
		   }
	}
}
// Create key object
  if(key_tx != -1)
  {
	
	  var key_px = key_tx * tile_size + tile_size * 0.5;
      var key_py = key_ty * tile_size + tile_size * 0.5;

     var key_inst = instance_create_layer(key_px, key_py, "Instances", obj_key_pickup);

     key_inst.tile_x = key_tx;
     key_inst.tile_y = key_ty;

     show_debug_message("[KEY] Spawned key in room " + string(room_k) +" at tile " + string(key_tx) + "," + string(key_ty));
	
  }
  else
  {
	  show_debug_message("[KEY] Failed to spawn key in room " + string(room_k));
  }
	
     }
	}
  }
}