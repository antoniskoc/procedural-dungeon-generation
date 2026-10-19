function scr_wfc_propagate_from(_start_key)
{
    var q = ds_queue_create();
    ds_queue_enqueue(q, _start_key);

    /// : don't use ds_queue_is_empty 
    while (ds_queue_size(q) > 0)
    {
        var k = ds_queue_dequeue(q);
        var xy = scr_wfc_key_to_xy(k);
        var tx = xy[0], ty = xy[1];

        for (var dir = 0; dir < 4; dir++)
        {
			
			//forward propagation (tx,ty) -> neightbour
            var changed_fwd = scr_wfc_reduce_neighbor(tx, ty, dir);

            if (changed_fwd == -1)
            {
                ds_queue_destroy(q);
                return false;
            }

            if (changed_fwd == 1)
            {
                var nk_fwd = scr_wfc_key(tx + global.wfc_dx[dir], ty + global.wfc_dy[dir]);
                ds_queue_enqueue(q, nk_fwd);
            }
			
			
			// backwards propagation neightbor -> (tx,ty)
			// This is a fix for 90 rooms brnachy
			
			var ntx = tx + global.wfc_dx[dir];
            var nty = ty + global.wfc_dy[dir];
            var nkey = scr_wfc_key(ntx, nty);
			//only reverse check if neighbor in layout
			
			if (ds_map_exists(global.wfc_domain,nkey))
			{
				var opp = (dir +2) & 3;
				
				//neighbor constraint current
				var changed_back = scr_wfc_reduce_neighbor(ntx,nty,opp);
				
				if(changed_back == -1)
				{
					
					ds_queue_destroy(q);
					return false;
				}
				if (changed_back == 1)
				{
					//current domain changed  -> re-proces key
					ds_queue_enqueue(q,k);
					
					
					
					
				}
				
			}
        }
    }

    ds_queue_destroy(q);
    return true;
}