class_name ScaledPathDrawer
extends Control

@export var scale_factor: float = 64 / 1280.0

var path: ColouredPath

func _process(_delta):
    queue_redraw()

func _draw():
    if path == null:
        return

    var transformed_path = PackedVector2Array()
    for point in path.points:
        transformed_path.append(point + size / 2)
    
    path._draw_path(self, transformed_path)