function scr_can_enemy_occupy_tile(_tx, _ty, _ply_tx, _ply_ty)
{
    var gen = global.levelgen_id;
    if (!instance_exists(gen)) return false;

    // bounds
    if (_tx < 0 || _ty < 0 || _tx >= gen.grid_w || _ty >= gen.grid_h) return false;

    // walls
    if (gen.map[# _tx, _ty] == gen.CELL_WALL) return false;

    // don't knock into player
    if (_tx == _ply_tx && _ty == _ply_ty) return false;

    // don't knock into another enemy
    if (scr_enemy_at_tile(_tx, _ty) != noone) return false;

    return true;
}