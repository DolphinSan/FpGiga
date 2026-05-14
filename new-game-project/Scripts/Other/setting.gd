extends Control

@onready var slider:      HSlider = $Panel/HSlider
@onready var label_nilai: Label   = $Panel/LabelNilai
@onready var btn_back:    Button  = $Panel/BtnBack
@onready var btn_home:    Button  = $Panel/BtnHome
@onready var btn_save:    Button  = $Panel/BtnSave
@export var save_slot_scene: PackedScene

const SAVE_KEY := "volume"

func _ready() -> void:
	slider.min_value = 0
	slider.max_value = 100
	slider.step      = 1

	var saved := _load_volume()
	slider.value = saved
	_apply_volume(saved)
	_update_label(saved)

	slider.value_changed.connect(_on_slider_changed)
	btn_back.pressed.connect(_on_back)
	btn_home.pressed.connect(_on_home)
	btn_save.pressed.connect(_on_save)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_back()

func _on_slider_changed(val: float) -> void:
	_update_label(val)
	_apply_volume(val)

func _apply_volume(val: float) -> void:
	# Konversi 0-100 ke desibel (-80 sampai 0)
	var db := linear_to_db(val / 100.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), db)

func _update_label(val: float) -> void:
	label_nilai.text = "%d%%" % int(val)

func _on_save() -> void:
	var panel := save_slot_scene.instantiate()
	get_tree().current_scene.add_child(panel)
	panel.setup("save")

func _on_back() -> void:
	visible = false

func _on_home() -> void:
	get_tree().change_scene_to_file("res://Scene/MainMenu.tscn")

func _save_volume(val: float) -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", SAVE_KEY, val)
	cfg.save("user://settings.cfg")

func _load_volume() -> float:
	var cfg := ConfigFile.new()
	if cfg.load("user://settings.cfg") == OK:
		return cfg.get_value("audio", SAVE_KEY, 80.0)
	return 80.0
