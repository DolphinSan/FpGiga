extends Node2D

@onready var bg:            TextureRect = $Ending
@onready var label_speaker: Label       = $Panel/Label
@onready var label_teks:    Label       = $Panel/Label2
@onready var btn_1:         Button      = $Panel/VBoxContainer/Button
@onready var btn_2:         Button      = $Panel/VBoxContainer/Button2

var DIALOG: Array = []
var _index: int   = 0
var _fase_pilihan: bool = false

func _ready() -> void:
	print("[TrueEnding] bg node: ", bg)
	var gender := GameState.parent_gender

	DIALOG = [
		{
			"image":   "res://Asset/Ending/True/S935_1.png",
			"speaker": "Narator",
			"teks":    "Kamu merawatnya dari kecil",
			"pilihan": false
		},
		{
			"image":   "res://Asset/Ending/True/S935_1.png",
			"speaker": "Anak",
			"teks":    "%s dengar~~ aku punya teman baru disekolah hihi~" % gender,
			"pilihan": false
		},
		{   
			"image":   "res://Asset/Ending/True/S935_1.png",
			"speaker": "Anak",
			"teks":    "kenapa kamu menangis %s ?" % gender,
			"pilihan": true,
			"btn1":    "ini cuma air hujan",
			"btn2":    "%s sendiri tidak tahu..." % gender,
		},
		{
			"image":   "res://Asset/Ending/True/S935_2.png",
			"speaker": "Anak",
			"teks":    "%s, apakah kau benar benar menyangi ku?" % gender,
			"pilihan": false
		},
		{
			"image":   "res://Asset/Ending/True/S935_2.png",
			"speaker": "Anak",
			"teks":    "Mendengar cerita temanku, aku kadang berfikir apakah cintamu palsu",
			"pilihan": true,
			"btn1":    "....",
			"btn2":    "Tentu saja tidak, aku kan %s mu" % gender,
		},
		{
			"image":   "res://Asset/Ending/True/S935_3.png",
			"speaker": "Narator",
			"teks":    "kamu mengantarnya, untuk pertamakali jauh darimu",
			"pilihan": false
		},
		{
			"image":   "res://Asset/Ending/True/S935_3.png",
			"speaker": "Narator",
			"teks":    "Namun kamu tidak bersedih, karena ini bukan perpisahan",
			"pilihan": false
		},
	]

	_tampilkan(_index)

func _tampilkan(i: int) -> void:
	var d: Dictionary = DIALOG[i]

	var path: String = d.get("image", "")
	if path != "" and ResourceLoader.exists(path):
		bg.texture = load(path)

	label_speaker.text = d.get("speaker", "")
	label_teks.text    = d.get("teks", "")

	# Putus koneksi agar tidak double-click
	if btn_1.pressed.is_connected(_next):
		btn_1.pressed.disconnect(_next)
	if btn_2.pressed.is_connected(_next):
		btn_2.pressed.disconnect(_next)
	if btn_1.pressed.is_connected(_pilih_1):
		btn_1.pressed.disconnect(_pilih_1)
	if btn_2.pressed.is_connected(_pilih_2):
		btn_2.pressed.disconnect(_pilih_2)

	if d.get("pilihan", false):
		_fase_pilihan    = true
		btn_1.text       = d.get("btn1", "...")
		btn_2.text       = d.get("btn2", "...")
		btn_1.visible    = true
		btn_2.visible    = true
		btn_1.pressed.connect(_pilih_1)
		btn_2.pressed.connect(_pilih_2)
	else:
		_fase_pilihan    = false
		btn_1.text       = "Lanjut"
		btn_2.visible    = false   
		btn_1.pressed.connect(_next)

	print("[TrueEnding] Dialog %d | pilihan: %s" % [i, str(d.get("pilihan", false))])

func _next() -> void:
	_index += 1
	if _index >= DIALOG.size():
		_selesai()
		return
	_tampilkan(_index)

func _pilih_1() -> void:
	_next()

func _pilih_2() -> void:
	_next()

func _selesai() -> void:
	print("[TrueEnding] Ending selesai — kembali ke main menu")
	get_tree().change_scene_to_file("res://Scene/MainMenu.tscn")
