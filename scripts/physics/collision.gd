class_name Collision

var normal: Vector2
var speed: float
var centre: Vector2
var momentum_direction: Vector2

func _init(object_1: PhysicsObject, object_2: PhysicsObject,
        collision_elasticity: float = 0.5, minimum_collision_speed: float = 0.5):
        
    var displacement = object_1.position - object_2.position
    normal = displacement.normalized()
    centre = (object_1.position + object_2.position) / 2

    speed = (object_1.velocity.length() + object_2.velocity.length())
    speed *= collision_elasticity
    speed += minimum_collision_speed

    momentum_direction = object_1.velocity + object_2.velocity
    momentum_direction = momentum_direction.normalized()