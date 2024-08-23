class_name OpponentController
extends ControllableSquishyPhysicsBall

@export var x_target_offset: float = 25
@export var strafe_force_scaling_distance: float = 40
@export var home_position_x: float = 80
@export var ball_y_jump_threshold: float = -60
@export var ball_y_charge_jump_threshold: float = -100

@onready var ball = get_node("../BeachBall")
var x_target = home_position_x

func _process(_delta):
    apply_strategy()
    
func apply_strategy():
    if ball.position.x < stage_limits.net_position.x:
        x_target = home_position_x
        should_charge_jump = false
        jump_charge *= 0.4
    else:
        should_charge_jump = true
        x_target = ball.position.x + x_target_offset
        if ball.position.y > position.y:
            x_target += ball.radius + radius
        if position.x > ball.position.x and position.x < x_target and jump_charge > 0.5 and ball.position.y > ball_y_jump_threshold:
            should_charge_jump = false

func _apply_forces(delta):

    var strafe_direction = clamp((x_target - position.x - velocity.x) / strafe_force_scaling_distance, -1, 1)
    is_applying_strafe_force = strafe_direction != 0

    velocity.x += strafe_force * delta * strafe_direction
    
    super(delta)
