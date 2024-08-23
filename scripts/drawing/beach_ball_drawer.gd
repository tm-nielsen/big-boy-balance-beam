class_name BeachBallDrawer
extends CanvasItem

@export var base_radius: float = 24
@export var inner_radius_ratio: float = 0.2
@export var inner_fill_colour: Color = Color(0.8, 0.8, 0.8)
@export var inner_stroke_colour: Color = Color(0.4, 0.4, 0.4)

@export var section_fill_colours: Array[Color] = [
    Color("#FF3029"),
    Color("#FF8615"),
    Color("#F5FA17"),
    Color("#6CF220"),
    Color("#2CBAFF"),
    Color("#9F4DFF"),
]
@export var section_stroke_colours: Array[Color] = [
    Color("#CB2721"),
    Color("#F07400"),
    Color("#E9ED18"),
    Color("#67E022"),
    Color("#2CA5FF"),
    Color("#9236FC"),
]
@export var stroke_width: float = 1.5
@export var points_per_section: int = 3


func draw_beach_ball(drawer_node: CanvasItem, radius: float,
        rotation: float = 0.0, position: Vector2 = Vector2.ZERO) -> void:
    _draw_beach_ball(drawer_node, radius, rotation, position)

func draw_squished_beach_ball(drawer_node: CanvasItem, radius: float,
        squish_ratio: float, squish_normal: Vector2,
        rotation: float = 0.0, position: Vector2 = Vector2.ZERO) -> void:
    _draw_beach_ball(drawer_node, radius, rotation, position, true, squish_ratio, squish_normal)


func _draw_beach_ball(drawer_node: CanvasItem, radius: float, rotation: float,
        position: Vector2, draw_egg: bool = false,
        squish_ratio: float = 1.0, squish_normal: Vector2 = Vector2.UP) -> void:

    if !section_fill_colours or !section_stroke_colours:
        printerr("Error: tried to draw beach ball without colours")
        return
    
    var stroke_scale: float = radius / base_radius
    var n_sections = section_fill_colours.size()
    var section_width = 2 * PI / n_sections

    for i in range(n_sections):
        var from_angle = i * section_width + rotation
        var to_angle = from_angle + section_width
        var arc_points
        if draw_egg:
            arc_points = _generate_egg_slice(from_angle, to_angle, radius, squish_ratio, squish_normal, position)
        else:
            arc_points = _generate_slice(from_angle, to_angle, radius, position)

        drawer_node.draw_colored_polygon(arc_points, section_fill_colours[i])
        drawer_node.draw_polyline(arc_points, section_stroke_colours[i], stroke_width * stroke_scale)

    _draw_inner_circle(drawer_node, radius, stroke_scale, position)

func _draw_inner_circle(drawer_node: CanvasItem, radius: float, stroke_scale: float, position: Vector2) -> void:
    ShapeDrawer.draw_circle(drawer_node, radius * inner_radius_ratio,
            inner_fill_colour, stroke_width * stroke_scale, inner_stroke_colour, position)


func _generate_slice(angle_from: float, angle_to: float, radius: float,
        center: Vector2 = Vector2.ZERO, n_arc_points: int = 3) -> PackedVector2Array:

    var points = PackedVector2Array([center])

    for i in range(n_arc_points + 1):
        var angle = lerp_angle(angle_from, angle_to, float(i) / n_arc_points)
        points.push_back(center + Vector2(cos(angle), sin(angle)) * radius)

    return points

func _generate_egg_slice(angle_from: float, angle_to: float, radius: float,
        squish_ratio: float, elliptical_normal: Vector2,
        center: Vector2 = Vector2.ZERO, n_arc_points: int = 3) -> PackedVector2Array:

    var points = PackedVector2Array([center])

    for i in range(n_arc_points + 1):
        var angle = lerp_angle(angle_from, angle_to, float(i) / n_arc_points)
        points.push_back(center + _get_egg_point(angle, elliptical_normal, radius, squish_ratio))

    return points

func _get_egg_point(angle: float, elliptical_normal: Vector2, radius: float, squish_ratio):
    angle -= elliptical_normal.angle()
    while angle <= 0:
        angle += 2 * PI
    while angle > 2 * PI:
        angle -= 2 * PI

    var circular_radius = radius / squish_ratio
    var elliptical_radius = radius * (2.0 * squish_ratio - 1.0 / squish_ratio)

    var normal = elliptical_normal
    var tangent = normal.rotated(-PI / 2)

    var tangent_vector = tangent * cos(angle) * circular_radius
    var normal_vector = normal * sin(angle)
    normal_vector *= (elliptical_radius if PI <= angle and angle <= 2 * PI else circular_radius)
    return tangent_vector + normal_vector
