class_name BeachBall
extends PhysicsBall

@export var minimum_bump_speed: float = 0.1
@export var horizontal_bump_ratio: float = 0.25
@export var jump_charge_bump_multiplier: float = 0.5
@export var minimum_bump_angle: float = PI / 16

@export var ball_drawer: BeachBallDrawer

var squish_ratio := 1.0
var elliptical_normal := Vector2.DOWN


func _process(_delta):
    squish_ratio = lerpf(squish_ratio, 1, _delta * 6)
    queue_redraw()


func collide_with(p_body: PhysicsObject) -> Collision:
    var previous_velocity = velocity
    var collision = super(p_body)

    if p_body is ControllableSquishyPhysicsBall:
        var horizontal_collision_speed = abs(velocity.x) + abs(p_body.velocity.x)

        apply_bump(collision.normal, horizontal_collision_speed, p_body.jump_charge)

    var acceleration = (velocity - previous_velocity).length()
    squish_ratio = 1 - 0.1 * ease((acceleration + collision.speed) / 10, -2.5)
    elliptical_normal = collision.normal

    return collision

func apply_bump(collision_normal: Vector2, horizontal_collision_speed: float, collider_jump_charge: float):
    var collision_angle = collision_normal.angle()
    
    if minimum_bump_angle - PI < collision_angle and collision_angle < -minimum_bump_angle:
        velocity.y -= minimum_bump_speed + horizontal_collision_speed * horizontal_bump_ratio
        velocity.y -= collider_jump_charge * jump_charge_bump_multiplier



func _draw():
    ball_drawer.draw_squished_beach_ball(self, radius, squish_ratio, elliptical_normal, visual_rotation)
