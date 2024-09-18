@tool
class_name CharacterPreview
extends Node2D

var SquishState = SquishyPhysicsBall.SquishState

@export var radius: float = 12: set = _set_radius

@export_subgroup("movement")
@export var acceleration_mutliplier: float = 0.1
@export var egg_threshold: float = 0.5

@export_subgroup("squishing", "squish")
@export var squish_elasticity: float = 5
@export var squish_friction: float = 0.075
@export var squish_ratio_max: float = 0.35

var drawer: CharacterDrawer
var file_path: String: set = _set_file_path

var squish_ratio: float
var squish_delta: float
var squish_normal := Vector2.ONE
var squish_state: int

var previous_velocity: Vector2
var previous_position: Vector2


func _ready():
  drawer = CharacterDrawer.new()
  drawer.radius = radius
  add_child(drawer)


func _physics_process(delta: float):
  var velocity = position - previous_position
  var acceleration = velocity - previous_velocity
  previous_position = position
  previous_velocity = velocity

  if acceleration.length() < 100:
    squish_delta += acceleration.length() * acceleration_mutliplier
  _oscillate_squish_ratio(delta)
  _set_squish_state(acceleration)
  drawer.update_parameters(0, squish_ratio, squish_normal, squish_state)


func _oscillate_squish_ratio(delta):
    var delta_scale = 60 * delta

    squish_delta += (1 - squish_ratio) * squish_elasticity * delta
    squish_delta *= (1 - squish_friction * delta_scale)
    squish_ratio += squish_delta * delta_scale

    squish_ratio = clamp(squish_ratio, squish_ratio_max, 1 / squish_ratio_max)

    if abs(squish_delta) < 0.005 and abs(1.0 - squish_ratio) < 0.005:
        squish_ratio = 1.0
        squish_delta = 0.0
    queue_redraw()


func _set_squish_state(acceleration: Vector2):
  if acceleration.length() > egg_threshold:
    squish_state = SquishState.EGG
    squish_normal = acceleration.normalized()
  elif squish_state < 1:
    squish_state = SquishState.ELLIPSE


func reset_squish():
  previous_position = position
  previous_velocity = Vector2.ZERO
  squish_ratio = 1.0
  squish_delta = 0


func apply_squish_to_physics_ball(ball: SquishyPhysicsBall):
  ball.squish_ratio = squish_ratio
  ball.squish_reset_delta = squish_delta
  ball.squish_state = SquishState.get(SquishState.keys()[squish_state])


func _set_file_path(path: String):
  file_path = path
  drawer.file_path = path

func _set_radius(r: float):
  radius = r
  drawer.radius = r