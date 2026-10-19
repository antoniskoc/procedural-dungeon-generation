function scr_player_use_weapon(_dir)
{
    if (_dir < 0) exit;

    var ply = instance_find(obj_player, 0);
    if (!instance_exists(ply)) exit;

    // Weapon switchboard
    if (ply.weapon_id == "knife")
    {
        scr_weapon_attack_knife(_dir);
    }
    else
    {
        // fallback until more weapons exist
        scr_weapon_attack_knife(_dir);
    }

    // Attacking consumes the turn
    scr_enemies_take_turn();
}