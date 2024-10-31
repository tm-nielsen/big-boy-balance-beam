class_name FmodEventEmitter
extends Node

@export var print_logs: bool = false

func start_event(event_name: String) -> FmodEvent:
  var event = _create_event(event_name)
  event.start()
  if print_logs:
    print('starting fmod event "%s"' % event_name)
  return event

func start_event_with_parameters(event_name: String, parameters: Dictionary) -> FmodEvent:
  var event = _create_event(event_name)
  for key in parameters:
    event.set_parameter_by_name(key, parameters[key])
  event.start()
  if print_logs:
    print(('starting fmod event "%s" with parameters: ' % event_name) + str(parameters))
  return event

func _create_event(event_name: String) -> FmodEvent:
  return FmodServer.create_event_instance('event:/%s' % event_name)