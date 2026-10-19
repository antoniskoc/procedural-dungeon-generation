function scr_bfs_next_step(_sx, _sy, _gx, _gy, _occ)
{

    // BFS pathfinding (grid-based).
    // Returns the NEXT tile [nx, ny] to move from (sx,sy) toward (gx,gy).
    // Returns [-1, -1] if no path exists.

    // - Walkable tiles are CELL_FLOOR only (rocks/boulders/walls block)
    // - Other enemies block tiles (using _occ map), but goal is allowed
    // - Goal tile (player) is treated as "reachable" for path purposes


    var gen = global.levelgen_id;
    if (!instance_exists(gen)) return [-1, -1];

    var gw = gen.grid_w;
    var gh = gen.grid_h;

    // Bounds check
    if (_sx < 0 || _sy < 0 || _sx >= gw || _sy >= gh) return [-1, -1];
    if (_gx < 0 || _gy < 0 || _gx >= gw || _gy >= gh) return [-1, -1];

    // If already at goal, no move
    if (_sx == _gx && _sy == _gy) return [-1, -1];

    // parent grid stores where we came from:
    // 0 means "unset"
    var parent = ds_grid_create(gw, gh);
    var visited = ds_grid_create(gw, gh);

    ds_grid_clear(parent, 0);
    ds_grid_clear(visited, 0);

    var q = ds_queue_create();

    visited[# _sx, _sy] = 1;
    ds_queue_enqueue(q, _sx);
    ds_queue_enqueue(q, _sy);

    var found = false;

    // 4-neighborhood
    var ddx = [0, 1, 0, -1];
    var ddy = [-1, 0, 1, 0];

    while (!ds_queue_empty(q))
    {
        var tx = ds_queue_dequeue(q);
        var ty = ds_queue_dequeue(q);

        if (tx == _gx && ty == _gy)
        {
            found = true;
            break;
        }

        for (var dir = 0; dir < 4; dir++)
        {
            var nx = tx + ddx[dir];
            var ny = ty + ddy[dir];

            if (nx < 0 || ny < 0 || nx >= gw || ny >= gh) continue;
            if (visited[# nx, ny] == 1) continue;

            // Check occupancy (other enemies block), but allow goal tile
            if (!(nx == _gx && ny == _gy))
            {
                var key = string(nx) + "," + string(ny);
                if (ds_map_exists(_occ, key)) continue;
            }

            // Check tile walkability:
            // allow goal tile even if not floor (player stands on floor anyway)
            if (!(nx == _gx && ny == _gy))
            {
                if (gen.map[# nx, ny] != gen.CELL_FLOOR) continue;
            }

            visited[# nx, ny] = 1;
            parent[# nx, ny] = (tx + ty * gw) + 1;

            ds_queue_enqueue(q, nx);
            ds_queue_enqueue(q, ny);
        }
    }

    ds_queue_destroy(q);

    if (!found)
    {
        ds_grid_destroy(parent);
        ds_grid_destroy(visited);
        return [-1, -1];
    }

    var cur_tx = _gx;
    var cur_ty = _gy;

    while (true)
    {
        var p = parent[# cur_tx, cur_ty];
        if (p == 0)
        {
            // Shouldn't happen if found=true, but safety
            ds_grid_destroy(parent);
            ds_grid_destroy(visited);
            return [-1, -1];
        }

        var packed = p - 1;
        var prev_tx = packed mod gw;
        var prev_ty = packed div gw;

        // If the previous node is the start, current node is the next step.
        if (prev_tx == _sx && prev_ty == _sy)
        {
            ds_grid_destroy(parent);
            ds_grid_destroy(visited);
            return [cur_tx, cur_ty];
        }

        cur_tx = prev_tx;
        cur_ty = prev_ty;
    }
}