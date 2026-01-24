function scrAddKillFeed(_text)
{
    if (!variable_instance_exists(oBrain, "kill_feed")) oBrain.kill_feed = [];
    if (!variable_instance_exists(oBrain, "kill_feed_max")) oBrain.kill_feed_max = 5;

    var entry = { text: _text, timer: room_speed * 3 };
    array_insert(oBrain.kill_feed, 0, entry);

    if (array_length(oBrain.kill_feed) > oBrain.kill_feed_max)
        array_resize(oBrain.kill_feed, oBrain.kill_feed_max);
}
