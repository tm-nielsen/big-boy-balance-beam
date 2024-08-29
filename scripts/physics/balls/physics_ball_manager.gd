class_name PhysicsBallManager
extends Node2D

signal balls_collided(collision: Collision)
static var physics_balls: Array[PhysicsBall]

@export_subgroup('collisions')
@export var collision_elasticity: float = 0.35
@export var minimum_collision_speed: float = 0.5

var physics_enabled = true : set = _set_physics_enabled

func _ready():
    physics_balls = []
    for child in get_children():
        if child is PhysicsBall:
            physics_balls.append(child)

func _physics_process(_delta: float):
    if !physics_enabled:
        return
    
    var ball_1 = physics_balls[0]
    var ball_2 = physics_balls[1]
    if ball_1.position.distance_to(ball_2.position) < ball_1.radius + ball_2.radius:
        var collision = Collision.new(ball_1, ball_2, collision_elasticity, minimum_collision_speed)
        ball_1.add_collision(collision)
        collision.normal *= -1
        ball_2.add_collision(collision)
        balls_collided.emit(collision)


func reset_balls():
    physics_enabled = true
    for ball in physics_balls:
        ball.reset()

func _set_physics_enabled(value := true):
    physics_enabled = value
    for ball in physics_balls:
        ball.physics_enabled = value
