function get_nearest_node(_x, _y)
{
    var best = noone;
    var best_dist = 999999;

    with (oNode)
    {
        var d = point_distance(_x, _y, x, y);
        if (d < best_dist)
        {
            best_dist = d;
            best = id;
        }
    }

    return best;
}