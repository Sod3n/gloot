extends Control

const info_offset: Vector2 = Vector2(20, 0)

const StackManager = preload("res://addons/gloot/core/stack_manager.gd")

@onready var ctrl_inventory_left := $"%CtrlInventoryGridLeft"
@onready var ctrl_inventory_right := $"%CtrlInventoryGridRight"
@onready var btn_sort_left: Button = $"%BtnSortLeft"
@onready var btn_sort_right: Button = $"%BtnSortRight"
@onready var btn_split_left: Button = $"%BtnSplitLeft"
@onready var btn_split_right: Button = $"%BtnSplitRight"
@onready var ctrl_slot: CtrlItemSlot = $"%CtrlItemSlot"
@onready var btn_unequip: Button = $"%BtnUnequip"
@onready var lbl_info: Label = $"%LblInfo"


func _ready() -> void:
    ctrl_inventory_left.item_mouse_entered.connect(_on_item_mouse_entered)
    ctrl_inventory_left.item_mouse_exited.connect(_on_item_mouse_exited)
    ctrl_inventory_right.item_mouse_entered.connect(_on_item_mouse_entered)
    ctrl_inventory_right.item_mouse_exited.connect(_on_item_mouse_exited)
    btn_sort_left.pressed.connect(_on_btn_sort.bind(ctrl_inventory_left))
    btn_sort_right.pressed.connect(_on_btn_sort.bind(ctrl_inventory_right))
    btn_split_left.pressed.connect(_on_btn_split.bind(ctrl_inventory_left))
    btn_split_right.pressed.connect(_on_btn_split.bind(ctrl_inventory_right))
    btn_unequip.pressed.connect(_on_btn_unequip)


func _on_item_mouse_entered(item: InventoryItem) -> void:
    lbl_info.show()
    lbl_info.text = item.get_title()


func _on_item_mouse_exited(_item: InventoryItem) -> void:
    lbl_info.hide()


func _input(event: InputEvent) -> void:
    if !(event is InputEventMouseMotion):
        return

    lbl_info.set_global_position(get_global_mouse_position() + info_offset)


func _on_btn_sort(ctrl_inventory) -> void:
    if !ctrl_inventory.inventory.sort():
        print("Warning: InventoryGrid.sort() returned false!")


func _on_btn_split(ctrl_inventory) -> void:
    var selected_items = ctrl_inventory.get_selected_inventory_items()
    if selected_items.is_empty():
        return

    for selected_item in selected_items:
        var stack_size := InventoryGridStacked.get_item_stack_size(selected_item)
        if stack_size < 2:
            return

        # All this floor/float jazz just to do integer division without warnings
        var new_stack_size: int = floor(float(stack_size) / 2)
        StackManager.inv_split_stack(ctrl_inventory.inventory, selected_item, ItemCount.new(new_stack_size))


func _on_btn_unequip() -> void:
    ctrl_slot.item_slot.clear()

