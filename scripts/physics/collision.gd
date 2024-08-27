class_name Collision

var normal: Vector2
var speed: float
var centre: Vector2

func _init(p_object_1: PhysicsObject, p_object_2: PhysicsObject,
        p_collision_elasticity: float = 0.5, p_minimum_collision_speed: float = 0.5):
        
    var displacement = p_object_1.position - p_object_2.position
    normal = displacement.normalized()
    centre = (p_object_1.position + p_object_2.position) / 2

    speed = (p_object_1.velocity.length() + p_object_2.velocity.length())
    speed *= p_collision_elasticity
    speed += p_minimum_collision_speed