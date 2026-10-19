function scr_wfc_key_to_xy(_k)
{
    var c = string_pos(",", _k);
    var tx = real(string_copy(_k, 1, c - 1));
    var ty = real(string_copy(_k, c + 1, string_length(_k) - c));
    return [tx, ty];
}