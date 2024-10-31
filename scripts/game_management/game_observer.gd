extends Node

const GameState = GameManager.GameState

signal game_state_changed(new_state: GameState)
signal player_died(player_index: int)
signal player_scored(player_index: int)
signal round_won(winner_index: int)

signal character_selected
signal selection_carousel_scrolled

signal beam_shrunk
signal balls_collided(collision_speed: float)

signal player_started_charging_jump
signal player_started_power_drop
signal player_jumped(jump_charge: float)
signal player_landed(jump_speed_ratio: float)
signal player_bounced(jump_speed_ratio: float)


func notify_game_state_changed(new_state: GameState):
  game_state_changed.emit(new_state)
func notify_player_died(player_index: int):
  player_died.emit(player_index)
func notify_player_scored(player_index):
  player_scored.emit(player_index)
func notify_round_won(winner_index):
  round_won.emit(winner_index)

func notify_character_selected():
  character_selected.emit()
func notify_selection_carousel_scrolled():
  selection_carousel_scrolled.emit()

func notify_beam_shrunk():
  beam_shrunk.emit()
func notify_balls_collided(collision_speed: float):
  balls_collided.emit(collision_speed)

func notify_player_started_charging_jump():
  player_started_charging_jump.emit()
func notify_player_started_power_drop():
  player_started_power_drop.emit()
func notify_player_jumped(jump_charge: float):
  player_jumped.emit(jump_charge)
func notify_player_landed(jump_speed_ratio: float):
  player_landed.emit(jump_speed_ratio)
func notify_player_bounced(jump_speed_ratio: float):
  player_bounced.emit(jump_speed_ratio)