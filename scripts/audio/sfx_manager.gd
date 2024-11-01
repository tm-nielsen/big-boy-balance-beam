class_name SfxManager
extends FmodEventEmitter

const GameState = GameManager.GameState

@export var collision_speed_scale_factor: float = 10 


func _ready():
  return
  GameObserver.player_scored.connect(_on_player_scored)
  GameObserver.game_state_changed.connect(_on_game_state_changed)
  GameObserver.character_selected.connect(_on_character_selected)
  GameObserver.selection_carousel_scrolled.connect(_on_selection_carousel_scrolled)
  GameObserver.beam_shrunk.connect(_on_beam_shrunk)
  GameObserver.player_died.connect(_on_player_died)
  GameObserver.balls_collided.connect(_on_players_collided)
  GameObserver.player_started_charging_jump.connect(_on_player_started_charging_jump)
  GameObserver.player_started_power_drop.connect(_on_player_started_power_drop)
  GameObserver.player_jumped.connect(_on_player_jumped)
  GameObserver.player_landed.connect(_on_player_landed)
  GameObserver.player_bounced.connect(_on_player_bounced)


func _on_player_scored(player_index: int):
  start_event('Player%dScored' % player_index)

func _on_game_state_changed(new_state: GameState):
  match new_state:
   GameState.CHARACTER_SELECTION:#start_event('CharacterSelectStarted')
	pass
   GameState.FROZEN:
	start_event('Reset')
   GameState.GAMEPLAY:
	 #start_event('GameplayStarted')


func _on_character_selected():
  start_event('CharacterSelected')

func _on_selection_carousel_scrolled():
  start_event('SelectionScrolled')


func _on_beam_shrunk():
  start_event('BeamShrunk')


func _on_player_died(player_index: int):
  start_event('Splash')

func _on_players_collided(collision_speed: float):
  var speed_scale = collision_speed / collision_speed_scale_factor
  #start_event_with_parameters('Collision', {'NormalizedSpeed': speed_scale})
  start_event_with_parameters('Bounced', {'NormalizedForce': jump_speed_scale})

func _on_player_started_charging_jump():
  start_event('Squish')

func _on_player_started_power_drop():
  start_event('Drop')

func _on_player_jumped(jump_charge: float):
  start_event_with_parameters('Jump', {'NormalizedForce': jump_charge})

func _on_player_landed(jump_speed_scale: float):
  start_event_with_parameters('Land', {'NormalizedForce': jump_speed_scale})

func _on_player_bounced(jump_speed_scale: float):
  start_event_with_parameters('Bounced', {'NormalizedForce': jump_speed_scale})
