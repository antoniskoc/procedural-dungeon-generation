/// obj_levelgen : Draw GUI

// Minimap
if (global.show_minimap){
	var cell = global.wfc_big_map ? 6 :12;
	scr_draw_minimap(20,20,cell);
	
	
}

// Hearts UI
scr_draw_hearts_ui();


//style overlay
if (global.pending_generate)
{
	var gui_w = display_get_gui_width();
	var gui_h = display_get_gui_height();
	
	draw_set_alpha(0.70);
    draw_set_color(c_black);
    draw_rectangle(0, 0, gui_w, gui_h, false);

    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    draw_text(gui_w * 0.5, gui_h * 0.5 - 60, "SELECT DUNGEON STYLE");
    draw_text(gui_w * 0.5, gui_h * 0.5 - 25, "1 = CORRIDOR   2 = BRANCHY   3 = VERTICAL");
    draw_text(gui_w * 0.5, gui_h * 0.5 + 10, "Current: " + string(global.wfc_style_name));
    draw_text(gui_w * 0.5, gui_h * 0.5 + 45, "B = Toggle Big Map (" + string(global.max_rooms) + " rooms)");
    draw_text(gui_w * 0.5, gui_h * 0.5 + 80, "Press ENTER to Generate");

    exit;
	
}

// Game over overlay
if (variable_global_exists("game_over") && global.game_over)
{
    var gui_w = display_get_gui_width();
    var gui_h = display_get_gui_height();

    var old_col = draw_get_color();
    var old_a = draw_get_alpha();
    var old_h = draw_get_halign();
    var old_v = draw_get_valign();

    draw_set_alpha(0.65);
    draw_set_color(c_black);
    draw_rectangle(0, 0, gui_w, gui_h, false);

    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    draw_text(gui_w * 0.5, gui_h * 0.5 - 10, "GAME OVER");
    draw_text(gui_w * 0.5, gui_h * 0.5 + 20, "Press R to Restart");

    draw_set_halign(old_h);
    draw_set_valign(old_v);
    draw_set_alpha(old_a);
    draw_set_color(old_col);
}
// Locked room overlay
// Locked gateway menu text
var lock_txt = "OFF";

if (global.use_locked_gateway)
{
    lock_txt = "ON";
}

draw_text(32, 184, "L - Locked gateway: " + lock_txt);