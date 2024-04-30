@tool
extends Tree

signal prototype_activated(prototype)

@export var prototree_json: JSON = null :
    set(new_prototree_json):
        if new_prototree_json == prototree_json:
            return
        _disconnect_json_signals()
        prototree_json = new_prototree_json
        _proto_tree.clear()
        _connect_json_signals()
        _proto_tree.deserialize(prototree_json)
        _queue_refresh()


var _proto_tree := ProtoTree.new()
var _refresh_queued := false


func _connect_json_signals() -> void:
    if !is_instance_valid(prototree_json):
        return
    prototree_json.changed.connect(_queue_refresh)


func _disconnect_json_signals() -> void:
    if !is_instance_valid(prototree_json):
        return
    prototree_json.changed.disconnect(_queue_refresh)


func _queue_refresh() -> void:
    _refresh_queued = true


func _process(_delta: float) -> void:
    if _refresh_queued:
        _refresh()
        _refresh_queued = false


func _refresh() -> void:
    clear()
    var root = create_item(null)
    root.set_text(0, _proto_tree.get_root().get_id())
    root.set_metadata(0, _proto_tree.get_root())
    _traverse(_proto_tree.get_root(), root)


func _traverse(prototype: Prototype, tree_item: TreeItem) -> void:
    for subprototype in prototype.get_prototypes():
        var subitem = create_item(tree_item)
        subitem.set_text(0, subprototype.get_id())
        subitem.set_metadata(0, subprototype)
        _traverse(subprototype, subitem)


func _ready() -> void:
    item_activated.connect(func():
        prototype_activated.emit(get_selected().get_metadata(0))
    )