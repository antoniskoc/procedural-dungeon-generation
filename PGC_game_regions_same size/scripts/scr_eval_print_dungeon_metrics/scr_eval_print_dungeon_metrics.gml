function scr_eval_print_dungeon_metrics(){
	//prints evaluation metrics from the dunegon using global variables
	// metrics rooms(V), edges(E), components(C) loops(E -V +C), deadends, shortest path from start to end, archetype class counts(deadends,corridors,corners,T,junctions), bounding box
	
	 if (!ds_exists(global.room_doors, ds_type_map))
    {
        show_debug_message("[EVAL] room_doors missing");
        exit;
    }

    var V = ds_map_size(global.room_doors);
	if (V<=0)
	{
		show_debug_message( "[EVAL] no rooms created");
		exit;
	}
	
	//directions
	var DIR_N = 0;
    var DIR_E = 1;
    var DIR_S = 2;
    var DIR_W = 3;

    var dx = [0, 1, 0, -1];
    var dy = [-1, 0, 1, 0];
	
	//bound for generated graph
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
 //boundry box
 var box_w = (max_rx - min_rx + 1);
 var box_h = (max_ry - min_ry +1);
 var density = V / max(1, box_w * box_h);
 
 // count edges and degree
 // degree counted using all 4 directions
 
 var E =0;
 
 var deg_sum =0;
 var deg_max =0;
 
 
  var dead_ends = 0;
  var corridors = 0;
  var junction3 = 0;
  var junction4 = 0;
  
  
  //archetype class count
  var cnt_deadend = 0;
  var cnt_corridor = 0; // 2 opposite dirs
  var cnt_corner = 0;   // 2 adjacent dirs
  var cnt_cross = 0;
  var cnt_T = 0;
  
  k = ds_map_find_first(global.room_doors);
  while (!is_undefined(k))
  {
	  var xy2 = scr_room_xy_from_key(k);
	  var rx2 = xy2[0];
	  var ry2 = xy2[1];
	  
	  var mask = ds_map_find_value(global.room_doors, k);
	  // archetype class(by door count)
	  var doors = scr_bits_count(mask);
	  if(doors == 1) cnt_deadend++;
	  else if (doors ==2){
		  //opposite coridors
		  if(mask == ((1<<DIR_N) | (1<<DIR_S)) || mask == ((1<<DIR_E) | (1<<DIR_W)))
		    cnt_corridor++
		  else cnt_corner++;
		  
	  }
	  else if (doors ==3) cnt_T++;
	  else if(doors ==4) cnt_cross++;
	  // degree(valid connections only)
	  var deg =0;
	  
	  for(var dir =0; dir <4; dir++)
	  {
		 if ((mask & (1 << dir)) == 0) continue;
		 
		 var nrx = rx2 + dx[dir];
		 var nry = ry2 + dy[dir];
		 var nk = scr_room_key_from_xy(nrx, nry);
		 
		 if (!ds_map_exists(global.room_doors, nk)) continue;
		 
		 var nmask = ds_map_find_value(global.room_doors,nk);
		 
		 var opp = (dir+2) & 3; // oposite directions
		 if ((nmask & (1 << opp)) == 0) continue;
		 
		 deg++;
		  
	  }
	  deg_sum +=deg;
	  if(deg > deg_max) deg_max =deg;
	  
	  if(deg ==1) dead_ends++;
	  else if (deg ==2) corridors++;
	  else if (deg ==3) junction3++;
	  else if (deg ==4) junction4++;
	  
	  //edge count unidirected to avoid double counting only chek EAST and SOUTH
	  
	  //east
	  if(mask &(1<<DIR_E))
	  {
		  var ek = scr_room_key_from_xy(rx2+1,ry2);
		  if (ds_map_exists(global.room_doors,ek))
		  {
			  var em = ds_map_find_value(global.room_doors,ek);
			  if (em & (1 << DIR_W)) E++;
		  }
		  
	  }
	  //south
	  if(mask &(1<<DIR_S))
	  {
		  var sk = scr_room_key_from_xy(rx2,ry2+1);
		  if (ds_map_exists(global.room_doors,sk))
		  {
			  var sm = ds_map_find_value(global.room_doors,sk);
			  if (sm & (1 << DIR_N)) E++;
		  }
		  
	  }
	   k = ds_map_find_next(global.room_doors, k);
  }
  var avg_deg = deg_sum / max(1,V);
  
  // COMPONENTS (C) using BFS over rooms
  
  var visited = ds_map_create();
  var C = 0;
  
  k = ds_map_find_first(global.room_doors);
  while (!is_undefined(k))
  {
	  if (!ds_map_exists(visited, k))
	  {
		  C++;
		  
		  var q = ds_queue_create();
		  ds_queue_enqueue(q,k);
		  ds_map_add(visited,k,1);
		  
		  while (!ds_queue_empty(q))
		  {
			  var ck = ds_queue_dequeue(q);
			  var cxy = scr_room_xy_from_key(ck);
			  var crx = cxy[0];
			  var cry = cxy[1];
			  
			  var cmask = ds_map_find_value(global.room_doors, ck);
			  
			  
			  for (var dirc = 0; dirc < 4; dirc++)
			  {
				  
				  if((cmask & (1 << dirc))  ==0) continue;
				  
				  var nrx2 = crx +dx[dirc];
				  var nry2 = cry +dy[dirc];
				  var nk2 = scr_room_key_from_xy(nrx2,nry2);
				  
				  if (!ds_map_exists(global.room_doors, nk2)) continue;
				  
				  var nmask2 = ds_map_find_value(global.room_doors, nk2);
				  var opp2 = (dirc+2)&3;
				  if ((nmask2 * (1 << opp2)) == 0)continue;
				  
				  if (!ds_map_exists(visited, nk2))
				  {
					  ds_map_add(visited, nk2,1);
					  ds_queue_enqueue(q, nk2);
					  
					  
				  }
				  
				  
			  }
			  
		  }
		  ds_queue_destroy(q);
		  
	  }
	  
	  k =ds_map_find_next(global.room_doors,k);
  }
  ds_map_destroy(visited);
  
  
  //LOOPS - for connected graphs , loops = E -V+1
  
  var loops = E - V +C;
  if(loops <0) loops =0;
  
  //SHORTEST PATH FROM START TO FINISH
  
  var start_k = "0,0";
  if(!ds_map_exists(global.room_doors, start_k))
  {
	  //fallback first room key
	  start_k = ds_map_find_first(global.room_doors);
  }
  var end_k = "";
  if (variable_global_exists("end_room_k")) end_k = global.end_room_k;
  
  var dist_to_end = -1;
  //BFS dist from map start
  var dist = ds_map_create();
  var q2 = ds_queue_create();
  
  ds_map_add(dist, start_k, 0);
  ds_queue_enqueue(q2,start_k);
  
  while(	!ds_queue_empty(q2))
  {
	  var ck2 = ds_queue_dequeue(q2);
	  var dcur = ds_map_find_value(dist, ck2);
	  
	  if(end_k != "" && ck2 == end_k)
	  {
		  dist_to_end =dcur;
		  break;
		  
	  }
	  var cxy2 = scr_room_xy_from_key(ck2);
	  var crx2 = cxy2[0];
	  var cry2 = cxy2[1];
	  
	  var cm = ds_map_find_value(global.room_doors, ck2);
	  
	  for (var dir3 = 0; dir3 <4; dir3++){
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
  
  
  //DIAMETER: BFS from every node and take max dist
  
  var diameter =0;
  
  //build a list of keys for easy loops
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
	
	
	// PRINT RESULTS !!
	
	var style_name = "";
	if(variable_global_exists("wfc_style_name")) style_name = global.wfc_style_name;
	
	
	show_debug_message("========== DUNGEON METRICS ==========");
	show_debug_message("Style: " + string(style_name));
	show_debug_message("Rooms(V): " + string(V));
	show_debug_message("Edges(E): " + string(E));
	show_debug_message("Components(C): " + string(C));
	show_debug_message("Loops (E - V + C): " + string(loops));
    show_debug_message("Dead ends (deg=1): " + string(dead_ends));
    show_debug_message("Avg degree: " + string(avg_deg) + " | Max degree: " + string(deg_max));
    show_debug_message("Junctions deg=3: " + string(junction3) + " | deg=4: " + string(junction4));
    show_debug_message("Bounding box: " + string(box_w) + " x " + string(box_h) + " | Density: " + string(density));
	
	 if (end_k != "")
        show_debug_message("Fastest path start->exit (rooms): " + string(dist_to_end));
    else
        show_debug_message("Fastest path start->exit: (no end_room_k set)");

    show_debug_message("Diameter (max shortest path): " + string(diameter));

    show_debug_message("Room type counts:");
    show_debug_message("- dead ends: " + string(cnt_deadend));
    show_debug_message("- corridors: " + string(cnt_corridor));
    show_debug_message("- corners:   " + string(cnt_corner));
    show_debug_message("- T-junction:" + string(cnt_T));
    show_debug_message("- 4-way:     " + string(cnt_cross));
    show_debug_message("====================================");
	

}