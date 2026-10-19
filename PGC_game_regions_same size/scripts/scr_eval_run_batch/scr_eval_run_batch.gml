function scr_eval_run_batch(_runs_per_style){
	
	// Batch evaluation run
	// - reset CSV file
	// for each style, collect exactly _runs_per_style valid dungeons
	// write one row of data per dungeon
	// adds seeds for dungeons
scr_eval_reset_csv();
show_debug_message(" BATCH RVAL START:" + string(_runs_per_style) + "per style");

//base seed to reproduce batches
var base_seed = (get_timer() div 1000) mod 2147483647;
var MAX_TRIES_PER_STYLE = _runs_per_style * 300; // safety cap for not looping forever

for (var style =0; style <3; style++)
{
	//set style
	scr_wfc_set_style(style);
	
	show_debug_message("STYLE" + string(style) + string(global.wfc_style_name));
	var kept =0;
	var tries =0;
	
	while(kept < _runs_per_style && tries < MAX_TRIES_PER_STYLE)
	{
		tries++;
		// Create a deterministic seed run
		var seed  = (base_seed + style * 100000 + tries) mod 2147483647;
		
		global.last_gen_seed = seed;
		random_set_seed(seed);
		
		// Generate dungeon 
		var ok= scr_generate_new_dungeon()
		if(!ok)
		{
			if((tries mod 25) == 0)
			{
				  show_debug_message("[BATCH] still searching... kept=" + string(kept) +
                                       " tries=" + string(tries) +
                                       " style=" + string(global.wfc_style_name));
			}
			continue;
			
		}
		
		//save to csv
		scr_eval_csv_dungeon_metrics();
		kept++;
		  show_debug_message("[BATCH] kept " + string(kept) + "/" + string(_runs_per_style) +
                               " | seed=" + string(seed) +
                               " | style=" + string(global.wfc_style_name) +
                               " | rooms=" + string(ds_map_size(global.room_doors)));
		
	}
	if(kept <_runs_per_style)
	{
		  show_debug_message("[BATCH] WARNING: only collected " + string(kept) +
                               "/" + string(_runs_per_style) +
                               " for style " + string(global.wfc_style_name) +
                               " after " + string(tries) + " tries.");
		
	}
}
show_debug_message(string(_runs_per_style)+ " DUNGEONS BATCH DONE" );
}