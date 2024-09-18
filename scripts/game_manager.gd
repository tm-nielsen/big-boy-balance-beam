class_name GameManager
extends Node2D

signal player_scored(player_index: int, score_increase: int)
signal lead_player_switched(player_index: int)

enum GameState {CHARACTER_SELECTION, FROZEN, GAMEPLAY, RESETTING}

@export var fallen_ball_reset_height: float = -120
@export var reset_delay: float = 1

@export_subgroup('references')
@export var reset_manager: ResetManager
@export var stage_limits: StageLimits
@export var character_selectors: Array[CharacterSelector]

var score_offset: int

var state := GameState.CHARACTER_SELECTION
var pending_selections := 2

# var round_completed: bool
# var is_resetting: bool

func _ready():
  reset_manager.reset_completed.connect(_on_reset_completed)
  stage_limits.bottom_threshold_reached.connect(_on_bottom_threshold_reached)
  reset_manager.freeze()
  for selector in character_selectors:
    selector.character_selected.connect(_on_character_selected)
    selector.start_selecting()

func _process(_delta: float):
  if state == GameState.FROZEN && Input.is_anything_pressed():
    state = GameState.GAMEPLAY
    reset_manager.end_reset_freeze()


func start_delayed_reset():
  state = GameState.RESETTING
  var reset_tween = create_tween()
  reset_tween.tween_interval(reset_delay)
  reset_tween.tween_callback(reset_manager.start_reset)


func _on_bottom_threshold_reached(ball: PlayerController):
  if state == GameState.GAMEPLAY:
    var scoring_player_index = 1 + ball.player_index % 2
    _score(scoring_player_index)
    start_delayed_reset()

  ball.physics_enabled = false
  ball.position.y = fallen_ball_reset_height

func _score(scoring_player_index: int):
    player_scored.emit(scoring_player_index, 1)
    if score_offset == 0:
      lead_player_switched.emit(scoring_player_index)
    score_offset += scoring_player_index * 2 - 3


func _on_reset_completed():
  match state:
    GameState.RESETTING:
      state = GameState.FROZEN
    GameState.CHARACTER_SELECTION:
      pending_selections -= 1
      if pending_selections == 0:
        state = GameState.FROZEN


func _on_character_selected(player_node):
  reset_manager.reset_ball(player_node)