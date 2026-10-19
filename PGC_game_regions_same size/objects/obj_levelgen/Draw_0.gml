draw_self();

// Mesh overlay
var alpha_old = draw_get_alpha();
draw_set_alpha(0.25); // semi transparent
// grid line color
var col_old = draw_get_color();
draw_set_color(c_white);

var ts = tile_size;
// Draw vertical grid lines
for (var gx = 0; gx <= grid_w; gx++)
{
    var px = gx * ts;
    draw_line(px, 0, px, grid_h * ts);
}

// Draw horizontal grid lines
for (var gy = 0; gy <= grid_h; gy++)
{
    var py = gy * ts;
    draw_line(0, py, grid_w * ts, py);
}
draw_set_alpha(0.12);
draw_set_color(c_black);

for (var ty = 0; ty < grid_h; ty++)
{
    for (var tx = 0; tx < grid_w; tx++)
    {
        if (map[# tx, ty] == CELL_WALL)
        {
            draw_rectangle(tx * ts, ty * ts, (tx + 1) * ts, (ty + 1) * ts, false);
        }
    }
}

// restore
draw_set_color(col_old);
draw_set_alpha(alpha_old);