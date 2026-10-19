function scr_room_xy_from_key(_k)
{
    var cpos = string_pos(",", _k);
    if (cpos <= 0) return [0, 0];

    var rx = real(string_copy(_k, 1, cpos - 1));
    var ry = real(string_copy(_k, cpos + 1, string_length(_k) - cpos));

    return [rx, ry];
}