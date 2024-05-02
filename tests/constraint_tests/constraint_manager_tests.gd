extends TestSuite

const ConstraintManager = preload("res://addons/gloot/core/constraints/constraint_manager.gd")
const WeightConstraint = preload("res://addons/gloot/core/constraints/weight_constraint.gd")
const GridConstraint = preload("res://addons/gloot/core/constraints/grid_constraint.gd")
const StackManager = preload("res://addons/gloot/core/stack_manager.gd")

var inventory: Inventory
var inventory2: Inventory
var constraint_manager: ConstraintManager

const TEST_PROTOTREE = preload("res://tests/data/prototree_basic.json")
const TEST_PROTOTYPE_PATH = "/minimal_item"
const TEST_PROTOTREE_W = preload("res://tests/data/prototree_stacks.json")
const TEST_PROTOTYPE_PATH_W = "/minimal_item"
const TEST_PROTOTREE_G = preload("res://tests/data/prototree_grid.json")
const TEST_PROTOTYPE_PATH_G = "/item_2x2"


func init_suite():
    tests = [
        "test_init",
        "test_has_space_for",
        "test_w_has_space_for",
        "test_g_has_space_for",
        "test_wg_has_space_for",
        "test_g_enforce_constraints",
        "test_wg_enforce_constraints",
    ]


func init_test() -> void:
    inventory = create_inventory(TEST_PROTOTREE)
    inventory2 = create_inventory(TEST_PROTOTREE)
    constraint_manager = inventory._constraint_manager


func cleanup_test() -> void:
    free_inventory(inventory)
    free_inventory(inventory2)


func test_init() -> void:
    assert(constraint_manager.get_weight_constraint() == null)
    assert(constraint_manager.get_grid_constraint() == null)
    assert(constraint_manager.inventory == inventory)


func test_has_space_for() -> void:
    var item = create_item(TEST_PROTOTREE, TEST_PROTOTYPE_PATH)
    assert(constraint_manager.has_space_for(item))


func test_w_has_space_for() -> void:
    inventory.prototree_json = TEST_PROTOTREE_W
    var item = create_item(TEST_PROTOTREE_W, TEST_PROTOTYPE_PATH_W)

    constraint_manager.enable_weight_constraint(10.0)
    assert(constraint_manager.get_weight_constraint() != null)

    var test_data := [
        {input = 1.0, expected = {has_space = true, space = ItemCount.new(10)}},
        {input = 10.0, expected = {has_space = true, space = ItemCount.new(1)}},
        {input = 11.0, expected = {has_space = false, space = ItemCount.zero()}},
    ]

    for data in test_data:
        WeightConstraint.set_item_weight(item, data.input)
        assert(constraint_manager.get_space_for(item).eq(data.expected.space))
        assert(constraint_manager.has_space_for(item) == data.expected.has_space)


func test_g_has_space_for() -> void:
    inventory.prototree_json = TEST_PROTOTREE_G
    var item = create_item(TEST_PROTOTREE_G, TEST_PROTOTYPE_PATH_G)

    constraint_manager.enable_grid_constraint(Vector2i(3, 3))
    var grid_constraint = constraint_manager.get_grid_constraint()
    assert(grid_constraint != null)

    var test_data := [
        {input = Vector2i(1, 1), expected = {has_space = true, space = ItemCount.new(9)}},
        {input = Vector2i(2, 2), expected = {has_space = true, space = ItemCount.new(1)}},
        {input = Vector2i(3, 3), expected = {has_space = true, space = ItemCount.new(1)}},
        {input = Vector2i(4, 4), expected = {has_space = false, space = ItemCount.zero()}},
    ]

    for data in test_data:
        assert(grid_constraint.set_item_size(item, data.input))
        assert(constraint_manager.get_space_for(item).eq(data.expected.space))
        assert(constraint_manager.has_space_for(item) == data.expected.has_space)


