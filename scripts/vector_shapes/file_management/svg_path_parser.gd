class_name SVGPathParser

# TODO: refactor to return multiple coloured paths
# TODO: split path into two or more if there are Z(s) in the middle
static func parse_path(path_element: Dictionary, parse_notes) -> ColouredPath:
    var path = ColouredPath.new()
    FileUtilities.set_object_parameters_from_element(path, path_element)
    
    if "d" in path_element:
        var draw_path = path_element.d
        path.points = parse_draw_points(draw_path, parse_notes)
        if !draw_path.ends_with("Z"):
            path.closed = false
        if path.close_overlapping_end():
            parse_notes.append_info_note("closed overlapping path")

    return path

static func parse_draw_points(draw_path: String, parse_notes) -> PackedVector2Array:
    var points: = PackedVector2Array()

    var command_segments = split_draw_path(draw_path)

    var initial_point := Vector2.INF
    var current_point := Vector2.ZERO
    var previous_command := ""
    var previous_control_point:= Vector2.INF

    for command_data in command_segments:
        var command = command_data.command
        var params = command_data.params
        var is_relative = command.to_lower() == command

        var command_points: PackedVector2Array

        match command.to_upper():
            'M':
                command_points = parse_line(params, current_point, is_relative)
                initial_point = command_points[0]
                previous_control_point = Vector2.INF
            'L':
                command_points = parse_line(params, current_point, is_relative)
                previous_control_point = Vector2.INF
            'H':
                command_points = parse_horizontal_line(params, current_point, is_relative)
                previous_control_point = Vector2.INF
            'V':
                command_points = parse_vertical_line(params, current_point, is_relative)
                previous_control_point = Vector2.INF
            'C':
                var parsed_data = parse_cubic_bezier_curve(params, current_point, is_relative)
                previous_control_point = parsed_data.last_control_point
                command_points = parsed_data.curve_points
            'S':
                var parsed_data = {}
                if (previous_command.to_upper() == 'C' or previous_command.to_upper() == 'S') and previous_control_point != Vector2.INF:
                    parsed_data = parse_smooth_cubic_bezier_curve(params, current_point, previous_control_point, is_relative)
                    previous_control_point = parsed_data.last_control_point
                else:
                    parsed_data = parse_smooth_cubic_bezier_curve(params, current_point, current_point, is_relative)
                    previous_control_point = Vector2.INF
                command_points = parsed_data.curve_points
            'Q':
                var parsed_data = parse_quadratic_bezier_curve(params, current_point, is_relative)
                previous_control_point = parsed_data.last_control_point
                command_points = parsed_data.curve_points
            'T':
                var parsed_data = {}
                if (previous_command.to_upper() == 'C' or previous_command.to_upper() == 'S') and previous_control_point != Vector2.INF:
                    parsed_data = parse_smooth_quadratic_bezier_curve(params, current_point, previous_control_point, is_relative)
                    previous_control_point = parsed_data.last_control_point
                else:
                    parsed_data = parse_smooth_quadratic_bezier_curve(params, current_point, current_point, is_relative)
                    previous_control_point = Vector2.INF
                command_points = parsed_data.curve_points
            'A':
                parse_notes.append_warning_note("skipped unsupported arc segment")
                # printerr("arc encountered, skipping to end point")
                var parsed_data = parse_arc(params, current_point, is_relative)
                previous_control_point = parsed_data.last_control_point
                command_points = parsed_data.arc_points
                previous_control_point = Vector2.INF
            'Z':
                #close or split path
                # command_points = PackedVector2Array()
                # command_points.append(initial_point)
                current_point = initial_point
                previous_control_point = Vector2.INF
        
        for command_point in command_points:
            points.append(command_point)

        if command_points.size() > 0:
            current_point = command_points[command_points.size() - 1]

        previous_command = command

    return points
    


