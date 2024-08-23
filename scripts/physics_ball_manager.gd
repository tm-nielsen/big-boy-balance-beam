class_name PhysicsBallManager
extends Node2D

signal reset_completed

@export var reset_lerp_scale: float = 7.5

var physics_balls: Array[PhysicsBall]
var ball_start_positions := []
var ball_count: int
var is_resetting := false

func _ready():
    physics_balls = []
    for child in get_children():
        if child is PhysicsBall:
            physics_balls.append(child)
    for ball in physics_balls:
        ball_start_positions.append(ball.position)
    ball_count = physics_balls.size()


func _process(delta):
    if is_resetting:
        _process_reset(delta)


func reset_balls():
    set_physics_enabled(false)
    is_resetting = true

# TODO: replace lerping with easing based on transition period
func _process_reset(delta):
    var is_finished := true
    for i in range(ball_count):
        var ball = physics_balls[i]
        var target_position = ball_start_positions[i]
        var scaled_lerp = reset_lerp_scale * delta

        ball.position = lerp(ball.position, target_position, scaled_lerp)
        ball.visual_rotation = lerp_angle(ball.visual_rotation, 0, scaled_lerp)
        if ball is SquishyPhysicsBall:
            ball.squish_ratio = lerp(ball.squish_ratio, 1.0, scaled_lerp)
            ball.update_drawer_parameters()

        if (ball.position - target_position).length_squared() > 1:
            is_finished = false

    if is_finished:
        _finalize_reset()

func _finalize_reset():
    for i in range(ball_count):
        var ball = physics_balls[i]
        ball.position = ball_start_positions[i]
    reset_completed.emit()

func set_physics_enabled(enable := true):
    for ball in physics_balls:
        ball.physics_enabled = enable
