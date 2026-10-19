function scr_dir_between_rooms(_from_k,_to_k){
	//convert first and second room keys from "x,y" to array [x,y]
    var a = scr_room_xy_from_key(_from_k);
    var b = scr_room_xy_from_key(_to_k);
	
	var ax = a[0];
    var ay = a[1];

    var bx = b[0];
    var by = b[1];


//Same X means , one room above

    if (bx == ax && by == ay - 1)
    {
        return 0; // North
    }
	
	 // Same y One room to the right
    if (bx == ax + 1 && by == ay)
    {
        return 1; // East
    }
	
	 // Same x, one room below
    if (bx == ax && by == ay + 1)
    {
        return 2; // South
    }
	
	 // One room to the left
    if (bx == ax - 1 && by == ay)
    {
        return 3; // West
    }
	
	  // If none of the above matched, the rooms are not direct neighbours.
    return -1;

}