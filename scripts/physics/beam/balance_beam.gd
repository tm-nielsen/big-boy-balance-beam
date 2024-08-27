@tool
class_name BalanceBeam
extends Node2D

signal slam_received(colliding_ball: PhysicsBall)

static var instance: BalanceBeam
static var beam_angle: get = _get_beam_angle
static var normal: get = _get_normal
static var tangent: get = _get_tangent

@export var width: float = 160

@export_subgroup('movement')
@export var friction: float = 0.03
@export_range(0, 180) var max_angle_degrees: float = 60
@export_range(0, 1) var max_angle_bounce: float = 0.2

@export_subgroup('collisions')
@export var minimum_collision_speed: float = 1
@export var ball_mass: float = 1
@export var ball_slam_multiplier: float = 5

var physics_enabled: bool = true
var max_angle: float

var angular_velocity: float
var velocity_multiplier: get = _get_velocity_multiplier


func _ready():
  instance = self
  max_angle = deg_to_rad(max_angle_degrees)

func _physics_process(delta: float):
  if physics_enabled:
    _process_movement(delta)
    _process_collisions(delta)


func start_tweened_reset(reset_tween: Tween, duration: float):
  physics_enabled = false
  angular_velocity = 0
  reset_tween.tween_property(self, 'rotation', 0, duration)

func reset():
  physics_enabled = true
  rotation = 0
  angular_velocity = 0


func _process_movement(delta: float):
  angular_velocity -= angular_velocity * friction * delta
  rotation += angular_velocity * velocity_multiplier * delta

  if abs(rotation) > max_angle:
    rotation = clamp(rotation, -max_angle, max_angle)
    angular_velocity *= -max_angle_bounce


func _process_collisions(delta: float):
  var balls = get_tree().get_nodes_in_group(PhysicsBall.GROUP_NAME)

  var half_length = tangent * width / 2
  var ends = [position - half_length, position + half_length]

  for ball in balls:
    var collision_point = _get_beam_point(ball.position)
    if collision_point:
      if (ball.position - collision_point).dot(normal) > 0:
        collide_with_beam(ball, collision_point, delta)
      else: collide_with_elastic_point(ball, collision_point)
    else:
      ball.on_no_beam_collision()
    
    for end_point in ends:
      collide_with_elastic_point(ball, end_point, 0)


static func get_beam_point(point: Vector2):
  if instance:
    return instance._get_beam_point(point)
  return null

func _get_beam_point(point: Vector2):
  var displacement = point - position
  var half_length = tangent * width / 2

  var left_dot = tangent.dot(displacement + half_length)
  var right_dot = tangent.dot(displacement - half_length)
  if left_dot > 0 && right_dot < 0:
    var projection = displacement.project(tangent)
    return position + projection
  else:
    return null


func collide_with_beam(ball: PhysicsBall, point: Vector2, delta: float):
  if ball_intersects_point(ball, point):
    var normal_velocity = ball.velocity.project(normal)

    var collision_speed = normal_velocity.length()
    var fulcrum_offset = (point - position).project(tangent)
    var fulcrum_displacement = fulcrum_offset.length()
    fulcrum_displacement *= sign(fulcrum_offset.dot(tangent))
    var rotation_impulse = ball_mass * collision_speed
    rotation_impulse *= fulcrum_displacement / width
    if 'is_dropping' in ball && ball.is_dropping:
      rotation_impulse *= ball_slam_multiplier
      slam_received.emit(ball)
    angular_velocity += rotation_impulse * delta
    
    ball.on_beam_collision(normal_velocity)
  else:
    ball.on_no_beam_collision()


func collide_with_elastic_point(ball: PhysicsBall, point: Vector2, \
    p_minimum_collision_speed := minimum_collision_speed):
  if ball_intersects_point(ball, point):
    var displacement = ball.position - point

    var collision_normal = displacement.normalized()
    var collision_speed = ball.velocity.length() * ball.elasticity
    collision_speed += p_minimum_collision_speed

    ball.velocity += collision_normal * collision_speed


func ball_intersects_point(ball: PhysicsBall, point: Vector2) -> bool:
  return (ball.position - point).length() < ball.radius

static func get_velocity_at_point(point: Vector2) -> Vector2:
  if instance: return instance._get_velocity_at_point(point)
  return Vector2.ZERO

func _get_velocity_at_point(point: Vector2) -> Vector2:
  var fulcrum_distance = (point - position).length()
  var orbital_speed = angular_velocity * fulcrum_distance / TAU
  var direction = normal * sign((point - position).dot(tangent))
  return orbital_speed * -direction


static func _get_beam_angle() -> float:
  if instance: return instance.rotation
  return 0

static func _get_normal() -> Vector2:
  return Vector2.UP.rotated(beam_angle)

static func _get_tangent() -> Vector2:
  return Vector2.RIGHT.rotated(beam_angle)

func _get_velocity_multiplier() -> float:
  return 1