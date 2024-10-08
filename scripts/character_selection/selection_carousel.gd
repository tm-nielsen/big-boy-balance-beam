@tool
class_name SelectionCarousel
extends Node2D

@export_range(1, 2) var player_index: int = 1
@export var clipping_margin := Vector2(24, 0)

@export_subgroup('movement settings')
@export var spin_speed: float = 6
@export var elasticity: float = 2
@export var friction: float = 0.15
@export var selection_impulse: float = 6
@export var selection_scroll_delay: float = 0.25;

@export_subgroup('carousel settings')
@export var carousel_item_count: float = 3
@export var carousel_radius: float = 80

@export_subgroup('drawing')
@export var size := Vector2(48, 110)
@export var curve_radius: float = 4
@export var curve_steps: int = 6
@export var caret_size := Vector2(4, 8)
@export var fill_colour := Color.TRANSPARENT
@export var border_colour := Color.BLACK
@export var border_width: float = 2

var item_viewport: Viewport
var items := []

var item_count: int

var selection_rotation: float
var selection_velocity: float
var explicitly_selected_index: int = -1
var selected_index: int: get = _get_selected_index
var selection_scroll_timer: float

var hidden_index: int = -1
var hidden_item: CanvasItem


func _ready():
  item_viewport = _create_viewport()
  _create_items(item_viewport)
  item_count = items.size()

func _process(_delta: float):
  if !visible: return
  if Engine.is_editor_hint(): queue_redraw()
  elif is_numbered_action_just_pressed('button'):
    _select_item()

func _physics_process(delta: float):
  _process_movement(delta)
  _move_items()

func _select_item(): pass


func _process_movement(delta: float):
  if !Engine.is_editor_hint():
    _process_input(delta)

  if explicitly_selected_index == -1:
    _spin_constant(delta)
  else:
    _spin_to_selected_index(delta)


func _process_input(delta: float):
    if is_numbered_action_pressed('up'):
      _process_delayed_scroll(delta, 1)
    elif is_numbered_action_pressed('down'):
      _process_delayed_scroll(delta, -1)
    else:
      selection_scroll_timer = 0

func _process_delayed_scroll(delta: float, direction := 1):
  if selection_scroll_timer * direction <= 0:
    selection_scroll_timer = selection_scroll_delay * direction
  selection_scroll_timer += delta * direction
  if selection_scroll_timer * direction > selection_scroll_delay:
    selection_scroll_timer -= selection_scroll_delay * direction
    _scroll(direction)


func _scroll(direction := 1):
  explicitly_selected_index = selected_index + direction
  selection_velocity += selection_impulse * direction
  _wrap_selected_index()
  if selection_rotation * direction > explicitly_selected_index * direction:
    selection_rotation -= item_count * direction

func _wrap_selected_index():
  if explicitly_selected_index >= item_count:
    explicitly_selected_index -= item_count
  elif explicitly_selected_index < 0:
    explicitly_selected_index += item_count



func _spin_constant(delta: float):
  selection_rotation -= delta * spin_speed
  if selection_rotation < 0:
    selection_rotation += item_count

func _spin_to_selected_index(delta: float):
    var offset = selected_index - selection_rotation
    selection_velocity += offset * elasticity
    selection_velocity *= (1 - friction * delta * 60)

    selection_rotation += selection_velocity * delta


func _create_viewport() -> Node:
  var viewport = SubViewport.new()
  viewport.transparent_bg = true
  viewport.canvas_item_default_texture_filter = texture_filter
  var container = SubViewportContainer.new()
  add_child(container)
  container.position = -(size + clipping_margin) / 2
  container.position.y += border_width / 2
  container.size = size + clipping_margin - Vector2.ONE * border_width
  container.stretch = true
  container.add_child(viewport)
  return viewport

func _create_items(_parent_node: Node): pass


func _move_items(ignore_velocity := false):
  for i in item_count:
    _move_item(i, ignore_velocity)

func _move_item(index: int, ignore_velocity := false):
  var centre = (size + clipping_margin) / 2
  var new_position = centre + _get_displacement(index)
  if ignore_velocity:
    items[index].move_without_squish(new_position)
  else:
    items[index].position = new_position


func _get_carousel_offset(index: int) -> float:
  var offset = index - selection_rotation
  return wrapf(offset, -item_count / 2.0, item_count / 2.0)

func _get_normalized_carousel_offset(index: int) -> float:
  var offset = _get_carousel_offset(index)
  return _normalize_carousel_offset(offset)

func _normalize_carousel_offset(offset: float) -> float:
  var t = offset / carousel_item_count
  t = clampf(t, -1, 1)
  return sin(0.5 * PI * t)

func _get_displacement(index: int) -> Vector2:
  var carousel_offset = _get_normalized_carousel_offset(index)
  return Vector2(0, carousel_offset * carousel_radius)


func _hide_item(index: int):
  hidden_item = items[index]
  hidden_item.hide()
  items.remove_at(index)
  item_count -= 1
  hidden_index = index
  if index == explicitly_selected_index:
    selection_rotation -= 1
  elif index < explicitly_selected_index:
    explicitly_selected_index -= 1
    selection_rotation -= 1
  _move_items(true)

func _unhide_item():
  if hidden_item:
    hidden_item.show()
    items.insert(hidden_index, hidden_item)
    item_count += 1
  if hidden_index > explicitly_selected_index && explicitly_selected_index > 0:
    explicitly_selected_index += 1
    selection_rotation += 1
  _move_items(true)


func _get_selected_index() -> int:
  if explicitly_selected_index >= 0:
    return explicitly_selected_index
  var rounded_index = roundi(selection_rotation)
  if rounded_index >= item_count: return 0
  return rounded_index


func _draw():
  var points = PackedVector2Array()
  points.append_array(_get_curve_points(-size / 2, -1, 1))
  points.append_array(_get_curve_points(size / 2, 1, -1))
  
  draw_colored_polygon(points, fill_colour)
  points.append(points[0])
  draw_polyline(points, border_colour, border_width)

  _draw_caret(-Vector2((size.x + curve_radius) / 2, 0), 1)
  _draw_caret(Vector2((size.x + curve_radius) / 2, 0), -1)

func _get_curve_points(origin: Vector2, x_direction: float, y_direction: float) -> PackedVector2Array:
  var points = PackedVector2Array()
  origin.x -= x_direction * curve_radius / 2
  for i in curve_steps:
    var p = origin
    p.x += x_direction * curve_radius * sin(PI * i / curve_steps)
    points.append(p)
    origin.y += y_direction * size.y / curve_steps
  points.append(origin)
  return points

func _draw_caret(origin: Vector2, direction: float):
  var points = PackedVector2Array()
  var vertical_offset = Vector2.UP * caret_size.y / 2
  points.append(origin + vertical_offset)
  points.append(origin + Vector2.RIGHT * direction * caret_size.x)
  points.append(origin - vertical_offset)
  draw_colored_polygon(points, border_colour)


func is_numbered_action_just_pressed(simple_name: String) -> bool:
  return Input.is_action_just_pressed(_get_input_name(simple_name))

func is_numbered_action_pressed(simple_name: String) -> bool:
  return Input.is_action_pressed(_get_input_name(simple_name))

func _get_input_name(simple_name: String) -> String:
  return ("p%d_" % player_index) + simple_name