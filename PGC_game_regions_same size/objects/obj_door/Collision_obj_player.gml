/// CHANGED: only trigger door once the player has finished a step
if (other.transition_cooldown > 0) exit;
if (other.moving) exit; // don't trigger mid-slide

var ply_inst = other.id;
var ddir = door_dir;

if (instance_exists(global.levelgen_id))
{
    scr_change_room(global.levelgen_id, ddir, ply_inst);
}