function scr_region_propagate_from(_start_key, _region_map){
  // Propagates WFC constriants through a region
  // when one rooms domain changes, neightbouring rooms may need to remove incompatible archetypes from their domian
  //_start_key: the room where propagation begins
  //_region_map: A ds_map containing only the rooms in the region
  
  var dx = [0, 1, 0, -1];
  var dy = [-1, 0, 1, 0];
  
  var q = ds_queue_create();// Queue for rooms whose neightbors need to be checked
  
  ds_queue_enqueue(q, _start_key);
  
  while(ds_queue_size(q)> 0)
  {
	  
	    var cur_k = ds_queue_dequeue(q);

        var cur_xy = scr_room_xy_from_key(cur_k);
        var cur_x = cur_xy[0];
        var cur_y = cur_xy[1];

     
        for (var dir = 0; dir < 4; dir++)
        {
            var nx = cur_x + dx[dir];
            var ny = cur_y + dy[dir];

            var nk = scr_room_key_from_xy(nx, ny);

            // Only propagate into rooms that belong to this region
            if (!ds_map_exists(_region_map, nk))
            {
                continue;
            }

            var opp = (dir + 2) & 3;

            // Reduce neighbour domain based on current room.
            var changed = scr_region_reduce_neighbor(cur_k, nk, dir, opp);

            // If reduction causes no valid options, WFC failed.
            if (changed == -1)
            {
                ds_queue_destroy(q);
                return false;
            }

            // If the neighbour's domain changed, its neighbours may also need to be updated
            if (changed == 1)
            {
                ds_queue_enqueue(q, nk);
            }
        }
    }

    ds_queue_destroy(q);

    return true;
}