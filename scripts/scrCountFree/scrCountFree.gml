/// @func scrCountFree(_obj)
function scrCountFree(_obj)
{
    var c = 0;
    with (_obj)
    {
        if (!taken) c++;
    }
    return c;
}
