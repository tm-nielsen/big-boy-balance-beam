extends Node

const FILE_NAME := "settings.ini"

var timeout_enabled: bool
var timeout_period: int

var joystick_squishes: bool

var master_volume: float
var music_volume: float
var sfx_volume: float

var last_input_timestamp: int = 0

func _ready():
  process_mode = Node.PROCESS_MODE_ALWAYS
  Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
  var config = ConfigFile.new()
  load_settings(config)
  save_settings(config)
  apply_volume_settings()

func _input(_event):
  last_input_timestamp = Time.get_ticks_msec()

func _process(_delta):
  var time_delta = Time.get_ticks_msec() - last_input_timestamp
  var seconds_since_last_input = time_delta / 1000.0
  if Input.is_action_just_pressed('quit') || \
      (timeout_enabled && seconds_since_last_input > timeout_period):
    get_tree().quit()


func load_settings(config: ConfigFile):
  config.load(get_file_path())

  timeout_enabled = config.get_value("TIMEOUT", "timeout_enabled", true)
  timeout_period = config.get_value("TIMEOUT", "timeout_period_seconds", 180)

  joystick_squishes = config.get_value("CONTROLS", "joystick_squishes", true)

  master_volume = config.get_value("VOLUME", "master_volume", 1.0)
  music_volume = config.get_value("VOLUME", "music_volume", 1.0)
  sfx_volume = config.get_value("VOLUME", "sfx_volume", 1.0)


func save_settings(config: ConfigFile):
  config.set_value("TIMEOUT", "timeout_enabled", timeout_enabled)
  config.set_value("TIMEOUT", "timeout_period_seconds", timeout_period)
  config.set_value("CONTROLS", "joystick_squishes", joystick_squishes)
  config.set_value("VOLUME", "master_volume", master_volume)
  config.set_value("VOLUME", "music_volume", music_volume)
  config.set_value("VOLUME", "sfx_volume", sfx_volume)
  config.save(get_file_path())


func apply_volume_settings():
  var master_bus = FmodServer.get_bus('bus:/')
  master_bus.volume = master_volume
  var music_bus = FmodServer.get_bus('bus:/Music')
  music_bus.volume = music_volume
  var sfx_bus = FmodServer.get_bus('bus:/SFX')
  sfx_bus.volume = sfx_volume


func get_file_path() -> String:
  if OS.has_feature("editor"):
    return "res://".path_join(FILE_NAME)
  return OS.get_executable_path().get_base_dir().path_join(FILE_NAME)
