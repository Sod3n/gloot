class_name ProtoTree
extends RefCounted
## A prototype tree (prototree).
##
## A tree structure of prototypes with a root prototype that can have a number of child prototypes.

var _root := Prototype.new("ROOT")


## Returns the root prototype.
func get_root() -> Prototype:
    return _root


## Creates a child prototype for the root prototype.
func create_prototype(prototype_id: String) -> Prototype:
    return _root.create_prototype(prototype_id)


## Returns the prototype at the given path (as a `String` or a `PrototypePath`).
func get_prototype(path) -> Prototype:
    return _root.get_prototype(path)


## Returns an array of all child prototypes of the root.
func get_prototypes() -> Array:
    return _root.get_prototypes()


## Checks if the prototree contains the prototype at the given path (as a `String` or a `PrototypePath`).
func has_prototype(path) -> bool:
    return _root.has_prototype(path)


## Checks if the prototype at the given path (as a `String` or a `PrototypePath`) has the given property defined.
func has_prototype_property(path: Variant, property: String) -> bool:
    return _root.has_prototype_property(path, property)


## Returns the given property of the prototype at the given path (as a `String` or a `PrototypePath`). If the prototype
## does not have the property defined, `default_value` is returned.
func get_prototype_property(path: Variant, property: String, default_value: Variant = null) -> Variant:
    return _root.get_prototype_property(path, property, default_value)


## Clears the prototree by clearing the roots properties and child prototypes.
func clear() -> void:
    _root.clear()


## Checks if the prototree is empty (the root has no properties and no child prototypes).
func is_empty() -> bool:
    return _root.get_properties().is_empty() && _root.get_prototypes().is_empty()


## Parses the given JSON resource into a prototree. Returns `false` if parsing fails.
func deserialize(json: JSON) -> bool:
    return _root.deserialize(json)

