function scr_wfc_state_init()
{
    // Create/clear WFC DS
    if (!variable_global_exists("wfc_domain") || !ds_exists(global.wfc_domain, ds_type_map))
        global.wfc_domain = ds_map_create();
    else
        ds_map_clear(global.wfc_domain);

    if (!variable_global_exists("wfc_done") || !ds_exists(global.wfc_done, ds_type_map))
        global.wfc_done = ds_map_create();
    else
        ds_map_clear(global.wfc_done);

    if (!variable_global_exists("wfc_keys") || !ds_exists(global.wfc_keys, ds_type_list))
        global.wfc_keys = ds_list_create();
    else
        ds_list_clear(global.wfc_keys);

    // Constants
    global.wfc_nArch = array_length(global.room_archetypes);
    global.wfc_ALL   = (1 << global.wfc_nArch) - 1;

    global.wfc_dx = [0, 1, 0, -1];
    global.wfc_dy = [-1, 0, 1, 0];
}