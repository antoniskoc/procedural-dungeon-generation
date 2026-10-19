if (ds_exists(map, ds_type_grid)) ds_grid_destroy(map);
if (ds_exists(global.room_doors, ds_type_map)) ds_map_destroy(global.room_doors);
if (ds_exists(global.room_done, ds_type_map))  ds_map_destroy(global.room_done);
if (ds_exists(global.room_geom, ds_type_map)) ds_map_destroy(global.room_geom);
if (variable_global_exists("wfc_domain") && ds_exists(global.wfc_domain, ds_type_map)) ds_map_destroy(global.wfc_domain);
if (variable_global_exists("wfc_done")   && ds_exists(global.wfc_done,   ds_type_map)) ds_map_destroy(global.wfc_done);
if (variable_global_exists("wfc_keys")   && ds_exists(global.wfc_keys,   ds_type_list)) ds_list_destroy(global.wfc_keys);
//cleanup enemy layouts
if (variable_global_exists("room_enemy_defs") && ds_exists(global.room_enemy_defs, ds_type_map))
{
    var k = ds_map_find_first(global.room_enemy_defs);
    while (!is_undefined(k))
    {
        var lst = ds_map_find_value(global.room_enemy_defs, k);
        if (ds_exists(lst, ds_type_list)) ds_list_destroy(lst);
        k = ds_map_find_next(global.room_enemy_defs, k);
    }
    ds_map_destroy(global.room_enemy_defs);
}
