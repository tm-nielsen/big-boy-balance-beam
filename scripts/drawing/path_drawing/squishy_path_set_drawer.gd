class_name SquishyPathSetDrawer
extends PathSetDrawer

@export var max_visual_ellipse_squish_ratio: float = 0.65

var radius: float = 20

var visual_rotation := 0.0
var squish_ratio := 1.0
var squish_normal := Vector2.UP
var squish_state: int

var ellipse_params = {tangent_ratio = 1.0, normal_ratio = 1.0}
var stadium_params = {radius = 1.0, length = 1.0, length_multiplier = 1.0, offset = Vector2.ZERO}
var egg_elliptical_ratio
var squish_tangent

func set_radius(p_radius: float):
    radius = p_radius
    queue_redraw()

func update_parameters(p_rotation: float, p_squish_ratio: float, p_squish_normal: Vector2, p_squish_state: int):
    visual_rotation = p_rotation
    squish_ratio = p_squish_ratio
    squish_normal = p_squish_normal.normalized()
    squish_tangent = squish_normal.rotated(-PI / 2)
    squish_state = p_squish_state
    _calculate_shape_params()
    queue_redraw()

func _calculate_shape_params():
    match squish_state:
        SquishyPhysicsBall.SquishState.ELLIPSE:
            var clamped_squish_ratio = clamp(squish_ratio, max_visual_ellipse_squish_ratio, 1 / max_visual_ellipse_squish_ratio)
            ellipse_params.tangent_ratio = 1 / clamped_squish_ratio
            ellipse_params.normal_ratio = clamped_squish_ratio

        SquishyPhysicsBall.SquishState.STADIUM:
            var stadium_radius = radius * squish_ratio
            var stadium_length = radius * PI * (1 - squish_ratio) / (2 * squish_ratio)
            stadium_params.radius = stadium_radius
            stadium_params.length = stadium_length
            stadium_params.length_multiplier = stadium_length / (radius - stadium_radius) / 2
            stadium_params.offset = Vector2.DOWN * (radius - stadium_radius)

        SquishyPhysicsBall.SquishState.EGG:
            egg_elliptical_ratio = 2 * squish_ratio - 1 / squish_ratio


func _draw_path(path: ColouredPath):
    var distorted_path = PackedVector2Array()
    for i in range(path.points.size()):
        var distorted_point = distort_point(path.points[i])
        distorted_path.append(distorted_point)
    
    path._draw_path(self, distorted_path, draw_scale)


func distort_point(point: Vector2) -> Vector2:
    point = point.rotated(visual_rotation)

    match squish_state:
        SquishyPhysicsBall.SquishState.ELLIPSE:
            return distort_point_to_ellipse(point)
        SquishyPhysicsBall.SquishState.STADIUM:
            return distort_point_to_stadium(point)
        SquishyPhysicsBall.SquishState.EGG:
            return distort_point_to_egg(point)

    return point


func distort_point_to_ellipse(point: Vector2) -> Vector2:
    var angle = point.angle() - squish_normal.angle() + PI / 2
    var length = point.length()

    var normal = squish_normal * sin(angle) * ellipse_params.normal_ratio
    var tangent = squish_tangent * cos(angle) * ellipse_params.tangent_ratio
    return (normal + tangent) * length


func distort_point_to_egg(point: Vector2) -> Vector2:
    var angle = point.angle() - squish_normal.angle() + PI / 2
    var length = point.length()

    var normal
    var tangent

    var angle_to_normal = abs(squish_normal.angle_to(point))

    # elliptical portion
    if angle_to_normal > PI / 2:
        normal = squish_normal * sin(angle) * egg_elliptical_ratio
        tangent = squish_tangent * cos(angle) / squish_ratio
    # circular portion
    else:
        normal = squish_normal * sin(angle) / squish_ratio
        tangent = squish_tangent * cos(angle) / squish_ratio 
    return (normal + tangent) * length


func distort_point_to_stadium(point: Vector2) -> Vector2:
    var normalized_point = point.normalized()

    if normalized_point.x < -1 + squish_ratio:
        var circle_segment_height = get_segment_height(radius, abs(normalized_point.x))
        var stadium_segment_height = get_segment_height(radius * squish_ratio, abs(normalized_point.x))
        point.y *=  stadium_segment_height / circle_segment_height
        point.x -= stadium_params.length / 2 - (radius - stadium_params.radius)

    elif normalized_point.x > 1 - squish_ratio:
        var circle_segment_height = get_segment_height(radius, abs(normalized_point.x))
        var stadium_segment_height = get_segment_height(radius * squish_ratio, abs(normalized_point.x))
        point.y *=  stadium_segment_height / circle_segment_height
        point.x += stadium_params.length / 2 - (radius - stadium_params.radius)
        
    else:
        var circle_segment_height = get_segment_height(radius, abs(normalized_point.x))
        point.y *= 2 * stadium_params.radius / circle_segment_height
        point.x *= stadium_params.length_multiplier
    
    return point + stadium_params.offset

func get_segment_height(p_radius: float, p_apothem: float) -> float:
    var angle = acos(p_apothem / p_radius)
    return 2 * p_radius * sin(angle)
