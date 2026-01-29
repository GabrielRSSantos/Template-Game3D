extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.004

@onready var head = $head
@onready var camera = $head/Camera3D
@onready var raycast = $head/Camera3D/RayCast3D
@export var is_first_person := false

#Player Animation
@onready var character_female_a: Node3D = $"character-female-a"
@onready var animation_player: AnimationPlayer = $"character-female-a/AnimationPlayer"
var is_attacking := false

#BULLET
@onready var gun_barrel = $head/coming_bullet
@onready var aim = $Aim/AimMesh
@onready var end_point_raycast: MeshInstance3D = $head/Camera3D/RayCast3D/bullet_position
var bullet = load("res://scenes/bullet.tscn")

#Player Interaction
@onready var player_interaction: RayCast3D = $head/Camera3D/PlayerInteraction
var can_search := false

#Player Interaction TopDown
@onready var player_interaction_top_down: Area3D = $PlayerInteraction
var searching := false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event.is_action_pressed("camera_control"):
		is_first_person = !is_first_person
	if event is InputEventMouseMotion:
		character_female_a.rotate_y(-event.relative.x * SENSITIVITY)
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(10))
	#if event.is_action_pressed("Teste"):
		#print("Teste pressed")
		#$"../Abandoned_House2/Casa/Puerta".rotate_y(90)

func _process(delta: float) -> void:
	gun_barrel.look_at(end_point_raycast.global_transform.origin)
	#player_interaction_search_logic()
	endpoint_raycast_update()
	
	#Camera
	#first_person_config()

func _physics_process(delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		#bullet_instance()
	if not is_on_floor():
		velocity += get_gravity() * delta
	if Input.is_action_just_pressed("space") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("a", "d", "w", "s")
	var direction = (head.transform.basis * transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	animation_character(direction)
	
	if can_search:
		if Input.is_action_just_pressed("E"):
			print("START SEARCHING")
			searching = true
	if searching:
		player_search(delta)
	move_and_slide()

func first_person_config() -> void:
	if is_first_person:
		camera.position = Vector3(0, 0, 0)
		#aim.position = Vector2(20,18)
	else:
		camera.position = Vector3(0.6, 0.6, 1.2)
		camera.position = Vector3(0.5, 1, 2)
		#aim.position = Vector2(10,35)

func bullet_instance() -> void:
	var instance = bullet.instantiate()
	instance.position = gun_barrel.global_position
	instance.transform.basis = gun_barrel.global_transform.basis
	get_parent().add_child(instance)

func endpoint_raycast_update() -> void:
	if raycast.is_colliding():
		end_point_raycast.global_transform.origin = raycast.get_collision_point()
	else:
		end_point_raycast.position = Vector3(-0.1, -0.7, -10)

func player_interaction_search_logic() -> void:
	if player_interaction.is_colliding() and player_interaction.get_collider() is Box:
		can_search = true
	else:
		can_search = false

func animation_character(direction) -> void:
	if is_attacking:
		return
		
	if not is_on_floor():
		animation_player.play("jump")
	elif direction and is_on_floor():
		animation_player.play("walk")
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		is_attacking = true
		animation_player.play("attack-melee-right")
	else:
		animation_player.play("idle")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack-melee-right":
		is_attacking = false

func _on_player_interaction_body_entered(body: Node3D) -> void:
	can_search = check_is_box(body)
	print(can_search)

func _on_player_interaction_body_exited(body: Node3D) -> void:
	can_search = check_is_box(body)
	print(can_search)

func check_is_box(box : Node3D) -> bool:
	return box is Box
	
func player_search(delta) -> void:
	print("Searching...")
	$Sprite3D.visible = true
	$SubViewport/ProgressBar.value += delta * 10
