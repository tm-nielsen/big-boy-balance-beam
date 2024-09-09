class_name BacksplashParticles
extends MeshInstance2D

@export var emission_count: int = 40
@export var maximum_particles: int = 200
@export var frame_rate: int = 12
@export var preprocess_time: float = 0.0

@export_subgroup("lifetime")
@export var lifetime_minimum: float = 6
@export var lifetime_maximum: float = 16

@export_subgroup("velocity")
@export var spread: float = 30
@export var ball_speed_multiplier: float = 1
@export var speed_variation_curve: Curve

@export_subgroup("forces")
@export var gravity: float = 20

@export_subgroup("friction")
@export var wall_contact_delay_minimum: float = 0.1
@export var wall_contact_delay_maximum: float = 0.5
@export_range(0, 1) var air_friction_minimum: float = 0.04
@export_range(0, 1) var air_friction_maximum: float = 0.06
@export_range(0, 1) var wall_friction_minimum: float = 0.4
@export_range(0, 1) var wall_friction_maximum: float = 1.0

@export_subgroup("scale")
@export var particle_radius: float = 4
@export var wall_contact_scale: float = 2
@export var scale_over_lifetime_curve: Curve

var particle_list: Array[BacksplashParticle] = []
var screen_bounds: Rect2

var frame_period: float
var frame_timer: float


func _ready():
  frame_period = 1.0 / frame_rate
  screen_bounds = get_viewport_rect()
  screen_bounds.position -= screen_bounds.size / 2

  material = material.duplicate()
  var screen_resolution = get_viewport().size
  material.set_shader_parameter('screen_resolution', screen_resolution)

func _physics_process(delta: float):
  frame_timer += delta
  if frame_timer > frame_period:
    frame_timer -= frame_period
    _update_particles(frame_period)

func _process(_delta: float):
  modulate = get_parent().modulate
  _draw_particles()


func _update_particles(delta: float):
  var index = 0
  var dead_particles_indices = []
  for particle_data in particle_list:
    if particle_data.process(delta):
      dead_particles_indices.append(index)
    index += 1
  
  dead_particles_indices.sort_custom(func(a, b): return a > b)
  for dead_particle_index in dead_particles_indices:
    particle_list.remove_at(dead_particle_index)

func _draw_particles():
  material.set_shader_parameter('visible_ball_count', particle_list.size())

  var positions = PackedVector2Array()
  var radii = PackedFloat32Array()
  for particle in particle_list:
    positions.append(particle.position)
    var radius = particle_radius * (wall_contact_scale if particle.on_wall else 1.0)
    radius *= scale_over_lifetime_curve.sample(particle.lifetime_ratio)
    radii.append(radius)

  material.set_shader_parameter('ball_positions', positions)
  material.set_shader_parameter('ball_radii', radii)


func emit_burst(burst_position: Vector2, burst_velocity: Vector2, count := emission_count):
  for i in count:
    _emit_particle(burst_position, burst_velocity)
  _update_particles(preprocess_time)
  _draw_particles()

func _emit_particle(emission_point: Vector2, burst_velocity: Vector2):
  if particle_list.size() >= maximum_particles:
    return

  var lifetime = _get_spread_value(lifetime_minimum, lifetime_maximum)
  var velocity = _get_emission_velocity(burst_velocity)

  var air_friction = _get_spread_value(air_friction_minimum, air_friction_maximum)
  var wall_friction = _get_spread_value(wall_friction_minimum, wall_friction_maximum)
  var wall_contact_delay = _get_spread_value(wall_contact_delay_minimum, wall_contact_delay_maximum)
  var new_particle = BacksplashParticle.new(lifetime, emission_point, velocity, \
      screen_bounds, air_friction, wall_friction, wall_contact_delay, gravity)
  particle_list.append(new_particle)


func _get_emission_velocity(base_velocity: Vector2) -> Vector2:
  var emission_direction = _get_randomized_direction(base_velocity)
  var emission_speed = base_velocity.length()
  emission_speed *= speed_variation_curve.sample(randf())
  return emission_direction * emission_speed

func _get_randomized_direction(base_direction: Vector2) -> Vector2:
  if base_direction == Vector2.ZERO:
    var angle = randf() * TAU
    return Vector2(cos(angle), sin(angle))
  var deviance = deg_to_rad(spread) * (0.5 - randf())
  var particle_direction = base_direction.rotated(deviance)
  return particle_direction.normalized()


func _on_stage_limits_bottom_threshold_reached(ball: PhysicsBall):
  # self_modulate = ball.drawer.fill_colour
  # self_modulate.a = 0.5
  var burst_velocity = -ball.velocity * ball_speed_multiplier
  var burst_position = Vector2(ball.position.x, StageLimits.bottom - 20)
  emit_burst(burst_position, burst_velocity)

func _get_spread_value(min_value: float, max_value: float) -> float:
  return min_value + (max_value - min_value) * randf()