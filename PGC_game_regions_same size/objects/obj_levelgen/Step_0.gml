if (keyboard_check_pressed(ord("M")))
    global.show_minimap = !global.show_minimap;
	
	//style selection
	
if (global.pending_generate)
{
	//Chose style
	if(keyboard_check_pressed(ord("1"))){
		scr_wfc_set_style(global.WFC_STYLE_CORRIDOR);
		
	}
	else if (keyboard_check_pressed(ord("2"))){
		scr_wfc_set_style(global.WFC_STYLE_BRANCHY);
		
	}
	else if (keyboard_check_pressed(ord("3"))){
		scr_wfc_set_style(global.WFC_STYLE_VERTICAL);
		
	}
	// Toggle big map 
	if( keyboard_check_pressed(ord("B")))
	{
		
		global.wfc_big_map = !global.wfc_big_map;
		global.max_rooms = global.wfc_big_map ? global.max_rooms_big : global.max_rooms_small;
	}
	
	// Toggle locked gateway
	if (keyboard_check_pressed(ord("L")))
{
    global.use_locked_gateway = !global.use_locked_gateway;

    if (global.use_locked_gateway)
    {
        show_debug_message("[MENU] Locked gateway mode: ON");
    }
    else
    {
        show_debug_message("[MENU] Locked gateway mode: OFF");
    }
}
	if (keyboard_check_pressed(vk_f9))
{
    scr_eval_run_batch(30);
}
	// generatr
	if(keyboard_check_pressed(vk_enter))
	{
		//clear enemy definition
		if(ds_exists(global.room_enemy_defs, ds_type_map)) ds_map_clear(global.room_enemy_defs);
		// seed generation
		global.last_gen_seed = (get_timer() div 1000) mod 2147483647;
        random_set_seed(global.last_gen_seed);
        show_debug_message("[SEED] " + string(global.last_gen_seed));
		var ok = scr_generate_new_dungeon();
		
		if (!ok)
		{
			show_debug_message("[RUN] Generation FAILED (no valid dungeon). Not starting run.");
            // stay in pending_generate menu so you can press Enter again
            global.run_started = false;
            global.pending_generate = true;
            exit;
			
		}
		//only eval if dungeon is valid
		scr_eval_print_dungeon_metrics();// print evaluation
		scr_eval_csv_dungeon_metrics();
		
		
		
	    var start_k = "0,0";
        if (!ds_map_exists(global.room_doors, start_k))
            ds_map_add(global.room_doors, start_k, 0);

        scr_build_room(id);
        scr_room_on_enter();

        // Tell the rest of the game we can start moving/acting
        global.run_started = true;
        global.pending_generate = false;

        // Re-init player position cleanly
        var p = instance_find(obj_player, 0);
        if (instance_exists(p))
        {
            p.needs_grid_init = true;
            p.moving = false;
        }
    }

    exit; // don't do anything else this frame
}