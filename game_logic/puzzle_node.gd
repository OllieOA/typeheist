class_name PuzzleNode
extends Node2D

@onready var puzzle_sprite: Sprite2D = %PuzzleSprite

enum IconType {CIRCLE, SQUARE, DIAMOND}
var icon_type_map = [IconType.CIRCLE, IconType.SQUARE, IconType.DIAMOND]

const BASE_SCALE = Vector2(0.8, 0.8)

const TEXTURE_LOOKUP: Dictionary = {
	IconType.CIRCLE: {
		"inactive": preload("res://game_logic/network/circle_icon_empty.svg"),
		"active": preload("res://game_logic/network/circle_icon_filled.svg")
	},
	IconType.SQUARE: {
		"inactive": preload("res://game_logic/network/square_icon_empty.svg"),
		"active": preload("res://game_logic/network/square_icon_filled.svg")
	},
	IconType.DIAMOND: {
		"inactive": preload("res://game_logic/network/diamond_icon_empty.svg"),
		"active": preload("res://game_logic/network/diamond_icon_filled.svg")
	}
}

const COLOR_LOOKUP: Dictionary = {
	IconType.CIRCLE: {
		"active": Color.RED,
		"inactive": Color.DARK_RED
	},
	IconType.SQUARE: {
		"active": Color.GREEN,
		"inactive": Color.DARK_GREEN
	},
	IconType.DIAMOND: {
		"active": Color.MEDIUM_BLUE,
		"inactive": Color.DARK_BLUE
	}
}

var icon_type: IconType

var node_base_coord: Vector2i
var node_enabled: bool = true
var node_active: bool = false

var target_position: Vector2
var close_enough: bool = false

var max_jiggle_size: float = 10.0
var min_jiggle_time: float = 1.0

var rng = RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()


func _process(delta: float) -> void:
	_jiggle()


func _jiggle() -> void:
	if node_base_coord == null:
		return
	if target_position == Vector2.ZERO or target_position == null:
		target_position = global_position

	close_enough = global_position.distance_to(target_position) < 1.0
	
	if close_enough:
		var new_random_vector = Vector2(rng.randf_range(-max_jiggle_size, max_jiggle_size), rng.randf_range(-max_jiggle_size, max_jiggle_size))
		target_position = Vector2(node_base_coord) + new_random_vector
		
		var pos_tween = get_tree().create_tween()
		pos_tween.tween_property(self, "global_position", target_position, min_jiggle_time + randf_range(0, min_jiggle_time)).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)


func set_icon_type(requested_icon: int) -> void:
	print(requested_icon)
	icon_type = icon_type_map[requested_icon]
	deactivate_node()


func activate_node() -> void:
	node_active = true
	
	puzzle_sprite.texture = TEXTURE_LOOKUP[icon_type]["active"]
	var zoom_tween = get_tree().create_tween()
	zoom_tween.tween_property(puzzle_sprite, "scale", BASE_SCALE + Vector2(0.2, 0.2), 0.1).set_ease(Tween.EASE_IN_OUT)
	
	var color_tween = get_tree().create_tween()
	color_tween.tween_property(puzzle_sprite, "modulate", COLOR_LOOKUP[icon_type]["active"], 0.1)
	
	var alpha_tween = get_tree().create_tween()
	alpha_tween.tween_property(puzzle_sprite, "modulate:a", 1.0, 0.1)


func deactivate_node() -> void:
	node_active = false
	
	puzzle_sprite.texture = TEXTURE_LOOKUP[icon_type]["inactive"]
	var zoom_tween = get_tree().create_tween()
	zoom_tween.tween_property(puzzle_sprite, "scale", BASE_SCALE, 0.1).set_ease(Tween.EASE_IN_OUT)
	
	var color_tween = get_tree().create_tween()
	color_tween.tween_property(puzzle_sprite, "modulate", COLOR_LOOKUP[icon_type]["inactive"], 0.1)
	
	var alpha_tween = get_tree().create_tween()
	alpha_tween.tween_property(puzzle_sprite, "modulate:a", 1.0, 0.1)


func disable_node() -> void:
	if node_enabled:
		if node_active:
			deactivate_node()
		node_enabled = false
		var zoom_tween = get_tree().create_tween()
		zoom_tween.tween_property(puzzle_sprite, "scale", BASE_SCALE - Vector2(0.2, 0.2), 0.1).set_ease(Tween.EASE_IN_OUT)
		
		var color_tween = get_tree().create_tween()
		color_tween.tween_property(puzzle_sprite, "modulate", COLOR_LOOKUP[icon_type]["inactive"], 0.1)
		
		var alpha_tween = get_tree().create_tween()
		alpha_tween.tween_property(puzzle_sprite, "modulate:a", 0.8, 0.1)


func enable_node() -> void:
	if not node_enabled:
		node_enabled = true
		activate_node()


func _check_to_enabled() -> void:
	if not node_enabled:
		enable_node()