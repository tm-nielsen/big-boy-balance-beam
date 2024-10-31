@tool
class_name RoundManager
extends Node2D

@export var win_threshold: int = 4
var win_threshold_reached: bool: get = _get_win_threshold_reached

@export_subgroup('scoring lights', 'light')
@export var light_prefab: PackedScene
@export var light_placement_area := Rect2(24, -24, 60, 60)
@export var light_grid_columns: int = 2

@export_subgroup('debug')
@export var replace_lights: bool: set = _set_replace_lights

var scoring_lights: Array[Array] = []
var player_scores: Array[int] = [0, 0]


func _ready():
  recreate_lights()

func recreate_lights():
  _clear_lights()
  scoring_lights.append(_create_lights(-1))
  scoring_lights.append(_create_lights(1))

func _create_lights(direction: int) -> Array[ScoringLight]:
  var lights: Array[ScoringLight] = []
  for i in win_threshold:
    var new_light = light_prefab.instantiate()
    new_light.position = _get_light_position(i, direction)
    lights.append(new_light)
    add_child(new_light)
  return lights

func _get_light_position(index: int, direction := 1) -> Vector2:
  var pos = light_placement_area.position
  var columns = min(light_grid_columns, win_threshold)
  var x_spacing = light_placement_area.size.x / clampi((columns - 1), 1, win_threshold)
  var rows = ceil(float(win_threshold) / columns)
  var y_spacing = light_placement_area.size.y / clampi((rows - 1), 1, win_threshold)
  pos.x += x_spacing * (index % columns)
  pos.x *= direction
  pos.y += y_spacing * (index / columns)
  return pos


func reset_round():
  player_scores[0] = 0
  player_scores[1] = 0
  for light_array in scoring_lights:
    for light in light_array: light.turn_off()

func add_player_score(scoring_index: int) -> bool:
  var current_score = player_scores[scoring_index]
  scoring_lights[scoring_index][current_score].turn_on()
  var new_score = current_score + 1
  player_scores[scoring_index] = new_score
  return new_score >= win_threshold


func _get_win_threshold_reached() -> bool:
  for score in player_scores:
    if score >= win_threshold: return true
  return false

func _set_replace_lights(_value: bool):
  recreate_lights()

func _clear_lights():
  for light_array in scoring_lights:
    for light in light_array: light.queue_free()
  scoring_lights.clear()