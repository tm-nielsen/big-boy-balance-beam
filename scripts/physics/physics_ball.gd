class_name PhysicsBall
extends PhysicsObject

const GROUP_NAME = "physics balls"

@export var gravity: float = 9.81
@export var x_friction: float = 0.05
@export var elasticity: float = 0.65
@export var radius: float = 20
@export var collider_cushion: float = 0.75
@export var minimum_bounce_speed: Vector2 = Vector2(0, 0.5)

var visual_rotation: float = 0.0
var on_beam: bool = false

var left_limit: float
var right_limit: float

var circle_collider: CircleShape2D = CircleShape2D.new()

func _ready():
    super()
    add_to_group(GROUP_NAME)
    compute_local_limits()

    circle_collider.radius = radius + collider_cushion
    collision_shape.shape = circle_collider

func _apply_forces(delta):
    velocity.y += gravity * delta
    velocity.x *= (1 - x_friction * 60 * delta)

func _process_movement(delta):
    move_ball(delta)

func move_ball(delta):
    var delta_scale = 60 * delta
    position += velocity * delta_scale
    
    visual_rotation += velocity.x * delta_scale / radius
    if visual_rotation > TAU:
        visual_rotation -= TAU
    elif visual_rotation < 0:
        visual_rotation += TAU

    on_beam = false


func land(beam_point: Vector2, normal_velocity: Vector2):
    position = beam_point + radius * BalanceBeam.normal

    velocity -= normal_velocity
    # if normal_velocity.length() > minimum_bounce_speed.y:
    #     velocity += normal_velocity * elasticity


func _process_collisions(_delta):
    for area in collision_area.get_overlapping_areas():
        var parent_body = area.get_parent()
        if parent_body is PhysicsObject:
            var _collision = collide_with(parent_body)

    compute_local_limits()
    collide_with_local_limits()


func collide_with(p_body: PhysicsObject) -> Collision:
    var collision = super(p_body)
    velocity = collision.normal * collision.speed

    return collision


func compute_local_limits():
    left_limit = StageLimits.left + radius
    right_limit = StageLimits.right - radius


func collide_with_local_limits():
    _collide_with_walls()

func _collide_with_walls():
    if position.x < left_limit:
        position.x = left_limit
        velocity.x = abs(velocity.x) * elasticity
        
    if position.x > right_limit:
        position.x = right_limit
        velocity.x = -abs(velocity.x) * elasticity


func get_shadow_radius() -> float:
    return radius
