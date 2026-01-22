if(json_parse(persistentObjectProperties)._type == "flag")
{
var updated_data = {
    _type: "flag",
    _carrier: my_id // Le decimos al servidor que yo la llevo
}
EditPersistentObject(persistentObjectId, updated_data);
}
