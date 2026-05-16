extends Control

@onready var buttons := [
	$Panel/VBoxContainer/BtnEnding1,
	$Panel/VBoxContainer/BtnEnding2,
	$Panel/VBoxContainer/BtnEnding3,
	$Panel/VBoxContainer/BtnEnding4,
	$Panel/VBoxContainer/BtnEnding5,
	$Panel/VBoxContainer/BtnEnding6,
	$Panel/VBoxContainer/BtnEnding7,
	$Panel/VBoxContainer/BtnEnding8,
	$Panel/VBoxContainer/BtnEnding9
]

@onready var btn_back := $Panel/BtnBack
@onready var label_judul := $Panel/LabelJudul

const ENDING_NAMES := {
	GameConstants.Ending.SUKSES_AKADEMIK: "Sukses Akademik",
	GameConstants.Ending.PEMALAS: "Si Pemalas",
	GameConstants.Ending.SUKSES_PASSION: "Sukses Passion",
	GameConstants.Ending.MEMBERONTAK: "Memberontak",
	GameConstants.Ending.DEPRESI: "Depresi",
	GameConstants.Ending.MANDIRI_BAHAGIA: "Mandiri & Bahagia",
	GameConstants.Ending.NORMAL: "Normal",
	GameConstants.Ending.NORMAL_TIDAK_JELAS: "Normal(?)",
	GameConstants.Ending.TRUE_ENDING: "???"
}

func _ready():

	# DEBUG
	GameState.unlocked_endings = [
		GameConstants.Ending.SUKSES_AKADEMIK,
		GameConstants.Ending.SUKSES_PASSION,
		GameConstants.Ending.MEMBERONTAK,
		GameConstants.Ending.DEPRESI,
		GameConstants.Ending.MANDIRI_BAHAGIA,
	]
	btn_back.pressed.connect(_on_back)
	_refresh_gallery()

func _refresh_gallery():
	var endings := [
		GameConstants.Ending.SUKSES_AKADEMIK,
		GameConstants.Ending.PEMALAS,
		GameConstants.Ending.SUKSES_PASSION,
		GameConstants.Ending.MEMBERONTAK,
		GameConstants.Ending.DEPRESI,
		GameConstants.Ending.MANDIRI_BAHAGIA,
		GameConstants.Ending.NORMAL,
		GameConstants.Ending.NORMAL_TIDAK_JELAS,
		GameConstants.Ending.TRUE_ENDING
	]

	for i in range(buttons.size()):
		var btn = buttons[i]
		if i >= endings.size():
			btn.visible = false
			continue
		var ending_id = endings[i]
		var unlocked := false
		
		if ending_id == GameConstants.Ending.TRUE_ENDING:
			unlocked = _all_endings_unlocked()
		else:
			unlocked = GameState.unlocked_endings.has(ending_id)

		if unlocked:
			if ending_id == GameConstants.Ending.TRUE_ENDING:
				btn.text = "???"
			else:
				btn.text = ENDING_NAMES[ending_id]
			btn.disabled = false

			if not btn.pressed.is_connected(
				func(): _show_ending(ending_id)
			):
				btn.pressed.connect(
					func():
						_show_ending(ending_id)
				)
		else:
			if ending_id == GameConstants.Ending.TRUE_ENDING:
				btn.text = "???"
			else:
				btn.text = "LOCKED"

			btn.disabled = true

func _show_ending(ending_id: int):
	if ending_id == GameConstants.Ending.TRUE_ENDING:
		get_tree().change_scene_to_file(
			"res://Scene/TrueEnding.tscn"
		)
		return
	
	if ending_id == GameConstants.Ending.MANDIRI_BAHAGIA:
		get_tree().change_scene_to_file(
			"res://Scene/GoodEnding.tscn"
		)
		return
		
	GameState.current_ending = ending_id

	get_tree().change_scene_to_file(
		"res://Scene/Ending.tscn"
	)

func _all_endings_unlocked() -> bool:

	var required := [
		GameConstants.Ending.SUKSES_AKADEMIK,
		GameConstants.Ending.PEMALAS,
		GameConstants.Ending.SUKSES_PASSION,
		GameConstants.Ending.MEMBERONTAK,
		GameConstants.Ending.DEPRESI,
		GameConstants.Ending.MANDIRI_BAHAGIA,
		GameConstants.Ending.NORMAL,
		GameConstants.Ending.NORMAL_TIDAK_JELAS
	]

	for e in required:
		if not GameState.unlocked_endings.has(e):
			return false

	return true
	
func _on_back():
	queue_free()
