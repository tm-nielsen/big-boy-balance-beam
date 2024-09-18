extends SubViewportContainer

const GameState = GameManager.GameState

@export var warp_amount: float = 0.4
@export var noise_amount: float = 0.3

@export_subgroup('tween in parameters', 'on_tween')
@export var on_tween_duration: float = 0.3
@export var on_tween_easing := Tween.EASE_OUT
@export var on_tween_transition := Tween.TRANS_BACK

@export_subgroup('tween out parameters', 'off_tween')
@export var off_tween_duration: float = 0.15
@export var off_tween_easing := Tween.EASE_IN_OUT
@export var off_tween_transition := Tween.TRANS_SINE

var effect_level: float


func _ready():
  _set_effect_level(0)


func start_on_tween():
  var on_tween = create_tween()
  on_tween.set_ease(on_tween_easing)
  on_tween.set_trans(on_tween_transition)
  on_tween.tween_method(_set_effect_level, 0.0, 1.0, on_tween_duration)

func start_off_tween():
  var off_tween = create_tween()
  off_tween.set_ease(off_tween_easing)
  off_tween.set_trans(off_tween_transition)
  off_tween.tween_method(_set_effect_level, 1.0, 0.0, off_tween_duration)


func _set_effect_level(t: float):
  material.set_shader_parameter('warp_amount', lerpf(0, warp_amount, t))
  material.set_shader_parameter('noise_amount', lerpf(0, noise_amount, t))
  effect_level = t


func _on_game_state_changed(state: GameState):
  if state == GameState.RESETTING:
    start_on_tween()
  elif state == GameState.FROZEN && effect_level == 1:
    start_off_tween()
