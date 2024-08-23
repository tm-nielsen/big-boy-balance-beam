class_name PhysicsBall
extends PhysicsObject

@export var gravity: float = 9.81
@export var x_friction: float = 0.05
@export var elasticity: float = 0.65
@export var radius: float = 20
@export var collider_cushion = 0.75
@export var minimum_bounce_speed: Vector2 = Vector2(0, 0.5)

var visual_rotation = 0.0
var on_ground = false

var stage_limits
var local_limits = {
    left = -160.0,
    right = 160.0,
    ground = 80.0,
}

var circle_collider: CircleShape2D = CircleShape2D.new()

func _ready():
    super()
    add_to_group("physics_balls")
    stage_limits = get_tree().get_first_node_in_group("stage_limits")
    compute_local_limits()

    circle_collider.radius = radius + collider_cushion
    collision_shape.shape = circle_collider

func _apply_forces(delta):
    velocity.y += gravity * delta
    velocity.x *= (1 - x_friction * 60 * delta)

func _process_movement(delta):
    move_ball(delta)

func move_ball(delta):
    z_index = 1 if position.x < stage_limits.net_position.x else -1

    var delta_scale = 60 * delta
    position += velocity * delta_scale
    
    visual_rotation += velocity.x * delta_scale / radius
    if visual_rotation > TAU:
        visual_rotation -= TAU
    elif visual_rotation < 0:
        visual_rotation += TAU

func _on_land():
    pass


func _process_collisions(_delta):
    for area in collision_area.get_overlapping_areas():
        var parent_body = area.get_parent()
        if parent_body is PhysicsObject:
            var _collision = collide_with(parent_body)

    # compute_local_limits()
    collide_with_local_limits()


func collide_with(p_body: PhysicsObject) -> Collision:
    var collision = super(p_body)
    velocity = collision.normal * collision.speed

    return collision


func compute_local_limits():
    # var net_position = stage_limits.net_position

    # if(position.y > net_position.y):
    #     if(position.x < net_position.x):
    #         local_limits.left = stage_limits.left_wall
    #         local_limits.right = net_position.x
    #     else:
    #         local_limits.left = net_position.x
    #         local_limits.right = stage_limits.right_wall
    # else:
    #     local_limits.left = stage_limits.left_wall
    #     local_limits.right = stage_limits.right_wall

    local_limits.left = stage_limits.left_wall
    local_limits.right = stage_limits.right_wall
    
    local_limits.left += radius
    local_limits.right -= radius
    local_limits.ground = stage_limits.ground - radius


func collide_with_local_limits():
    _collide_with_ground()
    _collide_with_walls()

func _collide_with_ground():
    on_ground = false
    if position.y > local_limits.ground:
        _on_land()
        position.y = local_limits.ground
        velocity.y *= -elasticity

        on_ground = true
        if abs(velocity.y) < minimum_bounce_speed.y:
            velocity.y = 0

func _collide_with_walls():
    if position.x < local_limits.left:
        position.x = local_limits.left
        velocity.x = abs(velocity.x) * elasticity
        
    if position.x > local_limits.right:
        position.x = local_limits.right
        velocity.x = -abs(velocity.x) * elasticity


func get_shadow_radius() -> float:
    return radius
