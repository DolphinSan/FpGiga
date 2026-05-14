extends CanvasLayer

const KODE := [
	KEY_DOWN, KEY_RIGHT, KEY_UP, KEY_UP, KEY_UP
]

@onready var panel: Panel = $Panel
@onready var btns         = $Panel/VBoxContainer

var _input_buffer: Array[int] = []

func _ready() -> void:
	panel.visible = false

	var labels := [
		"Skip Fase",
		"Skip ke Hari Libur",
		"Buat Sakit",
		"Munculkan Random Event",
		"+10 Akademik",
		"+10 Tgg Jawab",
		"+10 Passion",
		"+10 Dimanjakan",
		"+10 Tertekan",
		"+10 Kemalasan",
	]
	var fungsi := [
		_on_skip_fase,
		_on_skip_libur,
		_on_buat_sakit,
		_on_random_event,
		_on_tambah_akademik,
		_on_tambah_tgg_jawab,
		_on_tambah_passion,
		_on_tambah_dimanjakan,
		_on_tambah_tertekan,
		_on_tambah_kemalasan,
	]

	var children := btns.get_children()
	for i in children.size():
		if i < labels.size():
			children[i].text = labels[i]
			children[i].pressed.connect(fungsi[i])

func _input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed:
		return

	if event.keycode == KEY_ESCAPE and panel.visible:
		panel.visible = false
		return

	_input_buffer.append(event.keycode)
	if _input_buffer.size() > KODE.size():
		_input_buffer.pop_front()

	if _input_buffer == KODE:
		panel.visible = not panel.visible
		print("[DebugCheat] Panel toggled: ", panel.visible)
		_input_buffer.clear()

# Aksi
func _on_skip_fase() -> void:
	if GameState.fase < GameConstants.Fase.SMA:
		GameState.fase += 1
		GameState.hari  = 1
		GameState.emit_signal("hari_changed", GameState.hari, GameState.fase)
		print("[DebugCheat] Skip ke Fase: ", GameState.fase)

func _on_skip_libur() -> void:
	# Cari hari libur berikutnya dari hari saat ini
	var next_hari := GameState.hari + 1
	while next_hari <= GameState.hari_max:
		var dow := ((next_hari - 1) % 7) + 1
		if dow >= 6:
			break
		next_hari += 1

	if next_hari > GameState.hari_max:
		print("[DebugCheat] Tidak ada hari libur lagi di fase ini")
		return

	GameState.hari          = next_hari
	GameState.is_hari_libur = true
	GameState.latar         = GameConstants.Waktu.PAGI
	GameState.action_point  = GameConstants.AP_PAGI
	GameState.emit_signal("hari_changed", GameState.hari, GameState.fase)
	GameState.emit_signal("latar_changed", GameState.latar)
	GameState.emit_signal("ap_changed",    GameState.action_point)
	print("[DebugCheat] Skip ke hari libur: hari ", GameState.hari)

func _on_buat_sakit() -> void:
	GameState.anak_sakit      = true
	GameState.sakit_diketahui = false
	GameState.hari_sakit      = 0
	print("[DebugCheat] Anak dibuat sakit (tersembunyi)")

func _on_random_event() -> void:
	var result: Array = []
	for event in RandomEventManager._all_events:
		var fase_list: Array = event.get("fase", [])
		var fase_int: Array  = fase_list.map(func(f): return int(f))
		if GameState.fase in fase_int:
			result.append(event)
	if result.is_empty():
		print("[DebugCheat] Tidak ada event tersedia")
		return
	var event: Dictionary = result[randi() % result.size()]
	print("[DebugCheat] Trigger event: ", event["id"])
	RandomEventManager.emit_signal("event_triggered", event)

func _on_tambah_akademik()   -> void: GameState.point_akademik       += 10; _log("Akademik",   GameState.point_akademik)
func _on_tambah_tgg_jawab()  -> void: GameState.point_tanggung_jawab += 10; _log("TggJawab",   GameState.point_tanggung_jawab)
func _on_tambah_passion()    -> void: GameState.point_passion        += 10; _log("Passion",    GameState.point_passion)
func _on_tambah_dimanjakan() -> void: GameState.point_dimanjakan     += 10; _log("Dimanjakan", GameState.point_dimanjakan)
func _on_tambah_tertekan()   -> void: GameState.point_tertekan       += 10; _log("Tertekan",   GameState.point_tertekan)
func _on_tambah_kemalasan()  -> void: GameState.point_kemalasan      += 10; _log("Kemalasan",  GameState.point_kemalasan)

func _log(nama: String, val: int) -> void:
	print("[DebugCheat] +10 %s → %d" % [nama, val])
