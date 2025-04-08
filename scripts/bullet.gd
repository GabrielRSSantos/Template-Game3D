extends Node3D

const SPEED = 10.0

@onready var mesh = $BulletMesh
@onready var raycast = $BulletRayCast
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += transform.basis * Vector3(0, 0, -SPEED) * delta


func _on_static_body_3d_body_entered(body: Node3D) -> void:
	queue_free()
