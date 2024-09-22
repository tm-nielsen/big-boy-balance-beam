@tool
class_name CharacterDrawer
extends SquishyBallDrawer

@export_file('*.svg') var file_path: String: set = _set_file_path
@export var mirrored: bool
var path_set_drawer: SquishyPathSetDrawer
var file_body_radius: float


func _ready():
    _create_path_set_drawer()
    _load_file()

func _create_path_set_drawer():
    path_set_drawer = SquishyPathSetDrawer.new()
    path_set_drawer.max_visual_ellipse_squish_ratio = max_visual_ellipse_squish_ratio
    path_set_drawer.mirrored = mirrored
    add_child(path_set_drawer)


func set_radius(p_radius: float):
    super(p_radius)
    if path_set_drawer != null:
        path_set_drawer.set_radius(p_radius)
        path_set_drawer.draw_scale = radius / file_body_radius

func update_parameters(p_rotation: float, p_squish_ratio: float, p_squish_normal: Vector2, p_squish_state: int):
    super(p_rotation, p_squish_ratio, p_squish_normal, p_squish_state)
    path_set_drawer.update_parameters(p_rotation, p_squish_ratio, p_squish_normal, p_squish_state)


func _set_file_path(path: String):
    file_path = path
    _load_file()

func _load_file():
    if !FileAccess.file_exists(file_path):
        return
    var parse_result := PathSetReader.read_file(file_path)
    var path_set: PathSet = parse_result.path_set
    if path_set != null:
        _apply_path_set(path_set)

func _apply_path_set(path_set: PathSet):
    fill_colour = path_set.fill_colour
    stroke_colour = path_set.stroke_colour
    stroke_width = path_set.stroke_width
    _apply_path_set_to_path_drawer(path_set)
    queue_redraw()

func _apply_path_set_to_path_drawer(path_set: PathSet):
    if !path_set_drawer || Engine.is_editor_hint(): return
    file_body_radius = path_set.body_radius
    path_set_drawer.paths = path_set.paths
    path_set_drawer.radius = radius
    path_set_drawer.draw_scale = radius / file_body_radius
