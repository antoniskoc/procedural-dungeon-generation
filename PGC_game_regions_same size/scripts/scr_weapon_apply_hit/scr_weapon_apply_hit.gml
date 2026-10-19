function scr_weapon_apply_hit(_enemy, _dmg, _dir, _knock_tiles, _ply_tx, _ply_ty)
{
    var gen = global.levelgen_id;
    if (!instance_exists(gen)) return false;

    if (_enemy == noone) return false;
    if (!instance_exists(_enemy)) return false;

   
    if (!variable_instance_exists(_enemy, "hp"))
        _enemy.hp = 1;

    // Stop any enemy animation that could fight the knockback
    if (variable_instance_exists(_enemy, "moving")) _enemy.moving = false;
    if (variable_instance_exists(_enemy, "bounce")) _enemy.bounce = false;
    if (variable_instance_exists(_enemy, "bounce_stage")) _enemy.bounce_stage = 0;

 
    _enemy.hp -= _dmg;

    // Death
    if (_enemy.hp <= 0)
    {
        with (_enemy) instance_destroy();
        return true;
    }

    // Knockback
    var delta = scr_dir_to_delta(_dir);
    var dx = delta[0];
    var dy = delta[1];

    if (dx == 0 && dy == 0) return true;

    var start_tx = _enemy.tile_x;
    var start_ty = _enemy.tile_y;

    var final_tx = start_tx;
    var final_ty = start_ty;

    // Try farthest -> nearest
    for (var step_i = _knock_tiles; step_i >= 1; step_i--)
    {
        var cand_tx = start_tx + dx * step_i;
        var cand_ty = start_ty + dy * step_i;

        if (scr_can_enemy_occupy_tile(cand_tx, cand_ty, _ply_tx, _ply_ty))
        {
            final_tx = cand_tx;
            final_ty = cand_ty;
            break;
        }
    }

    _enemy.tile_x = final_tx;
    _enemy.tile_y = final_ty;

    var px_pos = final_tx * gen.tile_size + gen.tile_size * 0.5;
    var py_pos = final_ty * gen.tile_size + gen.tile_size * 0.5;

    _enemy.x = px_pos;
    _enemy.y = py_pos;

    if (variable_instance_exists(_enemy, "target_x")) _enemy.target_x = px_pos;
    if (variable_instance_exists(_enemy, "target_y")) _enemy.target_y = py_pos;

    // Clear intent so it recalculates nicely
    if (variable_instance_exists(_enemy, "intent_valid")) _enemy.intent_valid = false;
    if (variable_instance_exists(_enemy, "intent_dx")) _enemy.intent_dx = 0;
    if (variable_instance_exists(_enemy, "intent_dy")) _enemy.intent_dy = 0;

    return true;
}