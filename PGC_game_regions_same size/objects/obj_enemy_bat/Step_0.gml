
if (!moving) exit;

x += clamp(target_x - x, -move_px_per_step, move_px_per_step);
y += clamp(target_y - y, -move_px_per_step, move_px_per_step);

if (abs(x - target_x) < 0.001 && abs(y - target_y) < 0.001)
{
    x = target_x;
    y = target_y;
    moving = false;
}