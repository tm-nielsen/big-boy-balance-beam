@tool
class_name BalanceBeam
extends Node2D

static var instance: BalanceBeam
static var beam_angle: get = _get_beam_angle
static var normal: get = _get_normal
static var tangent: get = _get_tangent

@export var width: float = 160

@export_subgroup('movement')
@export var friction: float = 0.03
@export var loosening_factor: float = 1
@export_range(0, 180) var max_angle_degrees: float = 60
@export var minimum_collision_speed: float = 1
@export var ball_mass: float = 1

@export_subgroup('drawing')
@export var height: float = 6
@export var fill_colour: Color
@export var stroke_colour: Color
@export var stroke_width: float = -1

var physics_enabled: bool = true

var angular_velocity: float
var max_angle: float
var timer: float


func _ready():
  instance = self
  max_angle = deg_to_rad(max_angle_degrees)

func _draw():
  var tri_shape = ShapeGenerator.generate_triangle(width, -height)
  ShapeDrawer.draw_shape(self, tri_shape, fill_colour, stroke_width, stroke_colour)

func _physics_process(delta: float):
  if physics_enabled:
    _process_movement(delta)
    _process_collisions(delta)

func _process_movement(delta: float):
  timer += delta
  angular_velocity -= angular_velocity * friction * delta
  var looseness = (1 + timer * loosening_factor)
  rotation += angular_velocity * looseness * delta
  rotation = clamp(rotation, -max_angle, max_angle)


func _process_collisions(delta: float):
  var balls = get_tree().get_nodes_in_group(PhysicsBall.GROUP_NAME)
  # var beam_ends = _get_beam_ends()

  for ball in balls:
    var collision_point = _get_beam_point(ball.position)
    if collision_point:
      if (ball.position - collision_point).dot(normal) > 0:
        collide_with_beam(ball, collision_point, delta)
      else: collide_with_elastic_point(ball, collision_point)
    else:
      ball.on_no_beam_collision()
    # else:
    #   for end_point in beam_ends:
    #     collide_with_elastic_point(ball, end_point)
  

func reset():
  physics_enabled = true
  rotation = 0
  angular_velocity = 0
  timer = 0


func _get_beam_ends() -> Array[Vector2]:
  var half_length = tangent * width / 2
  return [position + half_length, position - half_length]


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
    var centre_distance = (point - position).dot(tangent)
    var rotation_impulse = ball_mass * collision_speed
    rotation_impulse *= centre_distance / width
    angular_velocity += rotation_impulse * delta
    
    ball.on_beam_collision(normal_velocity)
  else:
    ball.on_no_beam_collision()


func collide_with_elastic_point(ball: PhysicsBall, point: Vector2):
  if ball_intersects_point(ball, point):
    var displacement = ball.position - point

    var collision_normal = displacement.normalized()
    var collision_speed = ball.velocity.length() * ball.elasticity
    collision_speed += minimum_collision_speed

    ball.velocity = collision_normal * collision_speed


func ball_intersects_point(ball: PhysicsBall, point: Vector2) -> bool:
  return (ball.position - point).length() < ball.radius

  # var space_state = get_world_2d().direct_space_state
  # var query_parameters = PhysicsPointQueryParameters2D.new()
  # query_parameters.position = point
  # query_parameters.collide_with_areas = true
  # query_parameters.collide_with_bodies = false

  # var query_result = space_state.intersect_point(query_parameters)
  # for result_entry in query_result:
  #   if result_entry.collider == ball.collision_area:
  #     return true
  # return false


static func _get_beam_angle() -> float:
  if instance: return instance.rotation
  return 0

static func _get_normal() -> Vector2:
  return Vector2.UP.rotated(beam_angle)

static func _get_tangent() -> Vector2:
  return Vector2.RIGHT.rotated(beam_angle)