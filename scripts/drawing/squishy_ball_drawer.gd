@tool
class_name SquishyBallDrawer
extends Node2D

@export var fill_colour := Color.WHITE
@export var stroke_colour := Color.BLACK
@export var stroke_width: float = 1.5
@export var radius: float = 20: set = set_radius

@export var max_visual_ellipse_squish_ratio: float = 0.65

var visual_rotation: float = 0.0
var squish_ratio: float = 1.0
var squish_normal: Vector2 = Vector2.UP
var squish_state: int = 0

var stadium_dimensions = {
    radius = 20.0,
    length = 0.0,
    position_offset = Vector2.ZERO
}
var elliptical_extents: Vector2


func set_radius(p_radius: float):
    radius = p_radius
    queue_redraw()

func update_parameters(p_rotation: float, p_squish_ratio: float, p_squish_normal: Vector2, p_squish_state: int):
    visual_rotation = p_rotation
    squish_ratio = p_squish_ratio
    squish_normal = p_squish_normal.normalized()
    squish_state = p_squish_state
    queue_redraw()


func _draw():
    if Engine.is_editor_hint():
        draw_editor_shape()
        return

    match squish_state:
        SquishyPhysicsBall.SquishState.CIRCLE:
            draw_bordered_circle()
        SquishyPhysicsBall.SquishState.ELLIPSE:
            draw_ellipse()
        SquishyPhysicsBall.SquishState.STADIUM:
            draw_stadium()
        SquishyPhysicsBall.SquishState.EGG:
            draw_egg()

func draw_bordered_circle() -> void:
    ShapeDrawer.draw_circle(self, radius, fill_colour, stroke_width, stroke_colour)


func draw_ellipse() -> void:
    var clamped_squish_ratio = clamp(squish_ratio, max_visual_ellipse_squish_ratio, 1 / max_visual_ellipse_squish_ratio)

    var ellipse_normal_radius = radius * clamped_squish_ratio
    var ellipse_tangent_radius = radius / clamped_squish_ratio
    var ellipse_points = ShapeGenerator.generate_ellipse(ellipse_tangent_radius, ellipse_normal_radius, squish_normal)

    ShapeDrawer.draw_shape(self, ellipse_points, fill_colour, stroke_width, stroke_colour)
    _set_elliptical_extents(ellipse_points)

func _set_elliptical_extents(ellipse_points: PackedVector2Array):
    elliptical_extents = Vector2.ZERO
    for point in ellipse_points:
        if point.y > elliptical_extents.y:
            elliptical_extents.y = point.y
        if point.x > elliptical_extents.x:
            elliptical_extents.x = point.x
    return elliptical_extents

func get_elliptical_length(angle: float) -> float:
    var clamped_squish_ratio = clamp(squish_ratio, max_visual_ellipse_squish_ratio, 1 / max_visual_ellipse_squish_ratio)

    var ellipse_tangent_radius = radius / clamped_squish_ratio
    var ellipse_normal_radius = radius * clamped_squish_ratio

    var tangent = squish_normal.rotated(-PI / 2)
    return abs((tangent * cos(angle) * ellipse_tangent_radius + squish_normal * sin(angle) * ellipse_normal_radius).x)


func draw_stadium():
    stadium_dimensions.radius = radius * squish_ratio
    stadium_dimensions.length = (PI * radius * (1 - squish_ratio)) / (2 * squish_ratio)
    stadium_dimensions.position_offset = Vector2.DOWN * (radius - stadium_dimensions.radius)

    ShapeDrawer.draw_stadium(self, stadium_dimensions.radius, stadium_dimensions.length,
            fill_colour, stroke_width, stroke_colour, stadium_dimensions.position_offset)

func get_stadium_horizontal_extent():
    return stadium_dimensions.radius + stadium_dimensions.length / 2


func draw_egg():
    var circular_radius = radius / squish_ratio
    var elliptical_radius = radius * (2 * squish_ratio - 1 / squish_ratio)

    ShapeDrawer.draw_egg(self, circular_radius, elliptical_radius, -squish_normal, fill_colour, stroke_width, stroke_colour)



func draw_editor_shape():
    var points = PackedVector2Array()

    for i in range(12):
        var angle = i * 2 * PI / 12
        points.push_back(Vector2(cos(angle), sin(angle)) * radius)

    draw_colored_polygon(points, fill_colour)

    if stroke_width > 0:
        points.push_back(points[0])
        draw_polyline(points, stroke_colour, stroke_width)