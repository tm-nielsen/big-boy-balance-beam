extends MeshInstance2D

@export_subgroup('surface distortion', 'distortion')
@export var distortion_threshold: float = 50
@export var distortion_ramp_distance: float = 10

@export_subgroup('splash', 'splash_particle')
@export var splash_particle_lifetime: float = 2
@export var splash_particle_velocity_multiplier: float = 1
@export var splash_particle_offset := Vector2(0, -20)
@export var splash_particle_friction: float = 0.01
@export var splash_particle_gravity: float = 10
@export var splash_particle_bouyancy: float = 1
@export var splash_particle_friction_per_submergence: float = 0.01

var distortion_particles: Array[IndexedWaterParticle] = []
var screen_bounds: Rect2


func _ready():
  screen_bounds = get_viewport_rect()
  screen_bounds.position -= screen_bounds.size / 2
  _set_material_distortion_parameter('amount', 1, 0)
  _set_material_distortion_parameter('amount', 2, 0)

func _physics_process(delta: float):
  for ball in PhysicsBallManager.physics_balls:
    distort_surface(ball)

  var dead_particles_indices = []
  var index = 0
  for particle in distortion_particles:
    if process_particle(particle, delta):
      dead_particles_indices.append(index)
    index += 1
    
  for dead_index in dead_particles_indices:
    distortion_particles.remove_at(dead_index)


func process_particle(particle: IndexedWaterParticle, delta: float) -> bool:
  var submergence = _get_particle_submergence(particle)
  var gravity = splash_particle_gravity
  gravity -= submergence * splash_particle_bouyancy
  var friction = splash_particle_friction
  friction += submergence * splash_particle_friction_per_submergence

  var dead = particle.process(delta, gravity, friction)
  apply_distortion_particle(particle)
  return dead


func distort_surface(ball: PlayerController):
  if ball.position.y < distortion_threshold:
    return
  var d = ball.position.y - distortion_threshold
  var t = clampf(d / distortion_ramp_distance, 0, 1)

  apply_surface_distortion(ball, t)


func apply_surface_distortion(ball: PlayerController, amount: float):
  _set_material_distortion_parameter('point', ball.player_index, ball.position)
  _set_material_distortion_parameter('amount', ball.player_index, amount)

func apply_distortion_particle(particle: WaterParticle):
  _set_material_distortion_parameter('point', particle.index, particle.position)
  _set_material_distortion_parameter('amount', particle.index, particle.lifetime_ratio)

func _set_material_distortion_parameter(p_name: String, player_index: int, value):
  var parameter_name = 'p%d_distortion_' % player_index + p_name
  material.set_shader_parameter(parameter_name, value)


func _on_stage_limits_bottom_threshold_reached(ball: PhysicsBall):
  distortion_particles.append(_make_splash_particle(ball))

func _make_splash_particle(ball: PlayerController) -> IndexedWaterParticle:
  var velocity = -ball.velocity * splash_particle_velocity_multiplier
  var spawn_position = ball.position + splash_particle_offset

  var particle = IndexedWaterParticle.new(splash_particle_lifetime, \
      spawn_position, velocity, screen_bounds)
  particle.index = ball.player_index
  return particle


func _get_particle_submergence(particle: WaterParticle) -> float:
  return clampf(particle.position.y - distortion_threshold, 0, INF)

class IndexedWaterParticle extends WaterParticle:
  var index: int