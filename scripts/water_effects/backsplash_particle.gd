class_name BacksplashParticle
extends WaterParticle

var air_friction: float
var wall_friction: float
var gravity: float
var wall_contact_delay: float

var on_wall: bool: get = _get_on_wall


func _init(_lifetime: float, _position: Vector2, \
    _velocity: Vector2, _bounds: Rect2, \
    _air_friction: float, _wall_friction: float, \
    _wall_contact_delay: float, _gravity: float):
  super(_lifetime, _position, _velocity, _bounds)
  air_friction = _air_friction
  wall_friction = _wall_friction
  gravity = _gravity
  wall_contact_delay = _wall_contact_delay


func process(delta: float) -> bool:
  var friction = wall_friction if on_wall else air_friction
  var is_dead = process_with_parameters(delta, gravity, friction)
  is_dead = is_dead || position.y > StageLimits.bottom
  return is_dead


func _get_on_wall() -> bool:
  return _max_lifetime - lifetime > wall_contact_delay