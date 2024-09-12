@tool
class_name CharacterSelector
extends Node2D

@export_dir var local_character_path := 'res://visuals/characters'
@export_dir var extra_characters_path := 'characters'

@export var preview_prefab: PackedScene
@export var label_prefab: PackedScene

@export var spin_speed: float = 1
@export var previews_on_dial: float = 3
@export var dial_radius: float = 80

@export_subgroup('drawing')
@export var rect := Rect2(-16, 0, 32, 92)
@export var fill_colour := Color.TRANSPARENT
@export var border_colour := Color.BLACK
@export var border_width: float = 2

var clipping_parent: Sprite2D

var character_previews: Array[CharacterPreview]
var name_labels: Array[CharacterNameLabel]

var label_offset: Vector2
var option_count: int

var selection_rotation: float
var selected_index: int: get = _get_selected_index


func _ready():
  _create_clipping_parent()
  label_offset = _get_label_offset()
  var paths = _get_file_paths()
  option_count = paths.size()
  _create_items(paths)

func _process(delta: float):
  queue_redraw()
  selection_rotation += delta * spin_speed
  if selection_rotation > option_count:
    selection_rotation -= option_count
  move_items()


func _create_clipping_parent():
  clipping_parent = Sprite2D.new()
  var clip_texture = PlaceholderTexture2D.new()
  clip_texture.size = abs(rect.size) - Vector2.ONE * border_width
  clipping_parent.texture = clip_texture
  clipping_parent.clip_children = CanvasItem.CLIP_CHILDREN_ONLY
  add_child(clipping_parent)
  var pos = rect.get_center() + Vector2.UP * rect.size.y / 2
  clipping_parent.position = pos


func _get_file_paths() -> Array[String]:
  var file_paths: Array[String] = []
  var local_paths = _get_paths_in_directory(local_character_path)
  var extra_paths = _get_paths_in_directory(extra_characters_path)
  file_paths.append_array(local_paths)
  file_paths.append_array(extra_paths)
  return file_paths

func _get_paths_in_directory(directory_path: String) -> Array[String]:
  var file_paths: Array[String] = []
  var dir_access = DirAccess.open(directory_path)
  if dir_access:
    dir_access.list_dir_begin()
    var file_name = dir_access.get_next()
    while file_name:
      if dir_access.current_is_dir():
        var subdirectory_path = directory_path + '\\' + file_name
        var subdirectory_paths = _get_paths_in_directory(subdirectory_path)
        file_paths.append_array(subdirectory_paths)
      elif file_name.ends_with('.svg'):
        file_paths.append(directory_path + '\\' + file_name)
      file_name = dir_access.get_next()
  return file_paths


func move_items():
  for i in option_count:
    var pos = _get_global_position_by_index(i)
    character_previews[i].global_position = pos
    name_labels[i].global_position = pos + label_offset


func _create_items(file_paths: Array[String]):
  character_previews = []
  name_labels = []
  for file_path in file_paths:
    character_previews.append(_create_preview(file_path))
    name_labels.append(_create_label(file_path))
  move_items()

func _create_preview(file_path: String) -> CharacterPreview:
  var new_preview = preview_prefab.instantiate()
  clipping_parent.add_child(new_preview)
  new_preview.file_path = file_path
  return new_preview

func _create_label(file_path: String) -> CharacterNameLabel:
  var new_label = label_prefab.instantiate()
  clipping_parent.add_child(new_label)
  var file_name = file_path.get_file()
  file_name = file_name.replace('_', ' ')
  new_label.text = file_name.left(-4)
  new_label.size.x = abs(rect.size.x - 2 * rect.position.x)
  return new_label


func _get_global_position_by_index(index: int) -> Vector2:
  if selection_rotation - index < -option_count / 2.0:
    index -= option_count
  elif index - selection_rotation < -option_count / 2.0:
    index += option_count
  var t = (index - selection_rotation) / previews_on_dial
  t = clampf(t, -1, 1)
  t = sin(0.5 * PI * t)
  return global_position + Vector2(0, t * dial_radius)


func _get_label_offset() -> Vector2:
  var x = rect.size.x - rect.position.x
  return Vector2(x, 0)


func _get_selected_index() -> int:
  return roundi(selection_rotation)


func _draw():
  var offset_rect = rect
  offset_rect.position.y -= rect.size.y / 2
  draw_rect(offset_rect, fill_colour)
  draw_rect(offset_rect, border_colour, false, border_width)
