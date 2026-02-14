class_name ItemData
extends Resource

enum Type {KEY, TOOL, WEAPON}

@export var name: String
@export var type: Type
@export_multiline var description: String
@export var texture: Texture2D
