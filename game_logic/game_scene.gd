class_name GameScene extends Node2D

@onready var network: Network = $Network
@onready var minigames: CanvasLayer = %Minigames
@onready var surveillance_bars: CanvasLayer = $SurveillanceBars


const MINIGAME_CONSTRUCTOR_SCENE = preload("res://game_logic/minigames/base_minigame/minigame_constructor.tscn")

const MINIGAME_SPAWN_LOCATIONS: Array = [
	Vector2i(1480, 360),
	Vector2i(1440, 700),
	Vector2i(120, 700),
	Vector2i(80, 360),
	Vector2i(120, 20),
	Vector2i(1440, 20),
]

var minigame_lookup: Dictionary
var rng = RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()
	network.connect("network_node_activated", _handle_network_node_activated)
	network.connect("network_node_deactivated", _handle_network_node_deactivated)
	GameControl.connect("completed_minigame", _handle_minigame_completed)
	
	var idx = 0
	for minigame_spawn_location in MINIGAME_SPAWN_LOCATIONS:
		_spawn_minigame(idx, minigame_spawn_location)
		
		idx += 1

func _spawn_minigame(minigame_id: int, minigame_spawn_location: Vector2i) -> void:
	var new_minigame: Node = MINIGAME_CONSTRUCTOR_SCENE.instantiate()
	new_minigame.minigame_id = minigame_id

	var minigame_choice = rng.randi() % MinigameData.MinigameType.size()
	minigames.add_child(new_minigame)
	
	new_minigame.create_minigame(minigame_choice)
	new_minigame.deactivate_minigame()
	new_minigame.global_position = minigame_spawn_location
	new_minigame.minigame_base_location = minigame_spawn_location
	minigame_lookup[minigame_id] = new_minigame


func _handle_network_node_activated(node_id: int) -> void:
	minigame_lookup[node_id].activate_minigame()


func _handle_network_node_deactivated(node_id: int) -> void:
	if minigame_lookup[node_id] == null:
		return
	minigame_lookup[node_id].deactivate_minigame()


func _handle_minigame_completed(completed_minigame_id: int) -> void:
	for each_node in minigame_lookup:
		if minigame_lookup[each_node] == null and completed_minigame_id != each_node:
			_spawn_minigame(each_node, MINIGAME_SPAWN_LOCATIONS[each_node])
			GameControl.emit_signal("spawned_minigame", each_node)
