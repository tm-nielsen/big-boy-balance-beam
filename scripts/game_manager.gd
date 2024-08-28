class_name GameManager
extends Node2D

signal player_scored(player_index: int, score_increase: int)

@export var fallen_ball_reset_height: float = -120
@export var reset_delay: float = 1

@export_subgroup('references')
@export var reset_manager: ResetManager
@export var stage_limits: StageLimits

var round_completed: bool
var is_resetting: bool

func _ready():
  reset_manager.reset_completed.connect(_on_reset_completed)
  stage_limits.bottom_threshold_reached.connect(_on_bottom_threshold_reached)

func _process(_delta: float):
  if round_completed && !is_resetting:
    if Input.is_anything_pressed():
      round_completed = false
      reset_manager.end_reset_freeze()


func start_delayed_reset():
  is_resetting = true
  var reset_tween = create_tween()
  reset_tween.tween_interval(reset_delay)
  reset_tween.tween_callback(reset_manager.start_reset)


func _on_bottom_threshold_reached(ball: PlayerController):
  if !round_completed:
    var scoring_player_index = 1 + ball.player_index % 2
    player_scored.emit(scoring_player_index, 1)
    round_completed = true
    start_delayed_reset()

  ball.physics_enabled = false
  ball.position.y = fallen_ball_reset_height

func _on_reset_completed():
  is_resetting = false