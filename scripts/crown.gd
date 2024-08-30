class_name Crown
extends Node2D

@export_range(0, 1) var tracking_strength: float = 0.4
@export_range(0, 1) var collection_strength: float = 0.05
@export var offset: float = 4
@export var lerp_strength_ramp_period: float = 2.0

var lerp_target: PlayerController
var lerp_strength: float

var lerp_strength_ramp_tween: Tween

func _ready():
  lerp_strength = collection_strength


func _physics_process(delta: float):
  if is_instance_valid(lerp_target):
    var delta_scale = delta * 60
    var target_position = lerp_target.position
    target_position.y -= lerp_target.radius + offset
    position = lerp(position, target_position, lerp_strength * delta_scale)


func _on_lead_player_switched(leading_player_index: int):
  lerp_target = _get_player_ball_by_index(leading_player_index)
  lerp_strength = collection_strength
  if lerp_strength_ramp_tween:
    lerp_strength_ramp_tween.kill()
  lerp_strength_ramp_tween = create_tween()
  lerp_strength_ramp_tween.tween_property(self, 'lerp_strength', \
      tracking_strength, lerp_strength_ramp_period)


func _get_player_ball_by_index(player_index: int) -> PlayerController:
  for ball in PhysicsBallManager.physics_balls:
    if ball.player_index == player_index:
      return ball
  return null