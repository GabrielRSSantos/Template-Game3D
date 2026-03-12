extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.004

@export var can_control = true

@onready var head = $Head
@onready var camera = $Head/CameraHead
@onready var raycast = $Head/RayCastBullet

#Player Animation
@onready var character_female_a: Node3D = $"character-female-a"
@onready var animation_player: AnimationPlayer = $"character-female-a/AnimationPlayer"
var is_attacking := false

#BULLET
@onready var bullet_spawn = $Head/BulletSpawn
@onready var end_point_raycast: MeshInstance3D = $Head/RayCastBullet/BulletPosition
var bullet = load("res://scenes/bullet.tscn")

#Player Interaction
@onready var sub_viewport: SubViewport = $SubViewport
@onready var sprite_sub_viewport: Sprite3D = $Head/SearchBarSprite
@onready var progress_bar_searching: ProgressBar = $SubViewport/ProgressBar
@onready var player_interaction_top_down: Area3D = $Head/PlayerInteraction
@onready var press_button_sprite: Sprite3D = $Head/PressButtonSprite

var can_rotate := true
var can_search := false
var searching := false
var item_in_box : Array[ItemData] = []

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion and can_rotate:
		character_female_a.rotate_y(-event.relative.x * SENSITIVITY)
		head.rotate_y(-event.relative.x * SENSITIVITY)

func _physics_process(delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		#bullet_instance()
	if not is_on_floor():
		velocity += get_gravity() * delta
	if Input.is_action_just_pressed("space") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("a", "d", "w", "s")
	if not can_control or $PlayerCanvas/ItemsInTheBox.visible:
		input_dir = Vector2.ZERO
	var direction = (head.transform.basis * transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	animation_character(direction)
	move_and_slide()
	player_search(item_in_box, delta)

func bullet_instance() -> void:
	var instance = bullet.instantiate()
	instance.position = bullet_spawn.global_position
	instance.transform.basis = bullet_spawn.global_transform.basis
	get_parent().add_child(instance)

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
		$Head/SlashNode/AnimationSlash.play("Slash")
	else:
		animation_player.play("idle")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack-melee-right":
		is_attacking = false
		$Head/SlashNode/AnimationSlash.play("RESET")

func player_search(items, delta) -> void:
	if can_search:
		press_button_sprite.visible = true
		if Input.is_action_just_pressed("E"):
			searching = true
	else:
		searching = false
	
	if searching:
		searching_item(items, delta)
	else:
		can_rotate = true
		sprite_sub_viewport.visible = false
		progress_bar_searching.value = 0

func searching_item(items, delta) -> void:
	press_button_sprite.visible = false
	can_rotate = false
	sprite_sub_viewport.visible = true
	#progress_bar_searching.value += delta * 60
	progress_bar_searching.value = 100
	if progress_bar_searching.value == 100:
		#item_found(item)
		items_found(items)
		searching = false

func clean_searching_progress() -> void:
	item_in_box.clear()
	can_search = false
	searching = false
	can_rotate = true
	sprite_sub_viewport.visible = false
	press_button_sprite.visible = false
	progress_bar_searching.value = 0

func items_found(items: Array[ItemData]) -> void:
	$PlayerCanvas/ItemsInTheBox.open_box(item_in_box)

func item_found(item : ItemData) -> void:
	if item == null:
		return
	
	var slot = $PlayerCanvas/PlayerUI/Slot
	for child in slot.get_children():
		child.queue_free()

	var item_icon = Item.new()
	
	item_icon.texture = item.texture
	item_icon.name = item.name
	item_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	item_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	item_icon.custom_minimum_size = Vector2(40, 40) 

	slot.add_child(item_icon)

func _on_player_interaction_body_entered(body: Node3D) -> void:
	if body is Box:
		item_in_box = body.items
		body.aplicar_outline()
		can_search = true

func _on_player_interaction_body_exited(body: Node3D) -> void:
	body.remover_outline()
	clean_searching_progress()
