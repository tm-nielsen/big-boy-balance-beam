class_name ScoreLabel
extends Label

@export_range(1, 2) var player_index: int = 1

@export_subgroup('size tween', 'size_tween')
@export var size_tween_initial_size: float = 42
@export var size_tween_duration: float = 0.3
@export var size_tween_transition := Tween.TRANS_BACK
@export var size_tween_easing := Tween.EASE_IN_OUT

var score_value: int

var base_font_size: float
var font_size: set = _set_font_size


func _ready():
  base_font_size = get_theme_font_size('font_size')
  font_size = base_font_size
  text = ''

func add_score(score_increase: int = 1):
  score_value += score_increase
  text = str(score_value)

  font_size = size_tween_initial_size
  var size_tween = create_tween()
  size_tween.set_trans(size_tween_transition)
  size_tween.set_ease(size_tween_easing)
  size_tween.tween_property(self, 'font_size', base_font_size, size_tween_duration)


func _on_player_scored(scorer_index: int, score_increase: int = 1):
  if player_index == scorer_index:
    add_score(score_increase)


func _set_font_size(value: float):
  font_size = value
  add_theme_font_size_override('font_size', font_size)