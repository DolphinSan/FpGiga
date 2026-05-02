extends Node
# RandomEventManager — load event dari JSON, roll 20%, eksekusi efek.
# Autoload. Maksimal 1 event per hari.

signal event_triggered(event_data: Dictionary)

const EVENT_PATH  := "res://Data/events.json"
const CHANCE      := 0.20   # 20%

var _all_events: Array[Dictionary] = []
var _event_hari_ini: bool = false   # reset tiap hari

# Setup
func _ready() -> void:
	_load_events()
	GameState.hari_changed.connect(_on_hari_changed)

func _load_events() -> void:
	if not FileAccess.file_exists(EVENT_PATH):
		push_error("[RandomEventManager] events.json tidak ditemukan di: " + EVENT_PATH)
		return

	var file := FileAccess.open(EVENT_PATH, FileAccess.READ)
	var json  := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		push_error("[RandomEventManager] Gagal parse events.json")
		file.close()
		return
	file.close()

	var data = json.get_data()
	if data is Array:
		for item in data:
			_all_events.append(item)
	print("[RandomEventManager] Loaded %d events" % _all_events.size())

# Dipanggil TimeManager setiap ganti hari
func _on_hari_changed(_hari: int, _fase: int) -> void:
	_event_hari_ini = false

# Dipanggil dari luar (misal: DayScene) di awal setiap latar waktu
func try_trigger_event() -> void:
	if _event_hari_ini:
		print("[RandomEventManager] Sudah ada event hari ini, skip")
		return

	if randf() > CHANCE:
		print("[RandomEventManager] Roll gagal — tidak ada event")
		return

	var kandidat := _get_kandidat()
	if kandidat.is_empty():
		print("[RandomEventManager] Tidak ada event yang sesuai fase")
		return

	var event: Dictionary = kandidat[randi() % kandidat.size()]
	_event_hari_ini = true
	print("[RandomEventManager] Event triggered: ", event["id"])
	emit_signal("event_triggered", event)

# Filter event berdasarkan fase & belum pernah terjadi
func _get_kandidat() -> Array:
	var result := []
	for event in _all_events:
		var fase_list: Array = event.get("fase", [])
		if GameState.fase in fase_list:
			if not event["id"] in GameState.random_events_triggered:
				result.append(event)
	return result

# Eksekusi pilihan pemain (dipanggil UI setelah pemain memilih)
func resolve_event(event: Dictionary, pilihan_index: int) -> void:
	var pilihan: Dictionary = event["pilihan"][pilihan_index]
	print("[RandomEventManager] Resolve: ", event["id"], " | pilihan: ", pilihan_index)

	# Tambah point
	for stat in pilihan.get("point_tambah", []):
		_add_point(stat, 1)

	# Kurangi point
	for stat in pilihan.get("point_kurang", []):
		_add_point(stat, -1)

	# Mood & mental
	var mood_delta: int   = pilihan.get("mood", 0)
	var mental_delta: int = pilihan.get("mental", 0)
	if mood_delta != 0:
		GameState.add_mood(mood_delta)
	if mental_delta != 0:
		GameState.add_mental(mental_delta)

	# Catat event sudah pernah terjadi
	GameState.random_events_triggered.append(event["id"])

	print("[RandomEventManager] Selesai. Mood: %d | Mental: %d" % [GameState.mood, GameState.mental])

func _add_point(stat: String, delta: int) -> void:
	match stat:
		"akademik":       GameState.point_akademik       += delta
		"tanggung_jawab": GameState.point_tanggung_jawab += delta
		"passion":        GameState.point_passion        += delta
		"dimanjakan":     GameState.point_dimanjakan     += delta
		"tertekan":       GameState.point_tertekan       += delta
		"kemalasan":      GameState.point_kemalasan      += delta
	# Clamp agar tidak negatif
	GameState.point_akademik       = max(0, GameState.point_akademik)
	GameState.point_tanggung_jawab = max(0, GameState.point_tanggung_jawab)
	GameState.point_passion        = max(0, GameState.point_passion)
	GameState.point_dimanjakan     = max(0, GameState.point_dimanjakan)
	GameState.point_tertekan       = max(0, GameState.point_tertekan)
	GameState.point_kemalasan      = max(0, GameState.point_kemalasan)
