class_name Box extends StaticBody3D

@export var item = null

@onready var box_mesh: MeshInstance3D = $BoxMesh
@onready var outline_shader = preload("res://Shaders/outline_shader.gdshader")

func aplicar_outline() -> void:
	var mat := ShaderMaterial.new()
	mat.shader = outline_shader
	box_mesh.material_overlay = mat

func remover_outline():
	box_mesh.material_overlay = null
