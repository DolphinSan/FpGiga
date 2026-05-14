extends Node2D

@onready var btn_new_game:  Button = $VBoxContainer/BtnNewGame
@onready var btn_continue:  Button = $VBoxContainer/BtnContinue
@onready var btn_setting:   Button = $VBoxContainer/BtnSetting
@onready var btn_ending:    Button = $VBoxContainer/BtnEnding
@onready var btn_exit:      Button = $VBoxContainer/BtnExit
@onready var label_judul:   Label  = $LabelJudul
@export var save_slot_scene: PackedScene
@export var EndingGallery: PackedScene

const GAMEPLAY_SCENE := "res://Scene/Gameplay/MainUI.tscn"
const ENDING_GALLERY  := "res://Scene/EndingGallery.tscn"

func _ready() -> void:
	print("[MainMenu] Continue disabled: ", btn_continue.disabled)
	print("[MainMenu] Continue modulate: ", btn_continue.modulate)
	label_judul.text = "Unsevering Thread"

	btn_new_game.pressed.connect(_on_new_game)
	btn_continue.pressed.connect(_on_continue)
	btn_setting.pressed.connect(_on_setting)
	btn_ending.pressed.connect(_on_ending)
	btn_exit.pressed.connect(_on_exit)

	var ada_save := SaveSystem.slot_exists(1) or SaveSystem.slot_exists(2) or SaveSystem.slot_exists(0)
	btn_continue.disabled = not ada_save
	btn_continue.modulate = Color(1, 1, 1) if ada_save else Color(0.5, 0.5, 0.5)

	print("[MainMenu] Save tersedia: ", ada_save)

func _on_new_game() -> void:
	var panel := save_slot_scene.instantiate()
	add_child(panel)
	panel.setup("new_game")
	panel.slot_dipilih.connect(func(_slot):
		get_tree().change_scene_to_file(GAMEPLAY_SCENE)
	)

func _on_continue() -> void:
	var panel := save_slot_scene.instantiate()
	add_child(panel)
	panel.setup("load")
	panel.slot_dipilih.connect(func(slot):
		get_tree().change_scene_to_file(GAMEPLAY_SCENE)
	)

func _on_setting() -> void:
	print("[MainMenu] Setting — belum dibuat")
	# TODO: buka panel setting

func _on_ending() -> void:
	#get_tree().change_scene_to_file(ENDING_GALLERY)
	var panel := EndingGallery.instantiate()
	add_child(panel)
	

func _on_exit() -> void:
	print("[MainMenu] Exit")
	get_tree().quit()
