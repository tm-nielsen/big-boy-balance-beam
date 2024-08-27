class_name ControllableSquishyPhysicsBall
extends SquishyPhysicsBall

@export var strafe_force: float = 25
@export var jump_speed: float = 5
@export var jump_charge_period: float = 0.5
@export var charged_squish_ratio: float = 0.6

var should_charge_jump = false
var charging_jump = false
var jump_charge = 0.0
var is_applying_strafe_force


func _process_movement(delta):
    if on_beam and should_charge_jump:
        _charge_jump(delta)
    
    if charging_jump and !should_charge_jump:
        _jump()

    super(delta)

func reset():
    physics_enabled = true
    velocity = Vector2.ZERO
    should_charge_jump = false
    charging_jump = false
    jump_charge = 0
    is_applying_strafe_force = false

func _on_land(normal_velocity: Vector2):
    super(normal_velocity)
    if !charging_jump:
        if should_charge_jump:
            jump_charge = abs(velocity.y) / jump_speed
            _apply_jump_charge()
            squish_reset_delta = -jump_charge * (1 - charged_squish_ratio) * landing_squish_elasticity
            squish_ratio = lerpf(1, charged_squish_ratio, jump_charge)
            squish_state = SquishState.STADIUM
        else:
            var speed_saturation = abs(velocity.y) / jump_speed
            if speed_saturation > 0.25:
                add_jiggle(-speed_saturation * (1 - charged_squish_ratio) * landing_squish_elasticity, Vector2.UP)


func _set_squish_state():
    if squish_ratio == 1:
        squish_state = SquishState.CIRCLE

    elif squish_ratio < 1:
        if charging_jump:
            squish_state = SquishState.STADIUM
        else:
            squish_state = SquishState.ELLIPSE


func _charge_jump(delta):
    jump_charge += delta / jump_charge_period
    _apply_jump_charge()

func _apply_jump_charge():
    charging_jump = true

    velocity = velocity.project(BalanceBeam.tangent)

    if(jump_charge > 1):
        jump_charge = 1.0

    squish_reset_target = lerpf(1, charged_squish_ratio, jump_charge)
    queue_redraw()


func _jump():
    velocity.y = -jump_speed * jump_charge
    
    squish_normal = velocity.normalized()
    squish_reset_delta = jump_charge * (1 - max(squish_ratio, charged_squish_ratio)) * jump_squish_elasticity
    squish_ratio  = 1.0
    squish_reset_target = 1.0
    squish_state = SquishState.EGG

    charging_jump = false
    should_charge_jump = false
    jump_charge = 0.0