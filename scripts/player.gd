extends CharacterBody3D

const JUMP_VELOCITY = 4.5

var speed = 3.0
var original_speed
var sprint_speed = 7.0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var sprint_slider
var sprint_drain_amount = 0.5
var sprint_refresh_amount = 0.3
var tired

func _ready() -> void:
	tired = false
	original_speed = speed
	sprint_slider = get_node("/root/" + get_tree().current_scene.name + "/UI/sprint_slider")

func _process(delta: float) -> void:
	if speed == sprint_speed:
		sprint_slider.value = sprint_slider.value - sprint_drain_amount * delta
		if sprint_slider.value <= sprint_slider.min_value:
			tired = true
			speed = original_speed
	else:
		if sprint_slider.value < sprint_slider.max_value:
			sprint_slider.value = sprint_slider.value + sprint_refresh_amount * delta
		else:
			tired = false
			sprint_slider.visible = false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		
		if Input.is_action_just_pressed("sprint"):
			if !tired:
				sprint_slider.visible = true
				speed = sprint_speed
		if Input.is_action_just_released("sprint"):
			speed = original_speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		speed = original_speed
	

	move_and_slide()
