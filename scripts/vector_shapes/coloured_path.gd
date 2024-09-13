class_name ColouredPath

var id: String

var fill_colour: Color = Color.WHITE
var stroke_colour: Color = Color.BLACK
var stroke_width: float = 1.0

var points: PackedVector2Array
var closed: bool = true

func _init(p_id: String = "",
        p_fill_colour: Color = Color.WHITE,
        p_stroke_colour: Color = Color.BLACK,
        p_stroke_width: float = 1.0, p_closed: bool = true,
        p_points: PackedVector2Array = PackedVector2Array()):
    id = p_id
    fill_colour = p_fill_colour
    stroke_colour = p_stroke_colour
    stroke_width = p_stroke_width
    points = p_points
    closed = p_closed

func _to_string() -> String:
    var string = "Coloured Path: id=%s fill=#%s, stroke=#%s, stroke-width=#%.2f, "
    string = string % [id, fill_colour.to_html(), stroke_colour.to_html(), stroke_width]

    string += "closed=" + str(closed)
    string += ", points=" + str(points)
    return string

func close_overlapping_end() -> bool:
    var point_count = points.size()
    var had_overlapping_end = false

    var last_point_index = point_count - 1
    while last_point_index >= 1 and points[0] == points[last_point_index]:
        points.remove_at(last_point_index)
        last_point_index -= 1
        had_overlapping_end = true

    closed = closed or had_overlapping_end
    return had_overlapping_end


func is_empty() -> bool:
    return points.size() == 0

func append(point: Vector2) -> void:
    points.append(point)

func set_vertex(index: int, new_point: Vector2) -> void:
    if index < points.size():
        points[index] = new_point
    elif index == points.size():
        append(new_point)
    else:
        printerr("Error: tried to set point %d on a path with %d points" % [index, points.size()])

func displace_vertex(index: int, displacement: Vector2) -> void:
    if index < 0 or index >= points.size():
        printerr("Error: tried to displace point %d on a path with %d points" % [index, points.size()])
    else:
        points[index] += displacement

func remove(index: int) -> void:
    if index < points.size():
        points.remove_at(index)
    else:
        printerr("Error: tried to remove point %d on a path with %d points" % [index, points.size()])

func _insert(index: int, point: Vector2) -> void:
    if index <= points.size():
        var _res = points.insert(index, point)
    else:
        printerr("Error: tried to insert point %d on a path with %d points" % [index, points.size()])


func insert(point: Vector2) -> int:
    var insert_index = get_insert_index(point)
    _insert(insert_index, point)
    return insert_index

func get_insert_index(point: Vector2) -> int:
    var vertex_count = points.size()
    if vertex_count <= 2:
        return vertex_count

    var insert_index: int = 0
    var distance: float = 1000000

    for i in range(0, vertex_count):
        var d = get_line_distance(i, (i+1) % vertex_count, point)
        
        # print("[%d, %d]: %.2f",  [i, i-1, d])
        if d < distance:
            distance = d
            insert_index = i + 1
        elif d == distance:
            var conflicting_index = i
            if insert_index == 1 and i == vertex_count - 1:
                conflicting_index = 0

            # print("decision triangle on point %d against result %d where i is %d" % [conflicting_index, insert_index, i])
            insert_index = settle_point_distance_conflict(conflicting_index, point)
            
    return insert_index

# TODO: if distance from point is equal for two segments, check distance to other point
# or use triangle from competing point as per Tung DMs
func get_line_distance(vertex_index_a: int, vertex_index_b: int, point: Vector2) -> float:
    var p_a = points[vertex_index_a]
    var p_b = points[vertex_index_b]

    var ap = point - p_a
    var bp = point - p_b

    var dot_ab = (p_b - p_a).dot(ap)
    var dot_ba = (p_a - p_b).dot(bp)

    var distance = 1000000
    # contained by line segment
    if dot_ab > 0 and dot_ba > 0:
        var normal = (p_b - p_a).rotated(PI / 2).normalized()
        distance = abs(ap.dot(normal))

    # closer to point b
    elif dot_ab <= 0:
        distance = ap.length()
    # closer to point a
    else:
        distance = bp.length()
    
    # print(dot_ab > 0 and dot_ba > 0, "[%d, %d]: %.2f" %  [vertex_index_a, vertex_index_b, distance])
    return distance


func settle_point_distance_conflict(conflicting_index: int, point: Vector2) -> int:
    var p_a = points[conflicting_index]
    var p_b = points[(conflicting_index - 1) % points.size()]
    var p_c = points[(conflicting_index + 1) % points.size()]

    var bp = point - p_b
    var ba_normal = (p_a - p_b).rotated(-PI / 2).normalized()
    var bp_dot_ba_normal = bp.dot(ba_normal)
    if bp_dot_ba_normal <= 0:
        return conflicting_index + 1 # point c

    var cp = point - p_c
    var ca_normal = (p_a - p_c).rotated(PI / 2).normalized()
    var cp_dot_ca_normal = cp.dot(ca_normal)
    if cp_dot_ca_normal <= 0:
        return conflicting_index # point b

    if bp_dot_ba_normal < cp_dot_ca_normal:
        return conflicting_index + 1
    else:
        return conflicting_index


func get_potential_subdivision_data(point: Vector2, min_vertex_distance: float) -> Dictionary:
    var vertex_count = points.size()
    if vertex_count <= 2:
        return {index = vertex_count, distance = 0, subdivision_point = point} 

    var insert_index: int = 0
    var distance: float = 1000000

    for i in range(0, vertex_count):
        var d = get_subdivision_line_distance(i, (i+1) % vertex_count, point, min_vertex_distance)
        
        if d < distance:
            distance = d
            insert_index = i + 1

    var subdivision_point = get_subdivisision_point(insert_index, point)
    return {index = insert_index, distance = distance, subdivision_point = subdivision_point}

func get_subdivision_line_distance(vertex_index_a: int, vertex_index_b: int,
        point: Vector2, min_vertex_distance: float) -> float:
    var p_a = points[vertex_index_a]
    var p_b = points[vertex_index_b]

    var ap = point - p_a
    var bp = point - p_b

    if ap.length() < min_vertex_distance or bp.length() < min_vertex_distance:
        return 1000000.0

    var dot_ab = (p_b - p_a).dot(ap)
    var dot_ba = (p_a - p_b).dot(bp)
    # contained by line segment
    if dot_ab > 0 and dot_ba > 0:
        var normal = (p_b - p_a).rotated(PI / 2).normalized()
        return abs(ap.dot(normal))
    else:
        return 1000000.0

func get_subdivisision_point(insert_index: int, point: Vector2) -> Vector2:
    var point_a = points[(insert_index - 1) % points.size()]
    var point_b = points[(insert_index) % points.size()]

    var ab_normal = (point_b - point_a).normalized()
    var line_ap = point - point_a

    return point_a + ab_normal * line_ap.dot(ab_normal)

    


func draw_path(draw_target: CanvasItem) -> void:
    _draw_path(draw_target, points)

func _draw_path(p_draw_target: CanvasItem, p_points: PackedVector2Array, p_scale := 1.0) -> void:
    if p_scale != 1.0:
        var scaled_points = PackedVector2Array()
        for i in p_points.size():
            scaled_points.append(p_points[i] * p_scale)
        p_points = scaled_points

    if p_points.size() > 2 && Geometry2D.triangulate_polygon(p_points):
        p_draw_target.draw_colored_polygon(p_points, fill_colour)

    if p_points.size() > 1:
        if closed:
            p_points.append(p_points[0])

        p_draw_target.draw_polyline(p_points, stroke_colour, stroke_width * p_scale)
