function scr_weapon_attack_knife(_dir)
{
    var gen = global.levelgen_id;
    if (!instance_exists(gen)) exit;

    var ply = instance_find(obj_player, 0);
    if (!instance_exists(ply)) exit;

    var delta = scr_dir_to_delta(_dir);
    var dx = delta[0];
    var dy = delta[1];

    // Knife hits 1 tile away
    var atk_tx = ply.tile_x + dx;
    var atk_ty = ply.tile_y + dy;

    var enemy = scr_enemy_at_tile(atk_tx, atk_ty);
    if (enemy == noone) exit;

    // Knife: 1 dmg + knockback 2 tiles
    scr_weapon_apply_hit(enemy, 1, _dir, 2, ply.tile_x, ply.tile_y);
}