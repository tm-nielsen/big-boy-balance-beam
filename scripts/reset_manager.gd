class_name ResetManager
extends Node2D

signal reset_completed

@export var ball_manager: PhysicsBallManager
@export var balance_beam: BalanceBeam

@export_subgroup('parameters', 'reset')
@export var reset_duration: float = 1
@export var reset_easing: Tween.EaseType = Tween.EASE_IN_OUT
@export var reset_transition: Tween.TransitionType = Tween.TRANS_BACK


func start_reset():
  var reset_tween = _create_reset_tween()

  ball_manager.physics_enabled = false
  for ball in PhysicsBallManager.physics_balls:
    ball.start_tweened_reset(reset_tween, reset_duration)
  balance_beam.start_tweened_reset(reset_tween, reset_duration)

  _tween_signal_callback(reset_tween)


func _create_reset_tween() -> Tween:
  var reset_tween = create_tween()
  reset_tween.set_ease(reset_easing)
  reset_tween.set_trans(reset_transition)
  reset_tween.set_parallel(true)
  return reset_tween

func _tween_signal_callback(reset_tween: Tween):
  reset_tween.set_parallel(false)
  reset_tween.tween_interval(reset_duration)
  reset_tween.tween_callback(reset_completed.emit)


func reset_ball(ball: PhysicsBall):
  var reset_tween = _create_reset_tween()
  ball.start_tweened_reset(reset_tween, reset_duration)
  _tween_signal_callback(reset_tween)


func freeze():
  ball_manager.physics_enabled = false
  balance_beam.physics_enabled = false

func end_reset_freeze():
  ball_manager.reset_balls()
  balance_beam.reset()