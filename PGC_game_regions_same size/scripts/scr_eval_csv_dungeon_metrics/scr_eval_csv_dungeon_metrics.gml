function scr_eval_csv_dungeon_metrics(){
	//returns a struct with all dunegon metrics
	
	
	var m = {
		style_name: "",
		style_id: -1,
		seed: -1,
		max_rooms: -1,
		
		V:0,E:0,C:0,loops:0,
		
		dead_ends: 0,
		avg_deg: 0,
		max_deg: 0,
		junction3: 0,
		junction4: 0,
		
		dead_ends: 0,
        avg_deg: 0,
        max_deg: 0,
        junction3: 0,
        junction4: 0,

        box_w: 0,
        box_h: 0,
        density: 0,

        dist_to_exit: -1,
        diameter: 0,

        cnt_deadend: 0,
        cnt_corridor: 0,
        cnt_corner: 0,
        cnt_T: 0,
        cnt_cross: 0
		
		
		
	};
	if (variable_global_exists("wfc_style_name")) m.style_name = global.wfc_style_name;
    if (variable_global_exists("wfc_style")) m.style_id = global.wfc_style;
    if (variable_global_exists("last_gen_seed")) m.seed = global.last_gen_seed;
    if (variable_global_exists("max_rooms")) m.max_rooms = global.max_rooms;
	
	  if (!ds_exists(global.room_doors, ds_type_map)) return m;
	  
	  var V = ds_map_size(global.room_doors);
	  m.V = V;
	  
	  if (V <= 0) return m;
	  
	  //directions
	  var DIR_N =0, DIR_E =1, DIR_S =2, DIR_W =3;
	  var dx = [0,1,0,-1];
	  var dy = [-1,0,1,0];
	  
	  // bounding box
	  
	     var min_rx =  999999;
         var max_rx = -999999;
         var min_ry =  999999;
         var max_ry = -999999;


    var k = ds_map_find_first(global.room_doors);
    while (!is_undefined(k))
    {
        var xy = scr_room_xy_from_key(k);
        var rx = xy[0];
        var ry = xy[1];

        if (rx < min_rx) min_rx = rx;
        if (rx > max_rx) max_rx = rx;
        if (ry < min_ry) min_ry = ry;
        if (ry > max_ry) max_ry = ry;

        k = ds_map_find_next(global.room_doors, k);
    }
	
	var box_w = (max_rx - min_rx +1);
	var box_h = (max_ry - min_ry+1);
	
	m.box_h = box_h;
	m.box_w = box_w;
	m.density = V/max(1, box_w * box_h);
	
	//edge count + degrees + archetype
	var E =0;
	var deg_sum =0;
	var deg_max =0;
	
	var dead_ends = 0;
    var junction3 = 0;
    var junction4 = 0;

    var cnt_deadend = 0;
    var cnt_corridor = 0;
    var cnt_corner = 0;
    var cnt_T = 0;
    var cnt_cross = 0;
	
	k = ds_map_find_first(global.room_doors);
	while(!is_undefined(k))
	{
		var xy2 = scr_room_xy_from_key(k);
		var rx2 = xy2[0];
		var ry2 = xy2[1];
		
		var mask = ds_map_find_value(global.room_doors, k);
		
		// archetype class
		var doors = scr_bits_count(mask);
		
		if(doors == 1) cnt_deadend++;
		else if (doors ==2)
		{
			if(mask == ((1<<DIR_N) | (1<<DIR_S)) || mask == ((1<<DIR_E) | (1<<DIR_W))) cnt_corridor++;
			else cnt_corner++;
		}
		else if (doors ==3) cnt_T++;
		else if (doors ==4) cnt_cross++;
		
		// Degree - valid mutual connections
		var deg = 0;
		
		for(var dir = 0; dir <4; dir ++)
		 {
            if ((mask & (1 << dir)) == 0) continue;

            var nrx = rx2 + dx[dir];
            var nry = ry2 + dy[dir];
            var nk = scr_room_key_from_xy(nrx, nry);

            if (!ds_map_exists(global.room_doors, nk)) continue;

            var nmask = ds_map_find_value(global.room_doors, nk);
            var opp = (dir + 2) & 3;
            if ((nmask & (1 << opp)) == 0) continue;

            deg++;
        }
		deg_sum += deg;
		if (deg > deg_max) deg_max = deg;
		
		if (deg == 1) dead_ends++;
		else if (deg ==3) junction3++;
		else if (deg ==4) junction4++;
		
		   //edges counted once: check EAST and SOUTH only
        if (mask & (1 << DIR_E))
        {
            var ek = scr_room_key_from_xy(rx2 + 1, ry2);
            if (ds_map_exists(global.room_doors, ek))
            {
                var em = ds_map_find_value(global.room_doors, ek);
                if (em & (1 << DIR_W)) E++;
            }
        }

        if (mask & (1 << DIR_S))
        {
            var sk = scr_room_key_from_xy(rx2, ry2 + 1);
            if (ds_map_exists(global.room_doors, sk))
            {
                var sm = ds_map_find_value(global.room_doors, sk);
                if (sm & (1 << DIR_N)) E++;
            }
        }

        k = ds_map_find_next(global.room_doors, k);
    }

    m.E = E;
    m.dead_ends = dead_ends;
    m.avg_deg = deg_sum / max(1, V);
    m.max_deg = deg_max;
    m.junction3 = junction3;
    m.junction4 = junction4;

    m.cnt_deadend = cnt_deadend;
    m.cnt_corridor = cnt_corridor;
    m.cnt_corner = cnt_corner;
    m.cnt_T = cnt_T;
    m.cnt_cross = cnt_cross;

    //Components C-
    var visited = ds_map_create();
    var C = 0;

    k = ds_map_find_first(global.room_doors);
    while (!is_undefined(k))
    {
        if (!ds_map_exists(visited, k))
        {
            C++;

            var q = ds_queue_create();
            ds_queue_enqueue(q, k);
            ds_map_add(visited, k, 1);

            while (!ds_queue_empty(q))
            {
                var ck = ds_queue_dequeue(q);
                var cxy = scr_room_xy_from_key(ck);
                var crx = cxy[0];
                var cry = cxy[1];

                var cmask = ds_map_find_value(global.room_doors, ck);

                for (var dirc = 0; dirc < 4; dirc++)
                {
                    if ((cmask & (1 << dirc)) == 0) continue;

                    var nrx2 = crx + dx[dirc];
                    var nry2 = cry + dy[dirc];
                    var nk2 = scr_room_key_from_xy(nrx2, nry2);

                    if (!ds_map_exists(global.room_doors, nk2)) continue;

                    var nmask2 = ds_map_find_value(global.room_doors, nk2);
                    var opp2 = (dirc + 2) & 3;
                    if ((nmask2 & (1 << opp2)) == 0) continue;

                    if (!ds_map_exists(visited, nk2))
                    {
                        ds_map_add(visited, nk2, 1);
                        ds_queue_enqueue(q, nk2);
                    }
                }
            }

            ds_queue_destroy(q);
        }

        k = ds_map_find_next(global.room_doors, k);
    }

    ds_map_destroy(visited);

    m.C = C;

    // Loops (
    var loops = E - V + C;
    if (loops < 0) loops = 0;
    m.loops = loops;

    // Shortest path from start to exit
    var start_k = "0,0";
    if (!ds_map_exists(global.room_doors, start_k))
        start_k = ds_map_find_first(global.room_doors);

    var end_k = "";
    if (variable_global_exists("end_room_k")) end_k = global.end_room_k;

    var dist_to_end = -1;

    if (end_k != "" && ds_map_exists(global.room_doors, end_k))
    {
        var dist = ds_map_create();
        var q2 = ds_queue_create();

        ds_map_add(dist, start_k, 0);
        ds_queue_enqueue(q2, start_k);

        while (!ds_queue_empty(q2))
        {
            var ck2 = ds_queue_dequeue(q2);
            var dcur = ds_map_find_value(dist, ck2);

            if (ck2 == end_k)
            {
                dist_to_end = dcur;
                break;
            }

            var cxy2 = scr_room_xy_from_key(ck2);
            var crx2 = cxy2[0];
            var cry2 = cxy2[1];

            var cm = ds_map_find_value(global.room_doors, ck2);

            for (var dir3 = 0; dir3 < 4; dir3++)
            {
                if ((cm & (1 << dir3)) == 0) continue;

                var nrx3 = crx2 + dx[dir3];
                var nry3 = cry2 + dy[dir3];
                var nk3 = scr_room_key_from_xy(nrx3, nry3);

                if (!ds_map_exists(global.room_doors, nk3)) continue;

                var nm3 = ds_map_find_value(global.room_doors, nk3);
                var opp3 = (dir3 + 2) & 3;
                if ((nm3 & (1 << opp3)) == 0) continue;

                if (!ds_map_exists(dist, nk3))
                {
                    ds_map_add(dist, nk3, dcur + 1);
                    ds_queue_enqueue(q2, nk3);
                }
            }
        }

        ds_queue_destroy(q2);
        ds_map_destroy(dist);
    }

    m.dist_to_exit = dist_to_end;

    // Diameter
    var diameter = 0;

    var keys = ds_list_create();
    k = ds_map_find_first(global.room_doors);
    while (!is_undefined(k))
    {
        ds_list_add(keys, k);
        k = ds_map_find_next(global.room_doors, k);
    }

    for (var si = 0; si < ds_list_size(keys); si++)
    {
        var src_k = ds_list_find_value(keys, si);

        var dist2 = ds_map_create();
        var q3 = ds_queue_create();

        ds_map_add(dist2, src_k, 0);
        ds_queue_enqueue(q3, src_k);

        var local_max = 0;

        while (!ds_queue_empty(q3))
        {
            var kk = ds_queue_dequeue(q3);
            var dd = ds_map_find_value(dist2, kk);
            if (dd > local_max) local_max = dd;

            var axy = scr_room_xy_from_key(kk);
            var arx = axy[0];
            var ary = axy[1];

            var am = ds_map_find_value(global.room_doors, kk);

            for (var dir4 = 0; dir4 < 4; dir4++)
            {
                if ((am & (1 << dir4)) == 0) continue;

                var brx = arx + dx[dir4];
                var bry = ary + dy[dir4];
                var bk = scr_room_key_from_xy(brx, bry);

                if (!ds_map_exists(global.room_doors, bk)) continue;

                var bm = ds_map_find_value(global.room_doors, bk);
                var opp4 = (dir4 + 2) & 3;
                if ((bm & (1 << opp4)) == 0) continue;

                if (!ds_map_exists(dist2, bk))
                {
                    ds_map_add(dist2, bk, dd + 1);
                    ds_queue_enqueue(q3, bk);
                }
            }
        }

        if (local_max > diameter) diameter = local_max;

        ds_queue_destroy(q3);
        ds_map_destroy(dist2);
    }

    ds_list_destroy(keys);

    m.diameter = diameter;

   // ============================================================

    // Create a subfolder in the save area
    if (!directory_exists("eval")) directory_create("eval");

    var use_path = "eval\\wfc_dungeon_metrics.csv";

    // Helpful debug so you know what folder name to look for
    show_debug_message("[CSV] Running sandboxed? " + string(GM_is_sandboxed));
    show_debug_message("[CSV] game_save_id = " + string(game_save_id));
    show_debug_message("[CSV] Saving CSV to SAVE AREA file: " + use_path);

    if (!file_exists(use_path))
    {
        var f0 = file_text_open_write(use_path);

   
        file_text_write_string(f0,
            "style_name,style_id,seed,max_rooms," +
            "V,E,C,loops,dead_ends,avg_deg,max_deg,junction3,junction4," +
            "box_w,box_h,density,dist_to_exit,diameter," +
            "cnt_deadend,cnt_corridor,cnt_corner,cnt_T,cnt_cross"
        );
        file_text_writeln(f0);

        file_text_close(f0);
        show_debug_message("[CSV] Created header + signature");
    }

    var f = file_text_open_append(use_path);

    var s_avg = string_replace(string(m.avg_deg), ",", ".");
    var s_den = string_replace(string(m.density), ",", ".");

    var line =
        string(m.style_name) + "," + string(m.style_id) + "," + string(m.seed) + "," + string(m.max_rooms) + "," +
        string(m.V) + "," + string(m.E) + "," + string(m.C) + "," + string(m.loops) + "," +
        string(m.dead_ends) + "," + s_avg + "," + string(m.max_deg) + "," +
        string(m.junction3) + "," + string(m.junction4) + "," +
        string(m.box_w) + "," + string(m.box_h) + "," + s_den + "," +
        string(m.dist_to_exit) + "," + string(m.diameter) + "," +
        string(m.cnt_deadend) + "," + string(m.cnt_corridor) + "," + string(m.cnt_corner) + "," +
        string(m.cnt_T) + "," + string(m.cnt_cross);

    file_text_write_string(f, line);
    file_text_writeln(f);
    file_text_close(f);

    show_debug_message("[CSV] Appended row (SAVE AREA). file_exists? " + string(file_exists(use_path)));

    return m;
}