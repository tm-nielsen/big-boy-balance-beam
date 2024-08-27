class_name PhysicsObject
extends Node2D

var velocity: Vector2 = Vector2.ZERO

var physics_enabled:= true

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


func add_collision(_collision: Collision):
    pass