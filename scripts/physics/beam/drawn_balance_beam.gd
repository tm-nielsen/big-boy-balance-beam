class_name DrawnBalanceBeam
extends BalanceBeam

@export var height: float = 8
@export var fill_colour: Color
@export var stroke_colour: Color
@export var stroke_width: float = -1


func _draw():
  var shape_points = PackedVector2Array()
  var right_end = Vector2.RIGHT * width / 2
  var left_end = Vector2.LEFT * width / 2
  var bottom = Vector2.DOWN * height
  var stroke_offset = Vector2.DOWN * stroke_width / 2

  shape_points.push_back(right_end + stroke_offset)
  shape_points.push_back(right_end + bottom / 2)
  shape_points.push_back(bottom)
  shape_points.push_back(left_end + bottom / 2)
  shape_points.push_back(left_end + stroke_offset)

  ShapeDrawer.draw_shape(self, shape_points, fill_colour, stroke_width, stroke_colour)