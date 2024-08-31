extends Node

const FILE_NAME := "settings.ini"

var timeout_enabled: bool
var timeout_period: int

var master_volume: float
var music_volume: float
var sfx_volume: float

var last_input_timestamp: int = 0

func _ready():
  process_mode = Node.PROCESS_MODE_ALWAYS
  var config = ConfigFile.new()
  load_settings(config)
  save_settings(config)
  apply_volume_settings()

func _input(event):
  last_input_timestamp = Time.get_ticks_msec()
  print(event)

func _process(_delta):
  var time_delta = Time.get_ticks_msec() - last_input_timestamp
  var seconds_since_last_input = time_delta / 1000.0
  if Input.is_action_just_pressed('quit') || seconds_since_last_input > timeout_period:
    get_tree().quit()


func load_settings(config: ConfigFile):
  config.load(get_file_path())

  timeout_enabled = config.get_value("TIMEOUT", "timeout_enabled", true)
  timeout_period = config.get_value("TIMEOUT", "timeout_period_seconds", 180)

  master_volume = config.get_value("VOLUME", "master_volume", 1.0)
  music_volume = config.get_value("VOLUME", "music_volume", 0.5)
  sfx_volume = config.get_value("VOLUME", "sfx_volume", 0.5)


func save_settings(config: ConfigFile):
  config.set_value("TIMEOUT", "timeout_enabled", timeout_enabled)
  config.set_value("TIMEOUT", "timeout_period_seconds", timeout_period)
  config.set_value("VOLUME", "master_volume", master_volume)
  config.set_value("VOLUME", "music_volume", music_volume)
  config.set_value("VOLUME", "sfx_volume", sfx_volume)
  config.save(get_file_path())


func apply_volume_settings():
  var master_bus_index = AudioServer.get_bus_index("Master")
  AudioServer.set_bus_volume_db(master_bus_index, linear_to_db(master_volume))
  var music_bus_index = AudioServer.get_bus_index("Music")
  AudioServer.set_bus_volume_db(music_bus_index, linear_to_db(music_volume))
  var sfx_bus_index = AudioServer.get_bus_index("Sfx")
  AudioServer.set_bus_volume_db(sfx_bus_index, linear_to_db(sfx_volume))


func get_file_path() -> String:
  if OS.has_feature("editor"):
    return "res://".path_join(FILE_NAME)
  return OS.get_executable_path().get_base_dir().path_join(FILE_NAME)
