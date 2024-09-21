class_name GameManager
extends Node2D

signal round_won(player_index: int)
signal state_changed(new_state: GameState)

enum GameState {CHARACTER_SELECTION, FROZEN, GAMEPLAY, RESET_DELAY, RESETTING}

@export var fallen_ball_reset_height: float = -120
@export var reset_delay: float = 1
@export var round_reset_delay: float = 2

@export_subgroup('references')
@export var reset_manager: ResetManager
@export var round_manager: RoundManager
@export var stage_limits: StageLimits
@export var character_selectors: Array[CharacterSelector]

var score_offset: int

var state := GameState.CHARACTER_SELECTION: set = _set_state


func _ready():
  reset_manager.reset_completed.connect(_on_reset_completed)
  stage_limits.bottom_threshold_reached.connect(_on_bottom_threshold_reached)
  reset_manager.freeze()
  for selector in character_selectors:
    var on_select = _on_character_selected.bind(selector.player_target)
    selector.character_selected.connect(on_select)
    selector.start_selecting()

func _process(_delta: float):
  if state == GameState.FROZEN && Input.is_anything_pressed():
    state = GameState.GAMEPLAY
    reset_manager.end_reset_freeze()


func start_delayed_reset():
  state = GameState.RESET_DELAY
  var reset_tween = create_tween()
  reset_tween.tween_interval(reset_delay)
  reset_tween.tween_callback(_start_reset)

func _start_reset():
  state = GameState.RESETTING
  reset_manager.start_reset()


func _on_bottom_threshold_reached(ball: PlayerController):
  ball.physics_enabled = false
  ball.position.y = fallen_ball_reset_height

  if state == GameState.GAMEPLAY:
    var scoring_index = ball.player_index % 2
    round_manager.add_player_score(scoring_index)
    if round_manager.win_threshold_reached:
      round_won.emit(scoring_index + 1)
      _start_delayed_round_reset()
    else:
      start_delayed_reset()


func _start_delayed_round_reset():
  state = GameState.RESET_DELAY
  var round_reset_tween = create_tween()
  round_reset_tween.tween_interval(round_reset_delay)
  round_reset_tween.tween_callback(_reset_round)

func _reset_round():
  state = GameState.CHARACTER_SELECTION
  reset_manager.start_reset()
  round_manager.reset_round()
  for selector in character_selectors:
    selector.start_selecting()


func _on_reset_completed():
  match state:
    GameState.RESETTING:
      state = GameState.FROZEN
    GameState.CHARACTER_SELECTION:
      if !_is_character_selection_active():
        state = GameState.FROZEN


func _on_character_selected(_file_path, player_node: PlayerController):
  reset_manager.reset_ball(player_node)

func _is_character_selection_active() -> bool:
  for selector in character_selectors:
    if selector.is_selecting: return true
  return false

func _set_state(new_state: GameState):
  state = new_state
  state_changed.emit(state)