func test_wg_has_space_for() -> void:
    inventory.prototree_json = TEST_PROTOTREE_W
    var item = create_item(TEST_PROTOTREE_W, TEST_PROTOTYPE_PATH_W)

    constraint_manager.enable_grid_constraint(Vector2i(3, 3))
    constraint_manager.enable_weight_constraint(10.0)
    var grid_constraint = constraint_manager.get_grid_constraint()
    var weight_constraint = constraint_manager.get_weight_constraint()
    assert(grid_constraint != null)
    assert(weight_constraint != null)

    var test_data := [
        {input = {weight = 1.0, size = Vector2i.ONE}, expected = {has_space = true, space = ItemCount.new(9)}},
        {input = {weight = 10.0, size = Vector2i(3, 3)}, expected = {has_space = true, space = ItemCount.new(1)}},
        {input = {weight = 11.0, size = Vector2i.ONE}, expected = {has_space = false, space = ItemCount.zero()}},
        {input = {weight = 1.0, size = Vector2i(4, 4)}, expected = {has_space = false, space = ItemCount.zero()}},
    ]

    for data in test_data:
        WeightConstraint.set_item_weight(item, data.input.weight)
        assert(grid_constraint.set_item_size(item, data.input.size))
        assert(constraint_manager.get_space_for(item).eq(data.expected.space))
        assert(constraint_manager.has_space_for(item) == data.expected.has_space)


func test_g_enforce_constraints() -> void:
    inventory.prototree_json = TEST_PROTOTREE_G
    var item = create_item(TEST_PROTOTREE_G, TEST_PROTOTYPE_PATH_G)

    constraint_manager.enable_grid_constraint(Vector2i(3, 3))
    var grid_constraint = constraint_manager.get_grid_constraint()
    assert(grid_constraint != null)

    var new_item = inventory.create_and_add_item("item_2x2")
    assert(grid_constraint.get_item_position(new_item) == Vector2i.ZERO)

    var test_data := [
        {input = Rect2i(0, 0, 2, 2), expected = false},
        {input = Rect2i(0, 0, 1, 1), expected = true},
    ]

    for data in test_data:
        grid_constraint.set_item_rect(new_item, data.input)
        var add_item_result := inventory.add_item(item)
        assert(add_item_result == data.expected)
        if add_item_result:
            assert(grid_constraint.rect_free(grid_constraint.get_item_rect(item), item))

    inventory.remove_item(new_item)


func test_wg_enforce_constraints() -> void:
    inventory.prototree_json = TEST_PROTOTREE_G
    var item = create_item(TEST_PROTOTREE_G, TEST_PROTOTYPE_PATH_G)

    constraint_manager.enable_weight_constraint(10.0)
    constraint_manager.enable_grid_constraint(Vector2i(3, 3))
    var weight_constraint = constraint_manager.get_weight_constraint()
    var grid_constraint = constraint_manager.get_grid_constraint()
    assert(weight_constraint != null)
    assert(grid_constraint != null)

    var new_item = inventory.create_and_add_item("item_1x1")
    assert(grid_constraint.get_item_position(new_item) == Vector2i.ZERO)

    var test_data := [
        {input = {new_item_rect = Rect2i(0, 0, 2, 2), item_weight = 1.0}, expected = false},
        {input = {new_item_rect = Rect2i(0, 0, 1, 1), item_weight = 11.0}, expected = false},
        {input = {new_item_rect = Rect2i(0, 0, 1, 1), item_weight = 1.0}, expected = true},
    ]

    for data in test_data:
        grid_constraint.set_item_rect(new_item, data.input.new_item_rect)
        WeightConstraint.set_item_weight(item, data.input.item_weight)
        var add_item_result := inventory.add_item(item)
        assert(add_item_result == data.expected)
        if add_item_result && (StackManager.get_item_stack_size(item).count > 0):
            assert(grid_constraint.rect_free(grid_constraint.get_item_rect(item), item))
        
    inventory.remove_item(new_item)

