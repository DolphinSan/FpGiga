extends CanvasLayer

signal pilihan_dipilih(event: Dictionary, pilihan_index: int)

@onready var label_speaker: Label   = $Panel/Label
@onready var label_teks: Label      = $Panel/Label2
@onready var btn_container          = $Panel/VBoxContainer
@onready var btn_pilihan1: Button   = $Panel/VBoxContainer/Button
@onready var btn_pilihan2: Button   = $Panel/VBoxContainer/Button2

var _event_aktif: Dictionary = {}
var _dialogs: Array          = []
var _dialog_index: int       = 0
var _fase_pilihan: bool      = false   # false = dialog, true = pilihan

# Setup
func setup(event: Dictionary) -> void:
	_event_aktif = event
	_dialogs     = event.get("dialog", [])
	_dialog_index = 0
	_fase_pilihan = false

	btn_container.visible = false

	if _dialogs.is_empty():
		# Tidak ada dialog — langsung ke pilihan
		_tampilkan_pilihan()
	else:
		_tampilkan_dialog()

# Dialog
func _tampilkan_dialog() -> void:
	if _dialog_index >= _dialogs.size():
		_tampilkan_pilihan()
		return

	var d: Dictionary      = _dialogs[_dialog_index]
	label_speaker.text     = d.get("speaker", "")
	label_teks.text        = d.get("teks", "")
	print("[EventPopup] Dialog %d: [%s] %s" % [_dialog_index, label_speaker.text, label_teks.text])

func _input(event: InputEvent) -> void:
	if _fase_pilihan:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_dialog_index += 1
		_tampilkan_dialog()
		get_viewport().set_input_as_handled()

# Pilihan
func _tampilkan_pilihan() -> void:
	_fase_pilihan      = true
	label_speaker.text = "Kamu"
	label_teks.text    = "Apa yang akan kamu lakukan?"
	btn_container.visible = true

	var pilihan: Array = _event_aktif.get("pilihan", [])
	btn_pilihan1.text  = pilihan[0]["teks"] if pilihan.size() > 0 else ""
	btn_pilihan2.text  = pilihan[1]["teks"] if pilihan.size() > 1 else ""

	btn_pilihan1.pressed.connect(_on_pilih.bind(0))
	btn_pilihan2.pressed.connect(_on_pilih.bind(1))
	print("[EventPopup] Fase pilihan dimulai")

func _on_pilih(index: int) -> void:
	print("[EventPopup] Pilihan: ", index)
	RandomEventManager.resolve_event(_event_aktif, index)
	emit_signal("pilihan_dipilih", _event_aktif, index)
	queue_free()
