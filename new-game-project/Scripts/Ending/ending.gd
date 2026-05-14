extends Node2D

@onready var label_judul: Label = $Panel/Label
@onready var label_desc:  Label = $Panel/Label2
@onready var btn_menu:    Button = $Panel/VBoxContainer/Button

# Isi teks sesuai ending — ganti placeholder dengan teks final
const ENDING_DATA := {
	GameConstants.Ending.SUKSES_AKADEMIK: {
		"judul": "Ending: Sukses Akademik",
		"desc":  "placeholder deskripsi sukses akademik"
	},
	GameConstants.Ending.PEMALAS: {
		"judul": "Ending: Si Pemalas",
		"desc":  "placeholder deskripsi pemalas"
	},
	GameConstants.Ending.SUKSES_PASSION: {
		"judul": "Ending: Sukses Passion",
		"desc":  "placeholder deskripsi sukses passion"
	},
	GameConstants.Ending.MEMBERONTAK: {
		"judul": "Ending: Memberontak",
		"desc":  "placeholder deskripsi memberontak"
	},
	GameConstants.Ending.DEPRESI: {
		"judul": "Ending: Depresi",
		"desc":  "placeholder deskripsi depresi"
	},
}

func _ready() -> void:
	btn_menu.text = "Kembali ke Menu"
	btn_menu.pressed.connect(_on_kembali)

	# Ambil ending dari GameState via signal game_over
	GameState.game_over.connect(_tampilkan_ending)

func _tampilkan_ending(ending: int) -> void:
	var data: Dictionary = ENDING_DATA.get(ending, {
		"judul": "Ending",
		"desc":  "Cerita telah berakhir."
	})
	label_judul.text = data["judul"]
	label_desc.text  = data["desc"]
	print("[EndingScreen] Ending: ", ending, " | ", data["judul"])

func _on_kembali() -> void:
	get_tree().change_scene_to_file("res://Scene/MainMenu.tscn")
