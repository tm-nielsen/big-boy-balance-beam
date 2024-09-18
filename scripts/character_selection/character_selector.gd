@tool
class_name CharacterSelector
extends SelectionCarousel

signal character_selected(player_node)

@export var player_target: PlayerController

@export_subgroup('preview settings', 'preview')
@export var preview_prefab: PackedScene
@export var preview_radius: float = 12
@export var preview_edge_radius: float = 6

@export_subgroup('directories')
@export_dir var local_character_path := 'res://visuals/characters'
@export_dir var extra_characters_path := 'characters'

var character_file_paths: Array[String]


func start_selecting():
  explicitly_selected_index = -1
  selection_rotation = 0
  show()
  player_target.hide()


func _create_items(parent_node: Node):
  character_file_paths = _get_file_paths()
  items = _create_previews(character_file_paths, parent_node)
  

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


func _create_previews(file_paths: Array[String], parent: Node) -> Array[CharacterPreview]:
  var character_previews: Array[CharacterPreview] = []
  for file_path in file_paths:
    var preview_node = _create_preview(file_path, parent)
    character_previews.append(preview_node)
  _move_items()
  _reset_preview_jiggle()
  return character_previews

func _create_preview(file_path: String, parent: Node) -> CharacterPreview:
  var new_preview = preview_prefab.instantiate()
  parent.add_child(new_preview)
  new_preview.file_path = file_path
  return new_preview

func _reset_preview_jiggle():
  for character_preview in items:
    character_preview.reset_squish()


func _move_item(index: int):
  super(index)
  var carousel_offset = abs(_get_carousel_offset(index))
  items[index].z_index = ceil(item_count / 2.0) - carousel_offset
  var normalized_offset = _normalize_carousel_offset(carousel_offset)
  items[index].radius = lerpf(preview_radius, preview_edge_radius, normalized_offset)


func _select_item():
  var selected_filepath = character_file_paths[selected_index]
  player_target.drawer.file_path = selected_filepath

  var selected_preview = items[selected_index]
  player_target.squish_ratio = selected_preview.squish_ratio
  player_target.squish_reset_delta = selected_preview.squish_delta
  player_target.squish_state = selected_preview.squish_state
  player_target.position = position
  player_target.show()
  character_selected.emit(player_target)
  hide()