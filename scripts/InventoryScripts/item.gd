class_name Item extends TextureRect

func _ready() -> void:
	custom_minimum_size = Vector2(24,24)
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	size_flags_horizontal = TextureRect.SIZE_SHRINK_CENTER
	size_flags_vertical = TextureRect.SIZE_SHRINK_CENTER

func _get_drag_data(at_position: Vector2):
	set_drag_preview(make_drag_preview(at_position))
	return self
	
func make_drag_preview(at_position: Vector2):
	var t := TextureRect.new()
	t.texture = texture
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.custom_minimum_size = size
	t.modulate.a = 0.7
	t.position = Vector2(-at_position)

	var c := Control.new()
	c.top_level = true
	c.z_index = 2
	c.add_child(t)

	return c
