class_name SVGShapeParser

# TODO: add error handling for incomplete elements, best to show in game
# TODO: Scale rounded elements by size
static func parse_rect(rect_element: Dictionary, scale:= 1.0) -> ColouredPath:
    var path = ColouredPath.new()
    set_object_parameters(path, rect_element)

    var x = float(rect_element.x) * scale
    var y = float(rect_element.y) * scale
    var width = float(rect_element.width) * scale
    var height = float(rect_element.height) * scale

    path.append(Vector2(x, y))
    path.append(Vector2(x + width, y))
    path.append(Vector2(x + width, y + height))
    path.append(Vector2(x, y + height))
    return path


static func parse_circle(circle_element: Dictionary, scale:= 1.0) -> ColouredPath:
    var path = ColouredPath.new()
    set_object_parameters(path, circle_element)

    var x = float(circle_element.cx) * scale
    var y = float(circle_element.cy) * scale
    var radius = float(circle_element.r) * scale
    
    path.points = ShapeGenerator.generate_circle(radius, Vector2(x, y), 8)
    return path


static func parse_ellipse(ellipse_element: Dictionary, scale:= 1.0) -> ColouredPath:
    var path = ColouredPath.new()
    set_object_parameters(path, ellipse_element)

    var x = float(ellipse_element.cx) * scale
    var y = float(ellipse_element.cy) * scale
    var x_radius = float(ellipse_element.rx) * scale
    var y_radius = float(ellipse_element.ry) * scale

    path.points = ShapeGenerator.generate_ellipse(x_radius, y_radius, Vector2.UP, Vector2(x, y), 8)
    return path


static func parse_line(line_element: Dictionary, scale:= 1.0) -> ColouredPath:
    var path = ColouredPath.new()
    set_object_parameters(path, line_element)

    path.append(Vector2(line_element.x1, line_element.y1) * scale)
    path.append(Vector2(line_element.x2, line_element.y2) * scale)
    path.closed = false
    return path


static func parse_polyline(polyline_element: Dictionary, scale:= 1.0) -> ColouredPath:
    var path = ColouredPath.new()
    set_object_parameters(path, polyline_element)

    path.points = FileUtilities.parse_point_list_string(polyline_element.points, scale)

    path.closed = false
    return path


static func parse_polygon(polygon_element: Dictionary, scale:= 1.0) -> ColouredPath:
    var path = ColouredPath.new()
    set_object_parameters(path, polygon_element)

    path.points = FileUtilities.parse_point_list_string(polygon_element.points, scale)

    return path



static func set_object_parameters(object: ColouredPath, xml_element: Dictionary) -> void:
    FileUtilities.set_object_parameters_from_element(object, xml_element)