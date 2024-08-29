class_name WaterParticle

var lifetime: float
var position: Vector2
var radius: float

var velocity: Vector2
var bounds: Rect2

var lifetime_ratio: get = _get_lifetime_ratio
var _max_lifetime: float


func _init(_lifetime: float, _position: Vector2, \
    _velocity: Vector2, _bounds: Rect2):
  lifetime = _lifetime
  _max_lifetime = lifetime
  position = _position
  velocity = _velocity
  bounds = _bounds


func process(delta: float, gravity: float, friction: float = 0) -> bool:
  var delta_scale = 60 * delta
  position += velocity * delta_scale
  _process_collision()
  velocity.y += gravity * delta
  velocity *= (1 - friction * delta_scale)

  lifetime -= delta
  return lifetime < 0
  
func _process_collision():
  if position.x > bounds.end.x || position.x < bounds.position.x:
    velocity.x *= -1

func _get_lifetime_ratio() -> float:
  return clampf(lifetime / _max_lifetime, 0, 1)