class_name PlayerController
extends ControllableSquishyPhysicsBall

@export_range(1, 2) var player_index: int = 1


func _apply_forces(delta):
    var strafe_direction = 1 if is_numbered_action_pressed("right") else 0
    strafe_direction -= 1 if is_numbered_action_pressed("left") else 0
    is_applying_strafe_force = strafe_direction != 0

    velocity.x += strafe_force * delta * strafe_direction

    should_charge_jump = is_numbered_action_pressed("charge_jump")
    
    super(delta)

func _collide_with_walls():
    if position.x < local_limits.left:
        position.x = local_limits.left
        if !is_applying_strafe_force or velocity.x < -minimum_bounce_speed.x:
            velocity.x = abs(velocity.x) * elasticity
        elif velocity.x < 0:
            velocity.x = 0
        
    if position.x > local_limits.right:
        position.x = local_limits.right
        if !is_applying_strafe_force or velocity.x > minimum_bounce_speed.x:
            velocity.x = -abs(velocity.x) * elasticity
        elif velocity.x > 0:
            velocity.x = 0


func is_numbered_action_pressed(simple_name: String) -> bool:
  return Input.is_action_pressed(_get_input_name(simple_name))

func _get_input_name(simple_name: String) -> String:
  return ("p%d_" % player_index) + simple_name