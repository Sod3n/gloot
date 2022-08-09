extends Node
class_name InventoryItem
tool

signal protoset_changed
signal prototype_id_changed
signal properties_changed

export(Resource) var protoset: Resource setget _set_prototset
export(String) var prototype_id: String setget _set_prototype_id
export(Dictionary) var properties: Dictionary setget _set_properties
var _inventory: Node

const KEY_PROTOSET: String = "protoset"
const KEY_PROTOTYE_ID: String = "prototype_id"
const KEY_PROPERTIES: String = "properties"
const KEY_IMAGE: String = "image"
const KEY_NAME: String = "name"


func _set_prototset(new_protoset: Resource) -> void:
    var old_protoset = protoset
    protoset = new_protoset
    if old_protoset != protoset:
        # Reset the prototype ID (pick the first prototype from the protoset)
        prototype_id = ""
        if protoset && protoset._prototypes && protoset._prototypes.keys().size() > 0:
            _set_prototype_id(protoset._prototypes.keys()[0])

        emit_signal("protoset_changed")


func _set_prototype_id(new_prototype_id: String) -> void:
    var old_prototype_id = prototype_id
    prototype_id = new_prototype_id
    if old_prototype_id != prototype_id:
        # Reset properties
        _set_properties({})

        emit_signal("prototype_id_changed")


func _set_properties(new_properties: Dictionary) -> void:
    properties = new_properties
    emit_signal("properties_changed")


func _notification(what):
    if what == NOTIFICATION_PARENTED:
        _inventory = get_parent()
        var inv_item_protoset = get_parent().get("item_protoset")
        if inv_item_protoset:
            protoset = inv_item_protoset
        _emit_added(get_parent())
    elif what == NOTIFICATION_UNPARENTED:
        _emit_removed(_inventory)
        _inventory = null


func _emit_removed(obj: Object):
    if obj.has_signal("item_removed"):
        obj.emit_signal("item_removed", self)


func _emit_added(obj: Object):
    if obj.has_signal("item_added"):
        obj.emit_signal("item_added", self)


func get_inventory() -> Node:
    return _inventory


func get_property(property_name: String, default_value = null):
    if properties.has(property_name):
        return properties[property_name]
    if protoset:
        return protoset.get_item_property(prototype_id, property_name, default_value)
    return default_value


func set_property(property_name: String, value) -> void:
    var old_property = null
    if properties.has(property_name):
        old_property = properties[property_name]
    properties[property_name] = value
    if old_property != properties[property_name]:
        emit_signal("properties_changed")


func clear_property(property_name: String) -> void:
    properties.erase(property_name)


func reset() -> void:
    protoset = null
    prototype_id = ""
    properties = {}


func serialize() -> Dictionary:
    var result: Dictionary = {}

    result[KEY_PROTOSET] = protoset.resource_path
    result[KEY_PROTOTYE_ID] = prototype_id
    if !properties.empty():
        result[KEY_PROPERTIES] = properties

    return result


func deserialize(source: Dictionary) -> bool:
    if !GlootVerify.dict(source, true, KEY_PROTOSET, TYPE_STRING) ||\
        !GlootVerify.dict(source, true, KEY_PROTOTYE_ID, TYPE_STRING) ||\
        !GlootVerify.dict(source, false, KEY_PROPERTIES, TYPE_DICTIONARY):
        return false

    reset()

    protoset = load(source[KEY_PROTOSET])
    prototype_id = source[KEY_PROTOTYE_ID]
    if source.has(KEY_PROPERTIES):
        properties = source[KEY_PROPERTIES]

    return true


func get_texture() -> Resource:
    var texture_path = get_property(KEY_IMAGE)
    if texture_path && ResourceLoader.exists(texture_path):
        var texture = load(texture_path)
        if texture is Texture:
            return texture
    return null


func get_title() -> String:
    var title = get_property(KEY_NAME, prototype_id)
    if !(title is String):
        title = prototype_id

    return title
