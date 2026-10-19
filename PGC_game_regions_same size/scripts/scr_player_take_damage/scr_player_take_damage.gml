function scr_player_take_damage(_amt)
{
    if (variable_global_exists("game_over") && global.game_over) exit;

    var ply = instance_find(obj_player, 0);
    if (!instance_exists(ply)) exit;

    ply.hp -= _amt;
    if (ply.hp < 0) ply.hp = 0;

    if (ply.hp <= 0)
    {
        global.game_over = true;
    }
}