function scr_bits_pick_random(_bits)
{
    var n = scr_bits_count(_bits);
    if (n <= 0) return -1;

    var k = irandom(n - 1);
    for (var i = 0; i < 32; i++)
    {
        if (_bits & (1 << i))
        {
            if (k == 0) return i;
            k--;
        }
    }
    return -1;
}