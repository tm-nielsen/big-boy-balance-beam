class_name PhysicsObject
extends Node2D

@export var minimum_collision_speed: float = 0.3
@export var collision_elasticity: float = 0.35

var collision_area: Area2D
var collision_shape: CollisionShape2D

var velocity: Vector2 = Vector2.ZERO

var physics_enabled:= true

func _ready():
    collision_area = Area2D.new()
    add_child(collision_area)
    collision_shape = CollisionShape2D.new()
    collision_area.add_child(collision_shape)

func _physics_process(_delta):
    if !physics_enabled:
        return
    _apply_forces(_delta)
    _process_collisions(_delta)
    _process_movement(_delta)

func _apply_forces(_delta):
    pass
func _process_collisions(_delta):
    pass
func _process_movement(_delta):
    pass


func collide_with(p_body: PhysicsObject) -> Collision:
    return Collision.new(self, p_body, collision_elasticity, minimum_collision_speed)


class Collision:
    var normal: Vector2
    var speed: float

    func _init(p_object_1: PhysicsObject, p_object_2: PhysicsObject,
            p_collision_elasticity: float = 0.5, p_minimum_collision_speed: float = 0.5):
            
        var displacement = p_object_1.position - p_object_2.position
        normal = displacement.normalized()

        speed = (p_object_1.velocity.length() + p_object_2.velocity.length())
        speed *= p_collision_elasticity
        speed += p_minimum_collision_speed