class_name TimeDependantBalanceBeam
extends DrawnBalanceBeam

signal shrunk()

@export var velocity_multiplier_increase_per_second: float = 1

@export_subgroup('shrinking', "shrink")
@export var shrink_delay: float = 2
@export var shrink_period: float = 4
@export var shrink_amount: float = 20
@export var shrink_minimum: float = 40

@export_subgroup('shrink tween', 'shrink_tween')
@export var shrink_tween_duration: float = 0.5
@export var shrink_tween_easing: Tween.EaseType
@export var shrink_tween_transition_type: Tween.TransitionType

@onready var starting_width: float = width

var timer: float

var shrink_timer: float
var shrink_tween: Tween


func start_tweened_reset(reset_tween: Tween, duration: float):
  super(reset_tween, duration)
  _reset_timers()
  reset_tween.tween_property(self, 'width', starting_width, duration)

func reset():
  super()
  _reset_timers()
  width = starting_width
  queue_redraw()

func _reset_timers():
  timer = 0
  shrink_timer = 0
  if shrink_tween: shrink_tween.kill()


func _process(delta: float):
  if !physics_enabled:
    queue_redraw()
    return

  timer += delta

  if timer > shrink_delay:
    shrink_timer += delta
    if shrink_timer > shrink_period && width > shrink_minimum:
      start_shrink_tween()
      shrunk.emit()
      shrink_timer -= shrink_period

  if shrink_tween && shrink_tween.is_running():
    queue_redraw()

func start_shrink_tween():
  shrink_tween = create_tween()
  shrink_tween.set_ease(shrink_tween_easing)
  shrink_tween.set_trans(shrink_tween_transition_type)
  shrink_tween.tween_property(self, 'width', width - shrink_amount, shrink_tween_duration)


func _get_velocity_multiplier() -> float:
  return 1 + timer * velocity_multiplier_increase_per_second
