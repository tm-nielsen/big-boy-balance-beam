class_name PhysicsBallManager
extends Node2D

signal reset_completed

@export var reset_lerp_scale: float = 7.5
@export var balance_beam: BalanceBeam

@export_subgroup('collisions')
@export var collision_elasticity: float = 0.35
@export var minimum_collision_speed: float = 0.5

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

    if Input.is_action_just_pressed('reset') && OS.is_debug_build():
        reset_balls()

func _physics_process(_delta: float):
    if is_resetting:
        return
    
    var ball_1 = physics_balls[0]
    var ball_2 = physics_balls[1]
    if ball_1.position.distance_to(ball_2.position) < ball_1.radius + ball_2.radius:
        var collision = Collision.new(ball_1, ball_2, collision_elasticity, minimum_collision_speed)
        ball_1.add_collision(collision)
        collision.normal *= -1
        ball_2.add_collision(collision)


func reset_balls():
    set_physics_enabled(false)
    is_resetting = true

# TODO: replace lerping with easing based on transition period
func _process_reset(delta):
    var is_finished := true
    var scaled_lerp = reset_lerp_scale * delta

    balance_beam.rotation = lerpf(balance_beam.rotation, 0, scaled_lerp)

    for i in range(ball_count):
        var ball = physics_balls[i]
        var target_position = ball_start_positions[i]

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
    
    is_resetting = false
    balance_beam.reset()
    for ball in physics_balls:
        ball.reset()

func set_physics_enabled(enable := true):
    for ball in physics_balls:
        ball.physics_enabled = enable
        balance_beam.physics_enabled = false
