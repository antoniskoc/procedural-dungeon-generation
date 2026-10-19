function scr_enemy_wfc_generate(_room_key, _target)
{
    var gen = global.levelgen_id;
    var out = ds_list_create();
    if (!instance_exists(gen)) return out;

    var gw = gen.grid_w;
    var gh = gen.grid_h;

    // states
    var S_EMPTY = 0;
    var S_SLIME = 1;
    var S_BAT   = 2;

    var D_EMPTY = (1 << S_EMPTY);
    var D_SLIME = (1 << S_SLIME);
    var D_BAT   = (1 << S_BAT);
    var D_ALL   = D_EMPTY | D_SLIME | D_BAT;

    // safe zone around center (3x3)
    var cx = gw div 2;
    var cy = gh div 2;

    var ATTEMPTS = 60;

    var dom = ds_grid_create(gw, gh);
    var st  = ds_grid_create(gw, gh);

    var cand_tx = [];
    var cand_ty = [];

    repeat (ATTEMPTS)
    {
        ds_list_clear(out);

        // init domains/states
        for (var ty = 0; ty < gh; ty++)
        for (var tx = 0; tx < gw; tx++)
        {
            var spawnable =
                (tx > 0 && tx < gw - 1 && ty > 0 && ty < gh - 1) &&
                (gen.map[# tx, ty] == gen.CELL_FLOOR);

            if (abs(tx - cx) <= 1 && abs(ty - cy) <= 1) spawnable = false;

            if (!spawnable)
            {
                dom[# tx, ty] = D_EMPTY;
                st[# tx, ty]  = S_EMPTY;
            }
            else
            {
                dom[# tx, ty] = D_ALL;
                st[# tx, ty]  = -1;
            }
        }

        var placed = 0;
        var ok = true;
        var safety = 8000;

        while (safety-- > 0)
        {
            // random tie-break among minimum entropy tiles
            var best_e = 999999;
            var cand_n = 0;

            for (var ty2 = 1; ty2 < gh - 1; ty2++)
            for (var tx2 = 1; tx2 < gw - 1; tx2++)
            {
                if (st[# tx2, ty2] != -1) continue;

                var d = dom[# tx2, ty2];
                var e = scr_bits_count(d);

                if (e == 0) { ok = false; break; }

                if (e < best_e)
                {
                    best_e = e;
                    cand_n = 0;
                    cand_tx[0] = tx2;
                    cand_ty[0] = ty2;
                    cand_n = 1;
                }
                else if (e == best_e)
                {
                    cand_tx[cand_n] = tx2;
                    cand_ty[cand_n] = ty2;
                    cand_n++;
                }
            }

            if (!ok) break;
            if (cand_n == 0) break;

            var pick_i = irandom(cand_n - 1);
            var best_tx = cand_tx[pick_i];
            var best_ty = cand_ty[pick_i];

            var d0 = dom[# best_tx, best_ty];
            var e0 = scr_bits_count(d0);

            var pick_state = S_EMPTY;

            if (e0 == 1)
            {
                if (d0 & D_SLIME) pick_state = S_SLIME;
                else if (d0 & D_BAT) pick_state = S_BAT;
                else pick_state = S_EMPTY;
            }
            else
            {
                // While we still need enemies, choose SLIME vs BAT with weights.
                var bat_chance = 3;   // out of 10
                var slime_chance = 7; // out of 10

                if (placed < _target && ((d0 & D_SLIME) || (d0 & D_BAT)))
                {
                    var r = irandom(9);

                    // choose bat sometimes
                    if (r < bat_chance && (d0 & D_BAT)) pick_state = S_BAT;
                    else if (d0 & D_SLIME) pick_state = S_SLIME;
                    else pick_state = S_EMPTY;

                    // if chosen not allowed, fall back
                    if (!(d0 & (1 << pick_state)))
                    {
                        if (d0 & D_SLIME) pick_state = S_SLIME;
                        else if (d0 & D_BAT) pick_state = S_BAT;
                        else pick_state = S_EMPTY;
                    }
                }
                else
                {
                    // prefer empty once we placed enough
                    pick_state = S_EMPTY;
                    if (!(d0 & D_EMPTY)) { ok = false; break; }
                }
            }

            // collapse
            st[# best_tx, best_ty]  = pick_state;
            dom[# best_tx, best_ty] = (1 << pick_state);

            // count enemies (slime or bat)
            if (pick_state == S_SLIME || pick_state == S_BAT)
            {
                placed++;
                if (placed > _target) { ok = false; break; }

                // propagate: neighbors must be empty (no adjacency between any enemies)
                var ntx, nty, old, neu;

                // N
                ntx = best_tx; nty = best_ty - 1;
                if (nty >= 0 && st[# ntx, nty] == -1)
                {
                    old = dom[# ntx, nty];
                    neu = old & D_EMPTY;
                    if (neu == 0) { ok = false; break; }
                    dom[# ntx, nty] = neu;
                }

                // S
                ntx = best_tx; nty = best_ty + 1;
                if (nty < gh && st[# ntx, nty] == -1)
                {
                    old = dom[# ntx, nty];
                    neu = old & D_EMPTY;
                    if (neu == 0) { ok = false; break; }
                    dom[# ntx, nty] = neu;
                }

                // E
                ntx = best_tx + 1; nty = best_ty;
                if (ntx < gw && st[# ntx, nty] == -1)
                {
                    old = dom[# ntx, nty];
                    neu = old & D_EMPTY;
                    if (neu == 0) { ok = false; break; }
                    dom[# ntx, nty] = neu;
                }

                // W
                ntx = best_tx - 1; nty = best_ty;
                if (ntx >= 0 && st[# ntx, nty] == -1)
                {
                    old = dom[# ntx, nty];
                    neu = old & D_EMPTY;
                    if (neu == 0) { ok = false; break; }
                    dom[# ntx, nty] = neu;
                }
            }
        }

        if (ok && placed == _target)
        {
            for (var ty3 = 1; ty3 < gh - 1; ty3++)
            for (var tx3 = 1; tx3 < gw - 1; tx3++)
            {
                if (st[# tx3, ty3] == S_SLIME)
                    ds_list_add(out, { type: 1, tx: tx3, ty: ty3 });

                if (st[# tx3, ty3] == S_BAT)
                    ds_list_add(out, { type: 2, tx: tx3, ty: ty3 });
            }

            ds_grid_destroy(dom);
            ds_grid_destroy(st);
            return out;
        }
    }

    ds_grid_destroy(dom);
    ds_grid_destroy(st);
    return out;
}