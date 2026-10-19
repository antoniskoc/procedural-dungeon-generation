if(global.key_collected)
{
	
	instance_destroy();
	exit;
}
// find the player
var p = instance_find(obj_player, 0);

if(!instance_exists(p))
{
exit;	
}

//check if player is standing on tile

if(p.tile_x == tile_x && p.tile_y == tile_y)
{
	// mark key as collected
	global.key_collected	 = true;
	//give permission to open locked gateway
	global.player_has_key = true;
	show_debug_message("[KEY] Picked up gateway key.");

    instance_destroy();
	
}