class_name Crown
extends Node2D

@export var offset: float = 4
@export var reset_position := Vector2(0, -80)

@export_subgroup('tracking', 'tracking')
@export_range(0, 1) var tracking_elasticity: float = 2.0
@export_range(0, 1) var tracking_friction: float = 0.2

var target: PlayerController
var velocity: Vector2


func _physics_process(delta: float):
  if is_instance_valid(target):
    var delta_scale = delta * 60
    var target_position = target.position
    target_position.y -= target.radius + offset

    velocity += (target_position - position) * tracking_elasticity
    velocity *= (1 - tracking_friction * delta_scale)
    
    position += velocity * delta


func _on_round_won(leading_player_index: int):
  target = _get_player_ball_by_index(leading_player_index)


func _get_player_ball_by_index(player_index: int) -> PlayerController:
  for ball in PhysicsBallManager.physics_balls:
    if ball.player_index == player_index:
      return ball
  return null


func _on_stage_limits_bottom_threshold_reached(ball: PhysicsBall):
  if ball == target:
    position = reset_position
    velocity = Vector2.ZERO