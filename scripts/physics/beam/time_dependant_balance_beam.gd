class_name TimeDependantBalanceBeam
extends DrawnBalanceBeam

@export var velocity_multiplier_increase_per_second: float = 1

var timer: float

func reset():
  super()
  timer = 0

func _physics_process(delta: float):
  timer += delta
  super(delta)

func _get_velocity_multiplier() -> float:
  return 1 + timer * velocity_multiplier_increase_per_second