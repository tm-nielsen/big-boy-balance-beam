@tool
class_name SelectionCarousel
extends Node2D

@export_range(1, 2) var player_index: int = 1

@export_subgroup('movement settings')
@export var spin_speed: float = 6
@export var elasticity: float = 2
@export var friction: float = 0.15
@export var selection_impulse: float = 6

@export_subgroup('carousel settings')
@export var carousel_item_count: float = 3
@export var carousel_radius: float = 80

@export_subgroup('drawing')
@export var rect := Rect2(-16, 0, 32, 92)
@export var fill_colour := Color.TRANSPARENT
@export var border_colour := Color.BLACK
@export var border_width: float = 2

var clipping_parent: Sprite2D

var items := []

var item_count: int

var selection_rotation: float
var selection_velocity: float
var explicitly_selected_index: int = -1
var selected_index: int: get = _get_selected_index


func _ready():
  _create_clipping_parent()
  _create_items()
  item_count = items.size()

func _process(delta: float):
  if Engine.is_editor_hint(): queue_redraw()
  elif is_numbered_action_just_pressed('button'):
    _select_item()
  _process_movement(delta)
  _move_items()

func _select_item(): pass


func _process_movement(delta: float):
  if !Engine.is_editor_hint():
    if is_numbered_action_just_pressed('up'):
      explicitly_selected_index = selected_index + 1
      selection_velocity += selection_impulse
      if explicitly_selected_index >= item_count:
        explicitly_selected_index -= item_count
        selection_rotation -= item_count
    elif is_numbered_action_just_pressed('down'):
      explicitly_selected_index = selected_index - 1
      selection_velocity -= selection_impulse
      if explicitly_selected_index < 0:
        explicitly_selected_index += item_count
        selection_rotation += item_count

  if explicitly_selected_index == -1:
    _spin_constant(delta)
  else:
    _spin_to_selected_index(delta)

func _spin_constant(delta: float):
  selection_rotation -= delta * spin_speed
  if selection_rotation < 0:
    selection_rotation += item_count

func _spin_to_selected_index(delta: float):
    var offset = selected_index - selection_rotation
    selection_velocity += offset * elasticity
    selection_velocity *= (1 - friction * delta * 60)

    selection_rotation += selection_velocity * delta


func _create_clipping_parent():
  clipping_parent = Sprite2D.new()
  var clip_texture = PlaceholderTexture2D.new()
  clip_texture.size = abs(rect.size) - Vector2.ONE * border_width
  clipping_parent.texture = clip_texture
  clipping_parent.clip_children = CanvasItem.CLIP_CHILDREN_ONLY
  add_child(clipping_parent)
  var pos = rect.get_center() + Vector2.UP * rect.size.y / 2
  clipping_parent.position = pos


func _move_items():
  for i in item_count:
    var pos = _get_global_position_by_index(i)
    items[i].global_position = pos

func _create_items(): pass

func _get_global_position_by_index(index: int) -> Vector2:
  if selection_rotation - index < -item_count / 2.0:
    index -= item_count
  elif index - selection_rotation < -item_count / 2.0:
    index += item_count
  var t = (index - selection_rotation) / carousel_item_count
  t = clampf(t, -1, 1)
  t = sin(0.5 * PI * t)
  return global_position + Vector2(0, t * carousel_radius)


func _get_selected_index() -> int:
  if explicitly_selected_index >= 0:
    return explicitly_selected_index
  return roundi(selection_rotation)


func _draw():
  var offset_rect = rect
  offset_rect.position.y -= rect.size.y / 2
  draw_rect(offset_rect, fill_colour)
  draw_rect(offset_rect, border_colour, false, border_width)


func is_numbered_action_just_pressed(simple_name: String) -> bool:
  return Input.is_action_just_pressed(_get_input_name(simple_name))

func is_numbered_action_pressed(simple_name: String) -> bool:
  return Input.is_action_pressed(_get_input_name(simple_name))

func _get_input_name(simple_name: String) -> String:
  return ("p%d_" % player_index) + simple_name