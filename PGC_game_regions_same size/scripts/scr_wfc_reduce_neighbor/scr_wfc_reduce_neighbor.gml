function scr_wfc_reduce_neighbor(_ax, _ay, _dir)
{
    var akey = scr_wfc_key(_ax, _ay);
    if (!ds_map_exists(global.wfc_domain, akey)) return 0;

    var bx = _ax + global.wfc_dx[_dir];
    var by = _ay + global.wfc_dy[_dir];
    var bkey = scr_wfc_key(bx, by);

    // Only constrain neighbors that already exist in the layout
    if (!ds_map_exists(global.wfc_domain, bkey)) return 0;

    var domA = ds_map_find_value(global.wfc_domain, akey);
    var domB = ds_map_find_value(global.wfc_domain, bkey);

    var opp = (_dir + 2) & 3;

    var newDomB = 0;
    var nArch = global.wfc_nArch;

    for (var b = 0; b < nArch; b++)
    {
        if (!(domB & (1 << b))) continue;

        var ok = false;

        for (var a = 0; a < nArch; a++)
        {
            if (!(domA & (1 << a))) continue;

            var maskA = global.room_archetypes[a];
            var maskB = global.room_archetypes[b];

            var aHas = (maskA & (1 << _dir)) != 0;
            var bHas = (maskB & (1 << opp)) != 0;

            if (aHas == bHas) { ok = true; break; }
        }

        if (ok) newDomB |= (1 << b);
    }

    if (newDomB == 0) return -1; // contradiction

    if (newDomB != domB)
    {
        ds_map_replace(global.wfc_domain, bkey, newDomB);
        return 1; // changed
    }

    return 0; // unchanged
}