function scrAddKillFeed(_text)
{
    // agarrar timings desde oBrain si existe
    var tin  = 10;
    var th   = 90;
    var tout = 12;
    var kmax = 5;

    if (instance_exists(oBrain))
    {
        tin  = oBrain.kf_in;
        th   = oBrain.kf_hold;
        tout = oBrain.kf_out;
        kmax = oBrain.kill_feed_max;
    }

    // asegurar array en oBrain
    if (instance_exists(oBrain) && !is_array(oBrain.kill_feed))
        oBrain.kill_feed = [];

    var item = {
        text: _text,
        t: 0,
        life: tin + th + tout,
        a: 0,
        xoff: -80,
        yoff: 0
    };

    // insert al inicio (en oBrain)
    if (instance_exists(oBrain))
    {
        array_insert(oBrain.kill_feed, 0, item);

        if (array_length(oBrain.kill_feed) > kmax) {
            array_delete(oBrain.kill_feed, kmax, array_length(oBrain.kill_feed) - kmax);
        }
    }
}
