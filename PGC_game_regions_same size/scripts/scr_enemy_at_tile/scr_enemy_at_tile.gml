function scr_enemy_at_tile(_tx, _ty)
{

    var cnt = instance_number(obj_enemy_parent);

    for (var ii = 0; ii < cnt; ii++)
    {
        var inst = instance_find(obj_enemy_parent, ii);
        if (inst.tile_x == _tx && inst.tile_y == _ty) return inst;
    }

    return noone;
}