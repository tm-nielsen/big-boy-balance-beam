class_name ShapeGenerator

# Generate points of a circle
static func generate_circle(radius: float, center:= Vector2.ZERO, n_points:= 16) -> PackedVector2Array:
    var points = PackedVector2Array()

    for i in range(n_points):
        var angle = i * 2 * PI / n_points
        points.push_back(center + Vector2(cos(angle), sin(angle)) * radius)

    return points


# Generate points of a stadium; a 2D capsule with given radius and length
static func generate_stadium(radius: float, length: float,
        center:= Vector2.ZERO, n_arc_points: = 8) -> PackedVector2Array:
    var points = PackedVector2Array()

    var arc_center = center + Vector2.LEFT * length / 2
    var angle = 3 * PI / 2

    for _i in range(n_arc_points):
        angle -= PI / n_arc_points
        points.push_back((arc_center + Vector2(cos(angle), sin(angle)) * radius))

    arc_center.x += length

    for _i in range(n_arc_points):
        angle -= PI / n_arc_points
        points.push_back((arc_center + Vector2(cos(angle), sin(angle)) * radius))

    return points

# Generate points of an ellipse
static func generate_ellipse(tangent_radius: float, normal_radius: float, normal:= Vector2.UP,
        center: = Vector2.ZERO, n_points:= 16) -> PackedVector2Array:

    var points = PackedVector2Array()

    normal = normal.normalized()
    var tangent = normal.rotated(-PI / 2)

    for i in range(n_points):
        var angle = 2 * PI * i / n_points
        points.push_back(center + tangent * cos(angle) * tangent_radius + normal * sin(angle) * normal_radius)

    return points


# Generate points of a half circle-half ellipse, elliptical half aligned to the eliptical normal
static func generate_egg(radius: float, elliptical_radius: float,eliptical_normal: Vector2,
        center:= Vector2.ZERO, n_arc_points:= 8) -> PackedVector2Array:

    var points = PackedVector2Array()

    eliptical_normal = eliptical_normal.normalized()
    var tangent = eliptical_normal.rotated(-PI / 2)
    var angle = PI / 2

    for _i in range(n_arc_points):
        points.push_back(center + eliptical_normal * cos(angle) * elliptical_radius + tangent * sin(angle) * radius)
        angle -= PI / n_arc_points

    for _i in range(n_arc_points):
        points.push_back(center + eliptical_normal * cos(angle) * radius + tangent * sin(angle) * radius)
        angle -= PI / n_arc_points

    return points


# Generate points of an arc
static func generate_arc(radius: float, angle_from: float, angle_to: float,
        center:= Vector2.ZERO, n_arc_points:= 3) -> PackedVector2Array:
    
    var points = PackedVector2Array()

    for i in range(n_arc_points + 1):
        var angle = lerp(angle_from, angle_to, float(i) / n_arc_points)
        points.push_back(center + Vector2(cos(angle), sin(angle)) * radius)

    return points


# Generate points of an isosceles triangle with centre at base
static func generate_triangle(width: float, height: float,
        centre:= Vector2.ZERO) -> PackedVector2Array:

    var points = PackedVector2Array()
    points.push_back(centre + Vector2.RIGHT * width / 2)
    points.push_back(centre + Vector2.LEFT * width / 2)
    points.push_back(centre + Vector2.UP * height)

    return points