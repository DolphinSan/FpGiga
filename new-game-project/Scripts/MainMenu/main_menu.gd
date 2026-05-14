extends Node2D

@onready var btn_new_game:  Button = $VBoxContainer/BtnNewGame
@onready var btn_continue:  Button = $VBoxContainer/BtnContinue
@onready var btn_setting:   Button = $VBoxContainer/BtnSetting
@onready var btn_ending:    Button = $VBoxContainer/BtnEnding
@onready var btn_exit:      Button = $VBoxContainer/BtnExit
@onready var label_judul:   Label  = $LabelJudul

const GAMEPLAY_SCENE := "res://Scene/Gameplay/MainUI.tscn"
const ENDING_GALLERY  := "res://Scene/EndingGallery.tscn"

func _ready() -> void:
	label_judul.text = "Unsevering Thread"

	btn_new_game.pressed.connect(_on_new_game)
	btn_continue.pressed.connect(_on_continue)
	btn_setting.pressed.connect(_on_setting)
	btn_ending.pressed.connect(_on_ending)
	btn_exit.pressed.connect(_on_exit)

	var ada_save := SaveSystem.slot_exists(1) or SaveSystem.slot_exists(2) or SaveSystem.slot_exists(0)
	btn_continue.disabled = not ada_save
	btn_continue.modulate = Color(0.5, 0.5, 0.5) if ada_save else Color(0.5, 0.5, 0.5)

	print("[MainMenu] Save tersedia: ", ada_save)

func _on_new_game() -> void:
	print("[MainMenu] New Game")
	GameState.reset_new_game()
	get_tree().change_scene_to_file(GAMEPLAY_SCENE)

func _on_continue() -> void:
	print("[MainMenu] Continue")
	# Load save slot terakhir yang ada
	for slot in [0, 1, 2]:
		if SaveSystem.slot_exists(slot):
			SaveSystem.load_game(slot)
			SaveSystem.load_completed.connect(func(_s):
				get_tree().change_scene_to_file(GAMEPLAY_SCENE)
			, CONNECT_ONE_SHOT)
			return

func _on_setting() -> void:
	print("[MainMenu] Setting — belum dibuat")
	# TODO: buka panel setting

func _on_ending() -> void:
	print("[MainMenu] Ending Gallery — belum dibuat")
	# TODO: buka ending gallery
	# get_tree().change_scene_to_file(ENDING_GALLERY)

func _on_exit() -> void:
	print("[MainMenu] Exit")
	get_tree().quit()
