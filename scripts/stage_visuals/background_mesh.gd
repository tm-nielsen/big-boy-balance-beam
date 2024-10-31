extends MeshInstance3D

const GameState := GameManager.GameState

@export var material_pool: Array[Material]
@export var material_change_delay: float = 0.4

func _ready():
  _randomize_material()

func _on_game_state_changed(new_state: GameState):
  if new_state == GameState.CHARACTER_SELECTION:
    var tween = create_tween()
    tween.tween_interval(material_change_delay)
    tween.tween_callback(_randomize_material)

func _randomize_material():
  var previous_material = material_override
  while material_override == previous_material:
    material_override = material_pool.pick_random()