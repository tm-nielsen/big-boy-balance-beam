class_name ShapeDrawer

static func draw_shape(drawer_node: CanvasItem, points: PackedVector2Array, fill_colour: Color,
        stroke_width:= -1.0, stroke_colour:= Color.BLACK) -> void:

    drawer_node.draw_colored_polygon(points, fill_colour)

    if stroke_width > 0:
        points.push_back(points[0])
        drawer_node.draw_polyline(points, stroke_colour, stroke_width)


static func draw_circle(drawer_node: CanvasItem, radius: float,
        fill_colour: Color, stroke_width: = 0.0, stroke_colour:= Color.BLACK,
        center:= Vector2.ZERO, n_points:= 16) -> void:

    var circle_points = ShapeGenerator.generate_circle(radius, center, n_points)
    draw_shape(drawer_node, circle_points, fill_colour, stroke_width, stroke_colour)


static func draw_stadium(drawer_node: CanvasItem, radius: float, length: float,
        fill_colour: Color, stroke_width:= 0.0, stroke_colour:= Color.BLACK,
        center:= Vector2.ZERO, n_arc_points:= 8) -> void:

    var stadium_points = ShapeGenerator.generate_stadium(radius, length, center, n_arc_points)
    draw_shape(drawer_node, stadium_points, fill_colour, stroke_width, stroke_colour)


static func draw_ellipse(drawer_node: CanvasItem,
        tangent_radius: float, normal_radius: float, normal: Vector2,
        fill_colour: Color, stroke_width:= 0.0, stroke_colour:= Color.BLACK,
        center:= Vector2.ZERO, n_points:= 16) -> void:

    var ellipse_points = ShapeGenerator.generate_ellipse(tangent_radius, normal_radius, normal, center, n_points)
    draw_shape(drawer_node, ellipse_points, fill_colour, stroke_width, stroke_colour)


static func draw_egg(drawer_node: CanvasItem,
    radius: float, elliptical_radius: float, elliptical_normal: Vector2,
    fill_colour: Color, stroke_width:= 0.0, stroke_colour:= Color.BLACK,
    center:= Vector2.ZERO, n_arc_points:= 8) -> void:

    var egg_points = ShapeGenerator.generate_egg(radius, elliptical_radius, elliptical_normal, center, n_arc_points)
    draw_shape(drawer_node, egg_points, fill_colour, stroke_width, stroke_colour)