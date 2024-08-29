class_name ShakyCamera
extends Camera2D

@export var impulse_scale: float = 1
@export var elasticity: float = 0.1
@export var friction: float = 0.2

@export_subgroup('input parameters')
@export var displacement_inverse_scale := Vector2(100, 60)
@export var collision_speed_inverse_scale: float = 2
@export var slam_impulse_inverse_scale: float = 2
@export var beam_shrink_zoom_impulse: float = 0.05
@export var score_speed_inverse_scale: float = 2
@export var score_base_speed: float = 10

@export_subgroup('zoom parameters', 'zoom')
@export var zoom_elasticity: float = 0.1
@export var zoom_friction: float = 0.2

@export_subgroup('references')
@export var ball_manager: PhysicsBallManager
@export var balance_beam: TimeDependantBalanceBeam
@export var stage_limits: StageLimits

var velocity: Vector2

var scalar_zoom: float = 1
var zoom_velocity: float


func _ready():
  ball_manager.balls_collided.connect(_on_balls_collided)
  balance_beam.slam_received.connect(_on_beam_slammed)
  balance_beam.shrunk.connect(_on_beam_shrunk)
  stage_limits.bottom_threshold_reached.connect(_on_ball_scored)


func _physics_process(delta: float):
  velocity -= position * elasticity
  velocity *= (1 - friction * 60 * delta)
  position += velocity

  zoom_velocity += (1 - scalar_zoom) * zoom_elasticity
  zoom_velocity *= (1 - friction * 60 * delta)
  scalar_zoom += zoom_velocity
  zoom = Vector2.ONE * scalar_zoom


func add_impulse_at_position(impulse: Vector2, impulse_position: Vector2):
  var displacement_impulse = _get_displacement_impulse(impulse_position)
  velocity += impulse * impulse_scale
  velocity += displacement_impulse * impulse_scale


func _on_balls_collided(collision: Collision):
  var impulse_strength = collision.speed / collision_speed_inverse_scale
  var impulse = impulse_strength * collision.momentum_direction

  add_impulse_at_position(impulse, collision.centre)
  

func _on_beam_slammed(ball: PhysicsBall):
  var impulse_strength = ball.velocity.length()
  impulse_strength /= slam_impulse_inverse_scale
  var impulse = Vector2(1, -1) * impulse_strength
  impulse.x *= BalanceBeam.normal.x

  add_impulse_at_position(impulse, ball.position)


func _on_ball_scored(ball: PhysicsBall):
  var impulse_strength = ball.velocity.length()
  impulse_strength = score_speed_inverse_scale
  impulse_strength += score_base_speed
  var impulse = Vector2.DOWN * impulse_strength

  add_impulse_at_position(impulse, ball.position)


func _on_beam_shrunk():
  zoom_velocity += beam_shrink_zoom_impulse


func _get_displacement_impulse(incident_position: Vector2) -> Vector2:
  return incident_position / displacement_inverse_scale