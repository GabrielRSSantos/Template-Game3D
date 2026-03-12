class_name ItemsInBox extends Control

@export var items_in_box : Array[ItemData]
@onready var h_box_container: HBoxContainer = $PanelContainer/HBoxContainer

@onready var slot: Slot = $"../PlayerUI/Slot"

func _ready():
	for item in items_in_box:
		var new_item = TextureButton.new()
		new_item.name = item.name
		new_item.texture_normal = item.texture
		new_item.texture_focused = load("res://Assets/Keyboard & Mouse/Double/keyboard_0_outline.png")
		new_item.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		new_item.ignore_texture_size = true
		new_item.custom_minimum_size.x = 50
		
		h_box_container.add_child(new_item)
	
	h_box_container.get_child(0).grab_focus()

func open_box(items) -> void:
	self.visible = true
	for item in items:
		var new_item = TextureButton.new()
		new_item.name = item.name
		new_item.texture_normal = item.texture
		new_item.texture_focused = load("res://Assets/Keyboard & Mouse/Double/keyboard_0_outline.png")
		new_item.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		new_item.ignore_texture_size = true
		new_item.custom_minimum_size.x = 50
		
		h_box_container.add_child(new_item)
	h_box_container.get_child(0).grab_focus()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("E"):
		var focused_node = get_viewport().gui_get_focus_owner()
		if focused_node and focused_node.get_parent() == h_box_container:
			_item_selected(focused_node)


func _item_selected(item_data) -> void:
	if slot.get_child_count() > 0:
		var item_in_slot = slot.get_child(0)
		item_in_slot.reparent(h_box_container)

	item_data.reparent(slot)
	
	var remaining_children = h_box_container.get_children()
	if remaining_children.size() > 0:
		remaining_children[0].grab_focus()
	else:
		close_box()


func close_box() -> void:
	self.visible = false
