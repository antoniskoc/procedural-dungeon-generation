function scr_enemies_take_turn()
{
    if (variable_global_exists("game_over") && global.game_over) exit;

    var gen = global.levelgen_id;
    if (!instance_exists(gen)) exit;

    var ply = instance_find(obj_player, 0);
    if (!instance_exists(ply)) exit;

    var ptx = ply.tile_x;
    var pty = ply.tile_y;

    // Occupancy map so enemies don't stack
    var occ = ds_map_create();
    with (obj_enemy_parent)
    {
        ds_map_replace(occ, string(tile_x) + "," + string(tile_y), id);
    }


    with (obj_enemy_bat)
    {
        intent_valid = false;
        intent_dx = 0;
        intent_dy = 0;
        intent_len = 0;

        if (moving) { }
        else
        {
            // REST
            if (bat_state == 2)
            {
                bat_rest_turns -= 1;
                if (bat_rest_turns <= 0)
                {
                    bat_rest_turns = 0;
                    bat_state = 0;
                }
            }
            // DASH
            else if (bat_state == 1)
            {
                var stx = tile_x;
                var sty = tile_y;

                var dx = plan_dx;
                var dy = plan_dy;
                var planned_len = plan_len;

                if ((dx == 0 && dy == 0) || planned_len <= 0)
                {
                    bat_state = 2;
                    bat_rest_turns = 1;
                }
                else
                {
                    // Damage if player is on trajectory (any step)
                    var hit_player = false;
                    for (var step_i = 1; step_i <= planned_len; step_i++)
                    {
                        var txp = stx + dx * step_i;
                        var typ = sty + dy * step_i;
                        if (txp == ptx && typ == pty) { hit_player = true; break; }
                    }
                    if (hit_player) scr_player_take_damage(1);

                    // Land as far as possible on FLOOR (fly over obstacles)
                    var actual_len = 0;

                    for (var step2 = planned_len; step2 >= 1; step2--)
                    {
                        var cand_tx = stx + dx * step2;
                        var cand_ty = sty + dy * step2;

                        if (cand_tx <= 0 || cand_ty <= 0 || cand_tx >= gen.grid_w - 1 || cand_ty >= gen.grid_h - 1) continue;
                        if (cand_tx == ptx && cand_ty == pty) continue;

                        var key = string(cand_tx) + "," + string(cand_ty);
                        var self_k = string(stx) + "," + string(sty);
                        if (key != self_k && ds_map_exists(occ, key)) continue;

                        if (gen.map[# cand_tx, cand_ty] != gen.CELL_FLOOR) continue;

                        actual_len = step2;
                        break;
                    }

                    if (actual_len <= 0)
                    {
                        bat_state = 2;
                        bat_rest_turns = 1;
                        plan_dx = 0; plan_dy = 0; plan_len = 0;
                    }
                    else
                    {
                        var dest_tx = stx + dx * actual_len;
                        var dest_ty = sty + dy * actual_len;

                        ds_map_delete(occ, string(stx) + "," + string(sty));
                        ds_map_replace(occ, string(dest_tx) + "," + string(dest_ty), id);

                        tile_x = dest_tx;
                        tile_y = dest_ty;

                        target_x = dest_tx * gen.tile_size + gen.tile_size * 0.5;
                        target_y = dest_ty * gen.tile_size + gen.tile_size * 0.5;

                        moving = true;

                        bat_state = 2;
                        bat_rest_turns = 1;

                        plan_dx = 0; plan_dy = 0; plan_len = 0;
                    }
                }
            }
            // PREPARE
            else
            {
                var btx = tile_x;
                var bty = tile_y;

                var ddx = ptx - btx;
                var ddy = pty - bty;

                var choose_h = false;
                if (abs(ddx) > abs(ddy)) choose_h = true;
                else if (abs(ddy) > abs(ddx)) choose_h = false;
                else choose_h = (irandom(1) == 0);

                var dx2 = 0;
                var dy2 = 0;

                if (choose_h)
                {
                    dx2 = sign(ddx);
                    if (dx2 == 0) { dy2 = sign(ddy); dx2 = 0; }
                }
                else
                {
                    dy2 = sign(ddy);
                    if (dy2 == 0) { dx2 = sign(ddx); dy2 = 0; }
                }

                if (dx2 == 0 && dy2 == 0)
                {
                    bat_state = 2;
                    bat_rest_turns = 1;
                }
                else
                {
                    var last_ok = 0;

                    // plan landing only (must be FLOOR)
                    for (var step3 = 1; step3 <= 3; step3++)
                    {
                        var cand_tx2 = btx + dx2 * step3;
                        var cand_ty2 = bty + dy2 * step3;

                        if (cand_tx2 <= 0 || cand_ty2 <= 0 || cand_tx2 >= gen.grid_w - 1 || cand_ty2 >= gen.grid_h - 1) break;
                        if (cand_tx2 == ptx && cand_ty2 == pty) continue;

                        var kk = string(cand_tx2) + "," + string(cand_ty2);
                        var self_kk = string(btx) + "," + string(bty);
                        if (kk != self_kk && ds_map_exists(occ, kk)) continue;

                        if (gen.map[# cand_tx2, cand_ty2] != gen.CELL_FLOOR) continue;

                        last_ok = step3;
                    }

                    if (last_ok <= 0)
                    {
                        bat_state = 2;
                        bat_rest_turns = 1;
                    }
                    else
                    {
                        plan_dx = dx2;
                        plan_dy = dy2;
                        plan_len = last_ok;

                        intent_valid = true;
                        intent_dx = plan_dx;
                        intent_dy = plan_dy;
                        intent_len = plan_len;

                        bat_state = 1;
                    }
                }
            }
        }
    }


    with (obj_enemy_slime)
    {
        intent_valid = false;
        intent_dx = 0;
        intent_dy = 0;

        if (moving || bounce_stage != 0) { }
        else
        {
            var stx = tile_x;
            var sty = tile_y;

            var ddx_s = ptx - stx;
            var ddy_s = pty - sty;

            // If adjacent -> attack 
            if (abs(ddx_s) + abs(ddy_s) == 1)
            {
                intent_valid = true;
                intent_dx = ddx_s;
                intent_dy = ddy_s;

                scr_player_take_damage(1);

                home_tile_x = stx;
                home_tile_y = sty;

                bounce = true;
                bounce_stage = 1;

                target_x = ptx * gen.tile_size + gen.tile_size * 0.5;
                target_y = pty * gen.tile_size + gen.tile_size * 0.5;

                moving = true;
            }
            else
            {
      
                var step = scr_bfs_next_step(stx, sty, ptx, pty, occ);
                var nxtx = step[0];
                var nxty = step[1];

                if (nxtx == -1)
                {
                    // no path -> do nothing
                }
                else
                {
                    var dxm = nxtx - stx;
                    var dym = nxty - sty;

                    intent_valid = true;
                    intent_dx = dxm;
                    intent_dy = dym;

                    // Safety checks 
                    if (gen.map[# nxtx, nxty] == gen.CELL_FLOOR)
                    {
                        var keym = string(nxtx) + "," + string(nxty);
                        if (!ds_map_exists(occ, keym))
                        {
                            ds_map_delete(occ, string(stx) + "," + string(sty));
                            ds_map_replace(occ, keym, id);

                            tile_x = nxtx;
                            tile_y = nxty;

                            target_x = nxtx * gen.tile_size + gen.tile_size * 0.5;
                            target_y = nxty * gen.tile_size + gen.tile_size * 0.5;

                            moving = true;
                        }
                    }
                }
            }
        }
    }

    ds_map_destroy(occ);
}