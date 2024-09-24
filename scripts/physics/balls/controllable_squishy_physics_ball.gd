class_name ControllableSquishyPhysicsBall
extends SquishyPhysicsBall

@export var strafe_force: float = 25
@export var charged_squish_ratio: float = 0.6

@export_subgroup('jump', 'jump')
@export var jump_speed: float = 5
@export var jump_charge_period: float = 0.5

@export_subgroup('drop slam', 'drop')
@export var drop_force: float = 10
@export var drop_impulse: float = 2
@export var drop_squish_ratio: float = 1.2
@export var drop_squish_elasticity: float = 0.5

var should_charge_jump: bool = false
var charging_jump: bool = false
var jump_charge: float = 0.0
var is_dropping: bool = false
var is_applying_strafe_force: bool


func start_tweened_reset(reset_tween: Tween, duration: float):
    super(reset_tween, duration)
    _reset_movement_flags()

func reset():
    super()
    _reset_movement_flags()

func _reset_movement_flags():
    should_charge_jump = false
    charging_jump = false
    jump_charge = 0
    is_dropping = false
    is_applying_strafe_force = false


func _process_movement(delta):
    if should_charge_jump:
        if on_beam:
            _charge_jump(delta)
        elif !charging_jump:
            _drop(delta)
    elif is_dropping:
        _end_drop()
    
    if charging_jump and !should_charge_jump:
        _jump()

    super(delta)

func _on_land(normal_velocity: Vector2):
    super(normal_velocity)
    is_dropping = false
    if !charging_jump:
        if should_charge_jump:
            jump_charge = abs(velocity.y) / jump_speed
            velocity = Vector2.ZERO
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

    var tangent_velocity = velocity.project(BalanceBeam.tangent)
    var beam_velocity = BalanceBeam.get_velocity_at_point(position)
    velocity = tangent_velocity + beam_velocity
    velocity.y += 0.05

    if(jump_charge > 1):
        jump_charge = 1.0

    squish_reset_target = lerpf(1, charged_squish_ratio, jump_charge)


func _drop(delta):
    velocity.y += drop_force * delta
    squish_normal = velocity.normalized()
    if !is_dropping:
        _start_drop()

func _start_drop():
    is_dropping = true
    if velocity.y < 0: velocity.y = 0
    velocity.y += drop_impulse

    var squish_offset = (drop_squish_ratio - squish_ratio)
    squish_reset_delta = squish_offset * drop_squish_elasticity
    squish_ratio = 1
    squish_reset_target = drop_squish_ratio
    squish_state = SquishState.EGG


func _end_drop():
    is_dropping = false
    squish_reset_target = 1


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