static func parse_line(command_params: PackedStringArray, current_point: Vector2, relative: bool) -> PackedVector2Array:
    var points = FileUtilities.parse_points(command_params)
    if relative:
        for i in range(points.size()):
            points[i] += current_point
            current_point = points[i]

    return points

static func parse_horizontal_line(command_params: PackedStringArray, current_point: Vector2, relative: bool) -> PackedVector2Array:
    var points = PackedVector2Array()
    var current_x = current_point.x
    for param in command_params:
        var x = float(param)
        if relative:
            x += current_x
            current_x = x
        points.append(Vector2(x, current_point.y))
    return points
    
static func parse_vertical_line(command_params: PackedStringArray, current_point: Vector2, relative: bool) -> PackedVector2Array:
    var points = PackedVector2Array()
    var current_y = current_point.y
    for param in command_params:
        var y = float(param)
        if relative:
            y += current_y
            current_y = y
        points.append(Vector2(current_point.x, y))
    return points



# TODO: parse polybezier curves
# C: parse cubic bezier curve
static func parse_cubic_bezier_curve(params: PackedStringArray, current_point: Vector2,
        relative: bool, n_points:= 3) -> Dictionary:
    var control_point_a = Vector2(float(params[0]), float(params[1]))
    var control_point_b = Vector2(float(params[2]), float(params[3]))
    var end_point = Vector2(float(params[4]), float(params[5]))

    if relative:
        control_point_a += current_point
        control_point_b += current_point
        end_point += current_point

    var points = get_cubic_bezier_points(current_point, end_point, control_point_a, control_point_b, n_points)

    # chain into polyline
    if params.size() > 6:
        var next_params = slice_string_array(params, 6)
        
        var chain_points = parse_cubic_bezier_curve(next_params, end_point, relative)
        for point in chain_points.curve_points:
            points.append(point)
        
        control_point_b = chain_points.last_control_point

    return {curve_points = points, last_control_point = control_point_b}

# S: parse smooth curve
static func parse_smooth_cubic_bezier_curve(params: PackedStringArray, current_point: Vector2,
        previous_control_point: Vector2, relative: bool, n_points:= 3) -> Dictionary:
    var control_point_a = current_point + 2 * (previous_control_point - current_point)

    var control_point_b = Vector2(float(params[0]), float(params[1]))
    var end_point = Vector2(float(params[2]), float(params[3]))

    if relative:
        control_point_b += current_point
        end_point += current_point

    var points = get_cubic_bezier_points(current_point, end_point, control_point_a, control_point_b, n_points)

    # chain into polyline
    if params.size() > 4:
        var next_params = slice_string_array(params, 4)

        var chain_points = parse_smooth_cubic_bezier_curve(next_params, end_point, control_point_b, relative)
        for point in chain_points.curve_points:
            points.append(point)

        control_point_b = chain_points.last_control_point

    return {curve_points = points, last_control_point = control_point_b}


static func get_cubic_bezier_points(current_point: Vector2, end_point: Vector2,
        control_point_1: Vector2, control_point_2: Vector2, n_points:= 3) -> PackedVector2Array:
    var points = PackedVector2Array()

    var lerp_value_step = 1.0 / (n_points)
    var lerp_value = lerp_value_step
    while lerp_value < 1.0:
        points.append(get_cubic_bezier_point(current_point, control_point_1, control_point_2, end_point, lerp_value))
        lerp_value += lerp_value_step

    points.append(end_point)
    return points

static func get_cubic_bezier_point(p_0: Vector2, p_1: Vector2, p_2: Vector2, p_3: Vector2, t: float) -> Vector2:
    var l_01 = lerp(p_0, p_1, t)
    var l_12 = lerp(p_1, p_2, t)
    var l_23 = lerp(p_2, p_3, t)
    var l_02 = lerp(l_01, l_12, t)
    var l_13 = lerp(l_12, l_23, t)
    return lerp(l_02, l_13, t)



