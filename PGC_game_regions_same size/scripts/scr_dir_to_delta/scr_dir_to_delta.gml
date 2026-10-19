function scr_dir_to_delta(_dir)
{
    var gen = global.levelgen_id;
    if (!instance_exists(gen)) return [0, 0];

    var dx = 0;
    var dy = 0;

    if (_dir == gen.DIR_N) dy = -1;
    else if (_dir == gen.DIR_S) dy =  1;
    else if (_dir == gen.DIR_E) dx =  1;
    else if (_dir == gen.DIR_W) dx = -1;

    return [dx, dy];
}