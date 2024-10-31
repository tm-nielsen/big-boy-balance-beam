class_name MusicManager
extends FmodParameterManager

const GameState = GameManager.GameState

var player_scores: Array[int] = [0, 0]


func _ready():
	return
	FmodServer.create_event_instance("event:/StageMusic").start()
	GameObserver.game_state_changed.connect(_on_game_state_changed)
	GameObserver.player_scored.connect(_on_player_scored)
	GameObserver.round_won.connect(_on_round_won)


func _on_game_state_changed(new_state: GameState):
	match new_state:
		GameState.CHARACTER_SELECTION:
			set_global_parameter('GameState', 'CharacterSelect')
			set_global_parameter_by_value('RoundWinner', 0)
			set_global_parameter_by_value('Player1Score', 0)
			set_global_parameter_by_value('Player2Score', 1)
		GameState.GAMEPLAY:
			set_global_parameter('GameState', 'Gameplay')
		GameState.RESETTING:
			set_global_parameter('GameState', 'Resetting')

func _on_player_scored(player_index: int):
	player_scores[player_index] += 1
	set_global_parameter_by_value('Player%dScore' % (player_index + 1), player_scores[player_index])

func _on_round_won(winner_index: int):
	set_global_parameter_by_value('RoundWinner', winner_index + 1)
	set_global_parameter('RoundWon', 'Yes')
	player_scores = [0, 0]