function scr_eval_reset_csv(){
	// CSV in save area
	if (!directory_exists("eval")) directory_create("eval");
	
	var path = "eval\\wfc_dungeon_metrics.csv";
	
	//delete old file if it exists
	if (file_exists(path)) file_delete(path);
	
	//recreate the header
	var f = file_text_open_write(path);
	file_text_write_string(f,
        "style_name,style_id,seed,max_rooms," +
        "V,E,C,loops,dead_ends,avg_deg,max_deg,junction3,junction4," +
        "box_w,box_h,density,dist_to_exit,diameter," +
        "cnt_deadend,cnt_corridor,cnt_corner,cnt_T,cnt_cross"
    );
	
	file_text_writeln(f);
	file_text_close(f);
	
	show_debug_message("CSV RESET" + path);

}