extends Node2D

const GameState = GameManager.GameState

@export var main_loop_player: AudioStreamPlayer
@export var transition_player: AudioStreamPlayer
@export var semitones_increase: int = 1

var score_count: int


func _on_game_state_changed(new_state: GameState):
	if new_state == GameState.GAMEPLAY:
		main_loop_player.play()
		main_loop_player.pitch_scale = pow(2, score_count / 12.0)
		transition_player.stop()

func _on_round_won(_winner):
	score_count = 0
	main_loop_player.pitch_scale = 1

func _on_player_scored(_scoring_index):
	score_count += 1
	main_loop_player.stop()
	transition_player.play()