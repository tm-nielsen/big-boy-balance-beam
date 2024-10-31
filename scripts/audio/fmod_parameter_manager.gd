class_name FmodParameterManager
extends Node

@export var print_logs: bool = false

func set_global_parameter(parameter_name: String, label: String):
  FmodServer.set_global_parameter_by_name_with_label(parameter_name, label)
  if print_logs:
    print('setting global fmod parameter "%s" with label "%s"' % [parameter_name, label])

func set_global_parameter_by_value(parameter_name: String, value: float):
  FmodServer.set_global_parameter_by_name(parameter_name, value)
  if print_logs:
    print('setting global fmod parameter "%s" with value "%s"' % [parameter_name, value])