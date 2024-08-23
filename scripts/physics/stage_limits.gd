class_name StageLimits
extends Node2D

@export var left_wall: float = -160
@export var right_wall: float = 160
@export var ground: float = 80
@export var net_position: Vector2 = Vector2(0, 30)
@export var minimum_collision_speed: float = 1.0

func _ready():
    # $NetCollisionArea.position = net_position
    add_to_group("stage_limits")


# func _physics_process(_delta):
    # for area in $NetCollisionArea.get_overlapping_areas():
    #     var parent_body = area.get_parent()
    #     if parent_body is PhysicsBall:
    #         collide_with_point(parent_body, net_position)


func collide_with_point(ball: PhysicsBall, point: Vector2):
    var displacement = ball.position - point

    if displacement.length() < ball.radius:
        if ball.velocity.y > 0:
            var collision_normal = displacement.normalized()
            var collision_speed = ball.velocity.length() * ball.elasticity
            collision_speed += minimum_collision_speed

            ball.velocity = collision_normal * collision_speed
        else:
            ball.velocity.x *= -ball.elasticity
