class_name PathSetDrawer
extends Node2D

var paths: Array[ColouredPath] = []: set = _set_paths


func _set_paths(p_paths: Array[ColouredPath]):
    paths = p_paths
    queue_redraw()

func add_path(p_path):
    paths.append(p_path)
    queue_redraw()

func remove_path(p_path):
    paths.erase(p_path)
    queue_redraw()

func insert_path(p_index: int, p_path):
    paths.insert(p_index, p_path)
    queue_redraw()

func set_path(p_index: int, p_path):
    if p_index < paths.size():
        paths[p_index] = p_path
    else:
        add_path(p_path)
    queue_redraw()


func move_path(p_from_index: int, p_to_index: int):
    var path = paths[p_from_index]
    paths.remove_at(p_from_index)
    paths.insert(p_to_index, path)


func _draw():
    for path in paths:
        _draw_path(path)

func _draw_path(path: ColouredPath):
    path.draw_path(self)
