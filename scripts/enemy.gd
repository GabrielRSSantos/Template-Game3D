extends CharacterBody3D
class_name Enemy

@export var health := 100

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
@onready var navigation = $NavigationAgent3D
@export var target_player: CharacterBody3D
@export var is_following := false

func _process(delta: float) -> void:
	if health <= 0:
		queue_free()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	var next_location = navigation.get_next_path_position()
	var current_location = global_transform.origin
	var new_velocity = (next_location - current_location).normalized() * SPEED
	
	velocity = velocity.move_toward(new_velocity, 0.25)
	if is_following:
		navigation.target_position = target_player.position
	move_and_slide()
	
