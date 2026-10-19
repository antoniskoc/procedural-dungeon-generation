/// obj_enemy_slime : Step

if (!moving) exit;

x += clamp(target_x - x, -move_px_per_step, move_px_per_step);
y += clamp(target_y - y, -move_px_per_step, move_px_per_step);

if (abs(x - target_x) < 0.001 && abs(y - target_y) < 0.001)
{
    x = target_x;
    y = target_y;

    if (bounce && bounce_stage == 1)
    {
        var gen = global.levelgen_id;
        if (instance_exists(gen))
        {
            bounce_stage = 2;
            target_x = home_tile_x * gen.tile_size + gen.tile_size * 0.5;
            target_y = home_tile_y * gen.tile_size + gen.tile_size * 0.5;
            exit;
        }
    }

    moving = false;
    bounce = false;
    bounce_stage = 0;

    // Return to normal after finishing motion
    if (sprite_index != spr_normal) sprite_index = spr_normal;
}