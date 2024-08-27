class_name SquishyPhysicsBall
extends PhysicsBall

@export var max_squish_ratio: float = 0.4
@export var max_visual_ellipse_squish_ratio: float = 0.65
@export var jump_squish_elasticity: float = 0.5
@export var landing_squish_elasticity: float = 0.25
@export var squish_reset_elasticity: float = 5
@export var squish_reset_friction: float = 0.075
@export var ground_squish_reset_elasticity: float = 20
@export var maximum_collision_jiggle: float = 0.02

@onready var drawer = $Drawer

var squish_ratio = 1.0
var squish_reset_delta = 0.0
var squish_reset_target = 1.0
var squish_normal = Vector2.UP

enum SquishState {
    CIRCLE,
    ELLIPSE,
    STADIUM,
    EGG,
}
var squish_state = SquishState.CIRCLE


func _ready():
    super()
    drawer.set_radius(radius)

func _process_movement(delta):
    _oscillate_squish_ratio(delta)
    _set_squish_state()
    update_drawer_parameters() 
    super(delta)


func _on_land(normal_velocity: Vector2):
    super(normal_velocity)
    update_drawer_parameters()

func update_drawer_parameters():
    var drawer_rotation = visual_rotation - rotation
    drawer.update_parameters(drawer_rotation, squish_ratio, squish_normal, squish_state)


func _oscillate_squish_ratio(delta):
    var delta_scale = 60 * delta

    var squish_elasticity = ground_squish_reset_elasticity if on_beam else squish_reset_elasticity

    squish_reset_delta += (squish_reset_target - squish_ratio) * squish_elasticity * delta
    squish_reset_delta *= (1 - squish_reset_friction * delta_scale)
    squish_ratio += squish_reset_delta * delta_scale

    squish_ratio = clamp(squish_ratio, max_squish_ratio, 1 / max_squish_ratio)

    if abs(squish_reset_delta) < 0.005 and abs(squish_reset_target - squish_ratio) < 0.005:
        squish_ratio = squish_reset_target
        squish_reset_delta = 0.0
    queue_redraw()


func _set_squish_state():
    if squish_ratio == 1:
        squish_state = SquishState.CIRCLE

    else:
        squish_state = SquishState.ELLIPSE


# add an impulse to the squish oscillation
# negative magnitude will compress along the normal, positive will stretch
# directions will be combined based on magnitudes
func add_jiggle(magnitude: float, direction: Vector2,
        override_direction: bool = false,
        override_magnitude: bool = false):
    direction = direction.normalized()

    if override_direction:
        squish_normal = direction
    else:
        var squish_delta_vector = abs(squish_reset_delta) * squish_normal
        squish_delta_vector += abs(magnitude) * direction
        squish_normal = squish_delta_vector.normalized()
    
    if override_magnitude:
        squish_reset_delta = magnitude
    else:
        squish_reset_delta += magnitude

    squish_ratio += squish_reset_delta


func add_collision(collision: Collision):
    super(collision)

    if squish_state == SquishState.STADIUM:
        add_jiggle(-landing_squish_elasticity * collision.speed / 20, Vector2.UP)
    else:
        var jiggle_magnitude = maximum_collision_jiggle * ease(collision.speed / 10, 0.2)

        jiggle_magnitude = max(jiggle_magnitude, 0)
        add_jiggle(jiggle_magnitude, Vector2.UP if on_beam else collision.normal.rotated(PI/2))
        squish_state = SquishState.ELLIPSE


func compute_local_limits():
    left_limit = StageLimits.left
    right_limit = StageLimits.right
    left_limit += get_horizontal_limit(true)
    right_limit -= get_horizontal_limit(false)

func get_horizontal_limit(left: bool = false, limit_by_center_width: bool = false) -> float:
    match squish_state:
        SquishState.ELLIPSE:
            if limit_by_center_width:
                return drawer.get_elliptical_length(PI if left else 0.0)
            return drawer.elliptical_extents.x

        SquishState.STADIUM:
            return drawer.get_stadium_horizontal_extent()

        SquishState.EGG:
            return radius / squish_ratio

        _:
            return radius


func get_shadow_radius():
    return get_horizontal_limit()
