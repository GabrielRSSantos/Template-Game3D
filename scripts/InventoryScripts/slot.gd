class_name Slot extends PanelContainer

func _can_drop_data(_at_position: Vector2, data: Variant):
	return data is Item

func _drop_data(_at_position: Vector2, data: Variant):
	var drag_node = data
	var old_parent = drag_node.get_parent()
	
	if get_child_count() > 0:
		var current_item = get_child(0)
		current_item.reparent(old_parent)
		
	drag_node.reparent(self)
