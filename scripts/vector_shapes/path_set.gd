class_name PathSet

const DEFAULT_BODY_RADIUS = 16.0

var fill_colour: Color = Color.BEIGE
var stroke_colour: Color = Color.MOCCASIN
var stroke_width: float = 2.0
var body_radius: float = DEFAULT_BODY_RADIUS

var paths: Array[ColouredPath]

func _init(p_fill_colour: Color = Color.WHITE,
        p_stroke_colour: Color = Color.BLACK,
        p_stroke_width: float = 1.0,
        p_paths: Array[ColouredPath] = []):
    paths = p_paths
    fill_colour = p_fill_colour
    stroke_colour = p_stroke_colour
    stroke_width = p_stroke_width

func _to_string() -> String:
    var string = "Path Set: fill=#%s, stroke=#%s, stroke-width=%.2f, paths="
    string = string % [fill_colour.to_html(), stroke_colour.to_html(), stroke_width]

    return string + str(paths)

func append(path: ColouredPath) -> void:
    paths.append(path)

func scale(s: float) -> void:
    for path in paths:
        var scaled_points = PackedVector2Array()
        for point in path.points:
            scaled_points.append(point * s)
        path.points = scaled_points

func translate(offset: Vector2) -> void:
    for path in paths:
        var translated_points = PackedVector2Array()
        for point in path.points:
            translated_points.append(point + offset)
        path.points = translated_points
