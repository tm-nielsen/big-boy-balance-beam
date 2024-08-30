@tool
class_name CharacterDrawer
extends SquishyBallDrawer

# enum CharacterType {NONE = 0, PLAYER, OPPONENT, PLAYER_2, OPPONENT_2}

# @export var character_type := CharacterType.NONE
@export_file('*.svg') var file_path
@export var path_set_drawer: SquishyPathSetDrawer


func _ready():
    var parse_result := PathSetReader.read_file(file_path)
    var path_set: PathSet = parse_result.path_set
    if path_set != null:
        fill_colour = path_set.fill_colour
        stroke_colour = path_set.stroke_colour
        stroke_width = path_set.stroke_width
        queue_redraw()
        path_set_drawer.paths = path_set.paths
        path_set_drawer.radius = radius
        path_set_drawer.draw_scale = radius / path_set.body_radius


func set_radius(p_radius: float):
    super(p_radius)
    if path_set_drawer != null:
        path_set_drawer.set_radius(p_radius)

func update_parameters(p_rotation: float, p_squish_ratio: float, p_squish_normal: Vector2, p_squish_state: int):
    super(p_rotation, p_squish_ratio, p_squish_normal, p_squish_state)
    path_set_drawer.update_parameters(p_rotation, p_squish_ratio, p_squish_normal, p_squish_state)
