@tool
class_name CharacterSelector
extends SelectionCarousel

signal character_selected(file_path: String)

@export var preview_prefab: PackedScene

@export_subgroup('directories')
@export_dir var local_character_path := 'res://visuals/characters'
@export_dir var extra_characters_path := 'characters'

var character_file_paths: Array[String]


func _create_items():
  character_file_paths = _get_file_paths()
  items = _create_previews(character_file_paths)
  

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


func _create_previews(file_paths: Array[String]) -> Array[CharacterPreview]:
  var character_previews: Array[CharacterPreview] = []
  for file_path in file_paths:
    character_previews.append(_create_preview(file_path))
  _move_items()
  _reset_preview_jiggle()
  return character_previews

func _create_preview(file_path: String) -> CharacterPreview:
  var new_preview = preview_prefab.instantiate()
  clipping_parent.add_child(new_preview)
  new_preview.file_path = file_path
  return new_preview

func _reset_preview_jiggle():
  for character_preview in items:
    character_preview.reset_squish()


func _select_item():
  character_selected.emit(character_file_paths[selected_index])