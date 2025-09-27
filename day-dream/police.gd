extends CharacterBody2D
# Police.gd

@export var speed: float = 260.0
@export var gravity: float = 1400.0
@export var jump_velocity: float = -420.0
@export var detection_range: float = 2000.0
@export var attack_distance: float = 32.0

var player_ref: Node = null
func _ready() -> void:
	player_ref = get_tree().get_current_scene().get_node("Player") if get_tree().get_current_scene().has_node("Player") else null

func _physics_process(delta: float) -> void:
	if player_ref == null:
		return

	var to_player = player_ref.global_position - global_position
	if to_player.x > detection_range or to_player.x < -detection_range:
		# too far, idle or patrol
		velocity.x = 0
	else:
		# chase only if player is to the right (runner game sense)
		if to_player.x > 10:
			velocity.x = speed
		elif to_player.x < -10:
			velocity.x = -speed
		else:
			velocity.x = 0

	# gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	# try to jump small obstacles (basic)
	if is_on_floor():
		var space_state = get_world_2d().direct_space_state
		var ahead_start = global_position
		var ahead_end = global_position + Vector2(16, -30)
		var params = PhysicsRayQueryParameters3D.new()
		params.from = ahead_start
		params.to = ahead_end
		params.exclude = [self]
		var result = space_state.intersect_ray(params)
		if result:
			velocity.y = jump_velocity

	move_and_slide()

	# detect collision with block and stop for a moment
	for i in get_last_slide_collision():
		var coll = get_last_slide_collision()[i]
		if coll and coll.get_collider().is_in_group("blocks"):
			# blocked: stop and maybe play animation
			velocity.x = 0
