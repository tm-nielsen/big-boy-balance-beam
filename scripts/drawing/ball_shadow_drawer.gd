extends Node2D

@export var shadow_colour: Color = Color(0, 0, 0, 0.2)
@export var shadow_height_ratio: float = 0.1

@export var base_scale_height: float = 80

@onready var balls = get_tree().get_nodes_in_group("physics_balls")
@onready var ground = get_node("../StageLimits").ground

# TODO: make shadows not stack
func _process(_delta):
    queue_redraw()

func _draw():
    for ball in balls:
        _draw_ball_shadow(ball.position, ball.get_shadow_radius())

func _draw_ball_shadow(ball_position: Vector2, shadow_radius: float):
    var distance_from_ground = ground - ball_position.y
    distance_from_ground = max(distance_from_ground, 0)

    var shadow_position = Vector2(ball_position.x, ground)

    var shadow_width = shadow_radius * base_scale_height / (base_scale_height + distance_from_ground)
    var shadow_height = shadow_width * shadow_height_ratio

    var shadow_points = ShapeGenerator.generate_ellipse(shadow_width, shadow_height, Vector2.UP, shadow_position, 8)
    draw_colored_polygon(shadow_points, shadow_colour)
