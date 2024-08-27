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

var capsule_collider: CapsuleShape2D = CapsuleShape2D.new()


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


func _process_collisions(delta):
    update_collider()
    super(delta)


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


func collide_with(p_body:PhysicsObject) -> Collision:
    var collision = super(p_body)

    if squish_state == SquishState.STADIUM:
        add_jiggle(-landing_squish_elasticity * collision.speed / 20, Vector2.UP)
    else:
        var jiggle_magnitude = maximum_collision_jiggle * ease(collision.speed / 10, 0.2)

        jiggle_magnitude = max(jiggle_magnitude, 0)
        add_jiggle(jiggle_magnitude, Vector2.UP if on_beam else collision.normal.rotated(PI/2))
        squish_state = SquishState.ELLIPSE

    return collision


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


func update_collider():
    match squish_state:
        SquishState.CIRCLE:
            set_collision_transform()
            collision_shape.shape = circle_collider

        SquishState.ELLIPSE:
            set_collision_transform(squish_normal.angle(), Vector2(squish_ratio, 1 / squish_ratio))
            collision_shape.shape = circle_collider

        SquishState.STADIUM:
            var stadium_dimensions = drawer.stadium_dimensions
            set_collision_transform(PI / 2, Vector2.ONE, stadium_dimensions.position_offset)
            capsule_collider.radius = stadium_dimensions.radius + collider_cushion
            capsule_collider.height = clampf(stadium_dimensions.length, 0, INF)
            collision_shape.shape = capsule_collider

        SquishState.EGG:
            set_collision_transform(0, Vector2.ONE / squish_ratio)
            collision_shape.shape = circle_collider

func set_collision_transform(shape_rotation: float = 0,
        shape_scale: Vector2 = Vector2.ONE, shape_position: Vector2 = Vector2.ZERO):
    collision_shape.position = shape_position
    collision_shape.rotation = shape_rotation
    collision_shape.scale = shape_scale


func get_shadow_radius():
    return get_horizontal_limit()
