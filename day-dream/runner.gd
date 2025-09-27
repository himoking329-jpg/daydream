extends RigidBody2D

@export var obstacle_scene: PackedScene
@export var coin_scene: PackedScene
@export var police_scene: PackedScene

@export var spawn_interval: float = 1.4
@export var obstacle_min_y: int = 120
@export var obstacle_max_y: int = 260
@export var coin_chance: float = 0.35
@export var police_spawn_after_seconds: float = 20.0

var timer: float = 0.0
var police_timer: float = 0.0
var time_elapsed: float = 0.0

func _process(delta: float) -> void:
	time_elapsed += delta
	timer += delta
	police_timer += delta

	if timer >= spawn_interval:
		timer = 0
		_spawn_obstacle_or_coin()

	# spawn police once after some time (or use difficulty scale)
	if police_scene and police_timer >= police_spawn_after_seconds:
		police_timer = -99999 # one-time
		var p = police_scene.instantiate()
		# spawn police behind the player so it can chase
		var player = get_tree().get_current_scene().get_node("Player")
		if player:
			p.global_position = player.global_position - Vector2(320, -0) # spawn behind
		get_tree().get_current_scene().add_child(p)

func _spawn_obstacle_or_coin() -> void:
	var root = get_tree().get_current_scene()
	var player = root.get_node("Player") if root.has_node("Player") else null
	if player == null:
		return

	var x_spawn = player.global_position.x + 800 + randi() % 200
	if randf() < coin_chance:
		var coin = coin_scene.instantiate()
		coin.global_position = Vector2(x_spawn, randf_range(obstacle_min_y - 60, obstacle_min_y - 20))
		root.get_node("Coins").add_child(coin)
	else:
		var obs = obstacle_scene.instantiate()
		obs.global_position = Vector2(x_spawn, randf_range(obstacle_min_y, obstacle_max_y))
		root.get_node("Obstacles").add_child(obs)
