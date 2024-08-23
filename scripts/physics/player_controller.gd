class_name PlayerController
extends ControllableSquishyPhysicsBall


func _apply_forces(delta):
    var strafe_direction = Input.get_action_strength("right")
    strafe_direction -= Input.get_action_strength("left")
    is_applying_strafe_force = strafe_direction != 0

    velocity.x += strafe_force * delta * strafe_direction

    should_charge_jump = Input.is_action_pressed("charge_jump")
    
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