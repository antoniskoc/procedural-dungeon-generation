function scr_draw_minimap(_px, _py, _cell)
{


    // If globals like room_x/room_y don't exist yet, we default to 0.


    if (!ds_exists(global.room_doors, ds_type_map)) exit;
    if (ds_map_size(global.room_doors) == 0) exit;

    // safe defaults if not set yet
    var cur_rx = 0;
    var cur_ry = 0;

    if (variable_global_exists("room_x")) cur_rx = global.room_x;
    if (variable_global_exists("room_y")) cur_ry = global.room_y;

    //Find bounds of all rooms
    var min_rx = 999999;
    var max_rx = -999999;
    var min_ry = 999999;
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

    // Save draw state
    var old_col = draw_get_color();
    var old_a = draw_get_alpha();
    var old_h = draw_get_halign();
    var old_v = draw_get_valign();

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    // Draw rooms
    k = ds_map_find_first(global.room_doors);
    while (!is_undefined(k))
    {
        var xy2 = scr_room_xy_from_key(k);
        var rx2 = xy2[0];
        var ry2 = xy2[1];

        var mx = rx2 - min_rx;
        var my = ry2 - min_ry;

        var sx0 = _px + mx * _cell;
        var sy0 = _py + my * _cell;

       var is_second_side = false;
	   if(variable_global_exists("second_side_rooms"))
	   {
		   if(ds_exists(global.second_side_rooms,ds_type_map))
		   {
			   if(ds_map_exists(global.second_side_rooms,k))
			   {
				   is_second_side = true;
			   }
		   }
	   }
       draw_set_alpha(0.35);
	   
	   if (is_second_side)
	   {
		   draw_set_colour(make_colour_rgb(90,120,255));
	   }
	   else{
		   draw_set_color(c_dkgray);
	   }
	   draw_rectangle(sx0,sy0,sx0+ _cell, sy0 + _cell, false);
	   
	   draw_set_alpha(0.85);
	     if (is_second_side)
        {
            draw_set_color(make_color_rgb(170, 230, 255));
        }
        else
        {
            draw_set_color(c_gray);
        }

        draw_rectangle(sx0, sy0, sx0 + _cell, sy0 + _cell, true);

        k = ds_map_find_next(global.room_doors, k);
    }
  if(global.use_locked_gateway)
  {
	  if(variable_global_exists("gateway_room_k") && global.gateway_room_k != "")
	  {
		  var gxy = scr_room_xy_from_key(global.gateway_room_k);
		  var grx = gxy[0];
		  var gry = gxy[1];
		  
		  var g_mx = grx - min_rx;
		  var g_my = gry - min_ry;
		  
		  var gx0 = _px + g_mx * _cell;
		  var gy0 = _py + g_my * _cell;
		  
		  draw_set_alpha(1);
		  draw_set_color(c_orange);
          draw_rectangle(gx0 + 1, gy0 + 1, gx0 + _cell - 1, gy0 + _cell - 1, true);

          draw_set_color(c_orange);
          draw_text_transformed(gx0 + _cell * 0.5, gy0 + _cell * 0.5, "G", 0.70, 0.70, 0);
        }
    }
	// current room outline
	var cur_mx = cur_rx - min_rx;
    var cur_my = cur_ry - min_ry;

    var cx0 = _px + cur_mx * _cell;
    var cy0 = _py + cur_my * _cell;

    draw_set_alpha(1);
    draw_set_color(c_red);
    draw_rectangle(cx0, cy0, cx0 + _cell, cy0 + _cell, true);
    // Start "S"
    var s_mx = 0 - min_rx;
    var s_my = 0 - min_ry;

    var sx = _px + s_mx * _cell + _cell * 0.5;
    var sy = _py + s_my * _cell + _cell * 0.5;

    draw_set_color(c_lime);
    draw_text_transformed(sx, sy, "S", 0.70, 0.70, 0);

    // End "E" (only if set)
    if (variable_global_exists("end_room_k") && global.end_room_k != "")
    {
        var exy = scr_room_xy_from_key(global.end_room_k);
        var erx = exy[0];
        var ery = exy[1];

        var e_mx = erx - min_rx;
        var e_my = ery - min_ry;

        var ex = _px + e_mx * _cell + _cell * 0.5;
        var ey = _py + e_my * _cell + _cell * 0.5;

        draw_set_color(c_yellow);
        draw_text_transformed(ex, ey, "E", 0.70, 0.70, 0);
    }
	//Key room marker
	if(global.use_locked_gateway)
	{
		if(!global.key_collected)
		{
			if(variable_global_exists("key_room_k")&& global.key_room_k != "")
			{
				var kxy = scr_room_xy_from_key(global.key_room_k);
				var krx = kxy[0];
				var kry = kxy[1];
				
				var k_mx = krx - min_rx;
				var k_my = kry - min_ry;
				
				var kx = _px + k_mx * _cell + _cell*0.5;
				var ky = _py + k_my * _cell + _cell*0.5;
				
				draw_set_colour(c_aqua);
				draw_text_transformed(kx,ky,"K", 0.70,0.70,0);
			}
		}
	}

    // Restore draw state
    draw_set_halign(old_h);
    draw_set_valign(old_v);
    draw_set_alpha(old_a);
    draw_set_color(old_col);
}