function scr_wfc_style_weight_for_mask(_mask){
	
	// returns the weight multiplier for a door mask
	// mask is clasified by the door amount and position
	
	var doors = scr_bits_count(_mask);
	
	var w_class = 1.0;
	
	if (doors ==1){
		w_class = global.wfc_w_deadend;
		
	}
	else if(doors == 2){
		var is_corridor = false;

        if (_mask == ((1 << 0) | (1 << 2))) is_corridor = true; // N-S
        if (_mask == ((1 << 1) | (1 << 3))) is_corridor = true; // E-W
		
		if (is_corridor == true) w_class = global.wfc_w_corridor;
		else w_class = global.wfc_w_corner;
	}
	else if (doors == 3)
    {
        w_class = global.wfc_w_t;
    }
    else if (doors == 4)
    {
        w_class = global.wfc_w_cross;
    }


// count up the "operation bias" (count up vertical and horizontal doors

    var v = 0;
    var h = 0;

    if (_mask & (1 << 0)) v += 1; // N
    if (_mask & (1 << 2)) v += 1; // S
    if (_mask & (1 << 1)) h += 1; // E
    if (_mask & (1 << 3)) h += 1; // W

    var orient = 1.0 + global.wfc_vert_bias * (v - h);

    // Clamp so it never becomes 0 or negative
    if (orient < 0.1) orient = 0.1;

    return w_class * orient;

}