# Q: parse quadratic bezier curve
static func parse_quadratic_bezier_curve(params: PackedStringArray, current_point: Vector2,
        relative: bool, n_points:= 3) -> Dictionary:
    var control_point = Vector2(float(params[0]), float(params[1]))
    var end_point = Vector2(float(params[2]), float(params[3]))

    if relative:
        control_point += current_point
        end_point += current_point

    var points = get_quadratic_bezier_points(current_point, end_point, control_point, n_points)

    # chain into polyline
    if params.size() > 4:
        var next_params = slice_string_array(params, 4)

        var chain_points = parse_quadratic_bezier_curve(next_params, end_point, relative, n_points)
        for point in chain_points.curve_points:
            points.append(point)
        
        control_point = chain_points.last_control_point

    return {curve_points = points, last_control_point = control_point}

# T: parse smooth quadratic bezier curve
static func parse_smooth_quadratic_bezier_curve(params: PackedStringArray, current_point: Vector2,
        previous_control_point, relative: bool,  n_points:= 3) -> Dictionary:
    var control_point = current_point + 2 * (previous_control_point - current_point)
    var end_point = Vector2(float(params[0]), float(params[1]))

    if relative:
        end_point += current_point

    var points = get_quadratic_bezier_points(current_point, end_point, control_point, n_points)

    # chain into polyline
    if params.size() > 2:
        var next_params = slice_string_array(params, 2)

        var chain_points = parse_smooth_quadratic_bezier_curve(next_params, end_point, control_point, relative, n_points)
        for point in chain_points.curve_points:
            points.append(point)

        control_point = chain_points.last_control_point

    return {curve_points = points, last_control_point = control_point}


static func get_quadratic_bezier_points(current_point: Vector2, end_point: Vector2,
    control_point: Vector2, n_points:= 3) -> PackedVector2Array:
    var points = PackedVector2Array()

    var lerp_value_step = 1.0 / (n_points)
    var lerp_value = lerp_value_step
    while lerp_value < 1:
        points.append(get_quadratic_bezier_point(current_point, control_point, end_point, lerp_value))
        lerp_value += lerp_value_step

    return points

static func get_quadratic_bezier_point(p_0: Vector2, p_1: Vector2, p_2: Vector2, t: float) -> Vector2:
    var l_01 = lerp(p_0, p_1, t)
    var l_12 = lerp(p_1, p_2, t)
    return lerp(l_01, l_12, t)


# A: parse arc
static func parse_arc(command_params: PackedStringArray, current_point: Vector2,
        relative: bool, _n_points:= 3) -> Dictionary:
    var points = PackedVector2Array()
    var end_point = Vector2(float(command_params[5]), float(command_params[6]))
    if relative:
        end_point += current_point
    points.append(end_point)
    return {arc_points = points, last_control_point = Vector2.INF}




static func split_draw_path(draw_path: String) -> Array:
    var delimeters: = ['M', 'L', 'H', 'V', 'Z', 'C', 'S', 'Q', 'T', 'A']
    var parts := []
    
    var command:= ""
    var start := 0
    var i := 0
    
    while i < draw_path.length():
        if draw_path[i].to_upper() in delimeters:
            if command != "":
                var command_data = {command = command}
                command_data.params = FileUtilities.split_by_comma_and_whitespace(draw_path.substr(start, i - start))
                parts.append(command_data)
            command = draw_path[i]

            if i == draw_path.length() - 1:
                parts.append({command = command, params = ""})
            start = i + 1
        i += 1

    if start < i:
        if command != "":
            var command_data = {command = command}
            command_data.params = FileUtilities.split_by_comma_and_whitespace(draw_path.substr(start, i - start))
            parts.append(command_data)
    
    return parts


static func slice_string_array(array: PackedStringArray, start_index: int) -> PackedStringArray:
    var sliced_array = PackedStringArray()
    var i = start_index
    while i < array.size():
        sliced_array.append(array[i])
        i += 1
    return sliced_array
