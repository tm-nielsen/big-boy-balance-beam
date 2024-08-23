class_name FileUtilities


static func parse_point(point_string: String, scale:= 1.0) -> Vector2:
    var values = point_string.split(",")

    if values.size() != 2:
        return Vector2.INF
    
    var x = float(values[0])
    var y = float(values[1])
    return Vector2(x, y) * scale

static func parse_point_list_string(point_list: String, scale:= 1.0) -> PackedVector2Array:
    var value_strings = split_by_comma_and_whitespace(point_list)
    return parse_points(value_strings, scale)

static func parse_points(value_strings: PackedStringArray, scale:= 1.0) -> PackedVector2Array:
    var points = PackedVector2Array()
    
    var i:= 0
    while i < value_strings.size():
        var x = float(value_strings[i])
        var y = float(value_strings[i + 1])
        points.append(Vector2(x, y) * scale)
        i += 2

    return points


static func set_object_parameters_from_element(object, xml_element: Dictionary) -> void:
    set_paint_parameters_from_element(object, xml_element)
    if "id" in xml_element:
        object.id = xml_element.id

# TODO: add fill-opacity and stroke-opacity
static func set_paint_parameters_from_element(paintable, xml_element: Dictionary) -> void:
    if "fill" in xml_element:
        paintable.fill_colour = get_colour(xml_element.fill)
    if "stroke" in xml_element:
        paintable.stroke_colour = get_colour(xml_element.stroke)
    if "stroke-width" in xml_element:
        paintable.stroke_width = float(xml_element["stroke-width"])

    if "fill-opacity" in xml_element:
        paintable.fill_colour.a = float(xml_element["fill-opacity"])
    if "stroke-opacity" in xml_element:
        paintable.stroke_colour.a = float(xml_element["stroke-opacity"])

    if "style" in xml_element:
        var style_dict = parse_style_string(xml_element["style"])
        set_paint_parameters_from_element(paintable, style_dict)

static func parse_style_string(style_string: String) -> Dictionary:
    var style = {}
    var style_properties = style_string.split(';')

    for property in style_properties:
        var parts = property.split(':')
        if parts.size() == 2:
            style[parts[0].strip_edges()] = parts[1].strip_edges()
    return style


enum ColourFormat {HEX, RGB, HSV, KEYWORD}
static func get_colour_format(colour_string: String) -> int:
    if colour_string.begins_with('#'):
        return ColourFormat.HEX
    elif colour_string.begins_with("rgb"):
        return ColourFormat.RGB
    elif colour_string.begins_with("hsv"):
        return ColourFormat.HSV

    return ColourFormat.KEYWORD

# TODO: account for all colour formats [#rgb, #rrggbbaa, rgb( r , g , b ), rgb( r% , g% , b% ), colour keyword]
static func get_colour(colour_string: String) -> Color:
    match get_colour_format(colour_string):
        ColourFormat.HEX:
            return Color(colour_string)
            # return rgba_string_to_argb_colour(colour_string)
        ColourFormat.KEYWORD:
            return Color(colour_string)

    printerr("Error: unable to parse colour string: ", colour_string)
    return Color()

# converts rgba colour string (#rrggbbaa | #rgba) to in engine argb colour
static func rgba_string_to_argb_colour(colour_string: String) -> Color:
    colour_string = colour_string.right(1)
    var string_length = colour_string.length()

    var has_alpha = string_length == 4 or string_length == 8
    if has_alpha:
        var swap_index = 6 if colour_string.length() >= 6 else 3
        colour_string = colour_string.right(swap_index) + colour_string.left(swap_index)
    return Color(colour_string)


static func split_by_comma_and_whitespace(string: String) -> PackedStringArray:
    var text_segments := split_by_whitespace(string)
    var results = PackedStringArray()

    for text_segment in text_segments:
        if text_segment == ',':
            continue
        var comma_split_segments = text_segment.split(',', false)
        for segment in comma_split_segments:
            results.append(segment)
    return results

static func split_by_whitespace(string: String) -> PackedStringArray:
    var regex = RegEx.new()
    regex.compile("\\S+")

    var results = PackedStringArray()
    for regex_match in regex.search_all(string):
        results.append(regex_match.get_string())
    return results