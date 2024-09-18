class_name ResetManager
extends Node2D

signal reset_completed

@export var ball_manager: PhysicsBallManager
@export var balance_beam: BalanceBeam

@export_subgroup('parameters', 'reset')
@export var reset_duration: float = 1
@export var reset_easing: Tween.EaseType = Tween.EASE_IN_OUT
@export var reset_transition: Tween.TransitionType = Tween.TRANS_BACK

@export var cancellation_threshold: float = 0.6

var reset_tween: Tween
var can_cancel_reset := false


func _process(_delta: float):
  if reset_tween && can_cancel_reset && Input.is_anything_pressed():
    cancel_reset()

func start_reset():
  reset_tween = _create_reset_tween()

  ball_manager.physics_enabled = false
  for ball in PhysicsBallManager.physics_balls:
    ball.start_tweened_reset(reset_tween, reset_duration)
  balance_beam.start_tweened_reset(reset_tween, reset_duration)

  _tween_signal_callback(reset_tween)

  can_cancel_reset = false
  var cancel_window_tween = create_tween()
  cancel_window_tween.tween_interval(cancellation_threshold)
  cancel_window_tween.tween_callback(_open_cancellation_window)


func _create_reset_tween() -> Tween:
  var tween = create_tween()
  tween.set_ease(reset_easing)
  tween.set_trans(reset_transition)
  tween.set_parallel(true)
  return tween

func _tween_signal_callback(tween: Tween):
  tween.set_parallel(false)
  tween.tween_callback(reset_completed.emit)


func cancel_reset():
  reset_tween.kill()
  can_cancel_reset = false
  reset_completed.emit()

func _open_cancellation_window():
  can_cancel_reset = true


func reset_ball(ball: PhysicsBall):
  var tween = _create_reset_tween()
  ball.start_tweened_reset(tween, reset_duration)
  _tween_signal_callback(tween)


func freeze():
  ball_manager.physics_enabled = false
  balance_beam.physics_enabled = false

func end_reset_freeze():
  ball_manager.reset_balls()
  balance_beam.reset()