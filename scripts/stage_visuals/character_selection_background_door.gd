extends Node3D

@export var open_position := Vector3(-1.25, 0, 0)
@export var closed_position := Vector3(-0.5, 0, 0)

@export var character_selector: CharacterSelector

@export_subgroup('close tween settings', 'close_tween')
@export var close_tween_duration: float = 0.6
@export var close_tween_easing := Tween.EASE_OUT
@export var close_tween_transition := Tween.TRANS_BOUNCE

@export_subgroup('open tween settings', 'open_tween')
@export var open_tween_duration: float = 0.3
@export var open_tween_easing := Tween.EASE_IN
@export var open_tween_transition := Tween.TRANS_CIRC

var movement_tween: Tween


func _ready():
  position = closed_position
  character_selector.selection_started.connect(_on_selection_started)
  character_selector.character_selected.connect(_on_character_selected)


func close():
  _start_movement_tween(closed_position, close_tween_duration, close_tween_easing, close_tween_transition)

func open():
  _start_movement_tween(open_position, open_tween_duration, open_tween_easing, open_tween_transition)

func _start_movement_tween(target_position: Vector3, duration: float,
    easing: Tween.EaseType, transition: Tween.TransitionType):
  if movement_tween: movement_tween.kill()
  movement_tween = create_tween()
  movement_tween.set_ease(easing)
  movement_tween.set_trans(transition)
  movement_tween.tween_property(self, 'position', target_position, duration)


func _on_selection_started():
  close()

func _on_character_selected(_path):
  open()