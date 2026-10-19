function scr_wfc_set_style(_style){
// sets global wfc parameter based on the chosen style 
//0 = corridors
//1 = Branchy
//2 = Vertical
global.wfc_style = _style;

global.wfc_weight_scale = 100;// multiply weights by this

global.wfc_growth_multi = 2; // how stringly we prefer growth (more doors leading to more rooms)

global.wfc_loopiness = 0.0; // 0 = avoid loops , 1 = incentivise loops
global.wfc_straight_bonus = 0.0;

 global.wfc_w_deadend  = 1.0;
 global.wfc_w_corridor = 1.0;
 global.wfc_w_corner   = 1.0;
 global.wfc_w_t        = 1.0;
 global.wfc_w_cross    = 1.0;// default weights for archetypes of room
 
 //vertical bias gives weight to rooms with North and South Facing doors more 
 global.wfc_vert_bias = 0.0;


// To fix big rooms not loading
 global.wfc_loop_start_rooms  = 30;    // loops start only after we have this many rooms
 global.wfc_finish_rooms      = 12;    // last N rooms = "endgame cap mode"
 global.wfc_finish_penalty    = 3.0;   // penalize options that create new rooms during endgame

 
 //Style Prestest
 if(_style == 0) // CORRIDOR
 {
	 global.wfc_style_name ="CORRIDOR";
	 
	 global.wfc_growth_mult = 2.5;	
	 global.wfc_growth_multi = global.wfc_growth_mult;
	 
	 global.wfc_w_deadend = 1.0;
	 global.wfc_w_corridor = 5.0;
	 global.wfc_w_corner   = 0.35;
     global.wfc_w_t        = 0.2;
     global.wfc_w_cross    = 0.1;
	 
	 global.wfc_vert_bias = 0.0;
	 
	 global.wfc_straight_bonus = 2.5;
	 global.wfc_loopiness = 0.05;
	 
	  global.wfc_loop_start_rooms  = 40;    
      global.wfc_finish_rooms      = 14;    
      global.wfc_finish_penalty    = 4.0;
	 
 }
 else if (_style == 1) // BRANCHYY
 {
	 global.wfc_style_name ="BRANCHY";
	 
	 global.wfc_growth_mult = 2.5;	
	 global.wfc_growth_multi = global.wfc_growth_mult;
	 
	 global.wfc_w_deadend = 1.2;
	 global.wfc_w_corridor = 1.0;
	 global.wfc_w_corner   = 1.0;
     global.wfc_w_t        = 2.0;
     global.wfc_w_cross    = 1.8;
	 
	 global.wfc_vert_bias = 0.0;
	 global.wfc_loopiness = 0.60;
	 
	 global.wfc_straight_bonus = 0.0;
	 
	  global.wfc_loop_start_rooms  = 30;    
      global.wfc_finish_rooms      = 18;    
      global.wfc_finish_penalty    = 5.0;
	 

 }
 
  else if (_style == 2) // Vertical
 {
	  global.wfc_style_name = "VERTICAL";

        global.wfc_growth_mult = 2.0;

        global.wfc_w_deadend  = 1.0;
        global.wfc_w_corridor = 2.0;
        global.wfc_w_corner   = 1.0;
        global.wfc_w_t        = 1.4;
        global.wfc_w_cross    = 0.8;

 
        global.wfc_vert_bias  = 0.7;// will prefer n/s doors over e/w
		global.wfc_loopiness = 0.35;
		
		global.wfc_straight_bonus = 0.0;
		
	  global.wfc_loop_start_rooms  = 25;    
      global.wfc_finish_rooms      = 14;    
      global.wfc_finish_penalty    = 4.0;
	 
 }

}