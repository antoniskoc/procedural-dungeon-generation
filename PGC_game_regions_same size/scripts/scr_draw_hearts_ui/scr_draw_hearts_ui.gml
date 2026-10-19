function scr_draw_hearts_ui()
{
    var ply = instance_find(obj_player, 0);
    if (!instance_exists(ply)) exit;

    if (!sprite_exists(spr_heart_full) || !sprite_exists(spr_heart_empty)) exit;

    //init anchor globals if missing
    if (!variable_global_exists("hp_ui_x") || !variable_global_exists("hp_ui_y"))
    {
        var a0 = instance_find(obj_ui_anchor_hearts, 0);
        if (instance_exists(a0))
        {
            global.hp_ui_x = a0.x;
            global.hp_ui_y = a0.y;
        }
        else
        {
            // fallback if anchor not placed
            global.hp_ui_x = 0;
            global.hp_ui_y = 288;
        }
    }



    var heart_h = sprite_get_height(spr_heart_full);

    var base_px_x = global.hp_ui_x;
    var base_px_y = global.hp_ui_y - heart_h;

    // Optional safety clamp so it can't go off-screen
    var gui_h = display_get_gui_height();
    if (base_px_y < 0) base_px_y = 0;
    if (base_px_y > gui_h - heart_h) base_px_y = gui_h - heart_h;

    var heart_w = sprite_get_width(spr_heart_full);
    var pad = 6;

    for (var ii = 0; ii < ply.max_hp; ii++)
    {
        var spr = (ii < ply.hp) ? spr_heart_full : spr_heart_empty;
        draw_sprite(spr, 0, base_px_x + ii * (heart_w + pad), base_px_y);
    }
}