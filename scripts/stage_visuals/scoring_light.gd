@tool
class_name ScoringLight
extends Node2D

@export var stroke_width: float = 2
@export var on: bool = false

@export_subgroup('off style', 'off')
@export var off_fill_colour: Color = Color.GRAY
@export var off_stroke_colour: Color = Color.DARK_GRAY
@export var off_radius: float = 8
@export var off_tween_duration: float = 0.5
@export var off_tween_easing := Tween.EASE_IN_OUT
@export var off_tween_transition := Tween.TRANS_BACK

@export_subgroup('on style', 'on')
@export var on_fill_colour: Color = Color.RED
@export var on_stroke_colour: Color = Color.DARK_RED
@export var on_radius: float = 10
@export var on_tween_duration: float = 0.4
@export var on_tween_easing := Tween.EASE_IN_OUT
@export var on_tween_transition := Tween.TRANS_BACK

@export_subgroup('flash', 'flash')
@export var flash_fill_colour: Color = Color.WHITE
@export var flash_stroke_colour: Color = Color.WHITE
@export var flash_radius: float = 16
@export var flash_tween_duration: float = 0.2
@export var flash_tween_easing := Tween.EASE_IN
@export var flash_tween_transition := Tween.TRANS_BACK

var fill_colour: Color
var stroke_colour: Color
var radius: float


func _ready():
  fill_colour = off_fill_colour
  stroke_colour = off_stroke_colour
  radius = off_radius

func _process(_delta: float):
  queue_redraw()
  if Engine.is_editor_hint():
    fill_colour = on_fill_colour if on else off_fill_colour
    stroke_colour = on_stroke_colour if on else off_stroke_colour
    radius = on_radius if on else off_radius


func turn_on():
  _start_flash_tween()
  var delay_tween = create_tween()
  delay_tween.tween_interval(flash_tween_duration)
  delay_tween.tween_callback(_start_on_tween)
  
func _start_flash_tween():
  var flash_tween = _create_eased_tween(flash_tween_easing, flash_tween_transition)
  _tween_style(flash_tween, flash_fill_colour, flash_stroke_colour, flash_radius, flash_tween_duration)

func _start_on_tween():
  var on_tween = _create_eased_tween(on_tween_easing, on_tween_transition)
  _tween_style(on_tween, on_fill_colour, on_stroke_colour, on_radius, on_tween_duration)

func turn_off():
  var off_tween = _create_eased_tween(off_tween_easing, off_tween_transition)
  _tween_style(off_tween, off_fill_colour, off_stroke_colour, off_radius, off_tween_duration)
  

func _tween_style(tween: Tween, fill: Color, stroke: Color, r: float, duration:float):
  tween.tween_property(self, 'fill_colour', fill, duration)
  tween.tween_property(self, 'stroke_colour', stroke, duration)
  tween.tween_property(self, 'radius', r, duration)

func _create_eased_tween(easing: Tween.EaseType, transition: Tween.TransitionType) -> Tween:
  var tween = create_tween()
  tween.set_ease(easing)
  tween.set_trans(transition)
  tween.set_parallel()
  return tween


func  _draw():
  draw_circle(Vector2.ZERO, radius, fill_colour)
  draw_circle(Vector2.ZERO, radius, stroke_colour, false, stroke_width)