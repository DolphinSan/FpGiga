extends Control

signal slot_dipilih(slot: int)

@onready var label_judul: Label  = $Panel/LabelJudul
@onready var btn_slot0:   Button = $Panel/VBoxContainer/BtnSave
@onready var btn_slot1:   Button = $Panel/VBoxContainer/BtnSave2
@onready var btn_slot2:   Button = $Panel/VBoxContainer/BtnSave3
@onready var btn_back:    Button = $Panel/BtnBack

# Mode: "save" = simpan game | "new_game" = pilih slot untuk new game
var mode: String = "save"

func _ready() -> void:
	btn_slot0.pressed.connect(_on_slot.bind(0))
	btn_slot1.pressed.connect(_on_slot.bind(1))
	btn_slot2.pressed.connect(_on_slot.bind(2))
	btn_back.pressed.connect(_on_back)
	_refresh_slots()

func setup(p_mode: String) -> void:
	mode = p_mode
	label_judul.text = "PILIH SLOT" if mode == "save" else "PILIH SLOT"
	_refresh_slots()

func _refresh_slots() -> void:
	var slots := [btn_slot0, btn_slot1, btn_slot2]
	for i in slots.size():
		var info := SaveSystem.get_slot_info(i)
		if info.get("exists", false):
			slots[i].text = "SLOT %d  |  Fase %d  |  Hari %d\n%s" % [
				i + 1,
				info.get("fase", 0),
				info.get("hari", 0),
				info.get("saved_at", "")
			]
			slots[i].disabled = false
		else:
			slots[i].text     = "SLOT %d  |  — Kosong —" % (i + 1)
			slots[i].disabled = (mode == "load") 
			
func _on_slot(slot: int) -> void:
	if mode == "save":
		SaveSystem.save_game(slot)
		_refresh_slots()
	elif mode == "load":
		SaveSystem.load_game(slot)
		SaveSystem.load_completed.connect(func(_s):
			emit_signal("slot_dipilih", slot)
		, CONNECT_ONE_SHOT)
	elif mode == "new_game":
		GameState.reset_new_game()
		SaveSystem.save_game(slot)
		emit_signal("slot_dipilih", slot)
		
func _on_back() -> void:
	visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_back()
