class_name FmodParameterManager
extends Node

@export var print_logs: bool = false
@export var event_name: String

var event_instance: FmodEvent


func _ready():
  if event_name:
    event_instance = FmodServer.create_event_instance('event:/%s' % event_name)
    event_instance.start()


func set_parameter(paramater_name: String, label: String):
  event_instance.set_parameter_by_name_with_label(paramater_name, label, false)
  if print_logs:
    print('setting fmod event paramater "%s" with label "%s"' % [paramater_name, label])

func set_parameter_by_value(parameter_name: String, value: float):
  event_instance.set_parameter_by_name(parameter_name, value)
  if print_logs:
    print('setting fmod event parameter "%s" with value "%s"' % [parameter_name, value])


func set_global_parameter(parameter_name: String, label: String):
  FmodServer.set_global_parameter_by_name_with_label(parameter_name, label)
  if print_logs:
    print('setting global fmod parameter "%s" with label "%s"' % [parameter_name, label])

func set_global_parameter_by_value(parameter_name: String, value: float):
  FmodServer.set_global_parameter_by_name(parameter_name, value)
  if print_logs:
    print('setting global fmod parameter "%s" with value "%s"' % [parameter_name, value])
