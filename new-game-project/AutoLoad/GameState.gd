extends Node
# Signals
signal mood_changed(new_mood: int)
signal mental_changed(new_mental: int)
signal ap_changed(remaining: int)
signal hari_changed(hari: int, fase: int)
signal latar_changed(latar: int)
signal anak_sakit_changed(sakit: bool)
signal game_over(ending: int)

# Waktu & Fase 
var fase: int = 1   # SD(1) SMP (2) SMA (3)
var hari: int           = 1
var hari_max: int       = 14
var latar: int          = GameConstants.Waktu.PAGI
var action_point: int   = GameConstants.AP_PAGI
var is_hari_libur: bool = false

# Orang Tua
var parent_gender: String = "ayah"
var parent_name: String   = ""

# Anak
var child_name: String   = ""
var child_gender: String = "Perempuan"

var mood: int = 2   # BIASA
var mental: int = GameConstants.Mental.BIASA

var anak_sakit: bool    = false
var mental_capped: bool = false   # true = mental tidak bisa melebihi biasa selamanya

# Stat Anak
var passion: int            = GameConstants.Passion.BELUM_DIKETAHUI
var passion_clue_level: int = 0   # 0–3

var point_akademik: int       = 0
var point_tanggung_jawab: int = 0
var point_passion: int        = 0
var point_dimanjakan: int     = 0
var point_tertekan: int       = 0
var point_kemalasan: int      = 0

#Chain & Streak (diisi oleh ActionManager)
var aksi_terakhir: int = GameConstants.Aksi.NONE

var streak: Dictionary = {}

# Lomba
var lomba_terdaftar: bool     = false
var lomba_cabang: int         = GameConstants.Passion.BELUM_DIKETAHUI
var lomba_sudah_selesai: bool = false
var lomba_hasil_menang: bool  = false

# RandomEvent
var random_events_triggered: Array[String] = []

func _ready() -> void:
	_init_streak()

func _init_streak() -> void:
	streak = {
		GameConstants.Aksi.NURTURE_2: { "today": 0, "streak": 0 },
		GameConstants.Aksi.NURTURE_3: { "today": 0, "streak": 0 },
		GameConstants.Aksi.NURTURE_4: { "today": 0, "streak": 0 },
		GameConstants.Aksi.NURTURE_5: { "today": 0, "streak": 0 },
		GameConstants.Aksi.REST:      { "today": 0, "streak": 0 },
	}
	
# Reset

func reset_new_game() -> void:
	fase          = GameConstants.Fase.SD
	hari          = 1
	hari_max      = 14
	latar         = GameConstants.Waktu.PAGI
	action_point  = GameConstants.AP_PAGI
	is_hari_libur = false

	mood          = GameConstants.Mood.BIASA
	mental        = GameConstants.Mental.BIASA
	anak_sakit    = false
	mental_capped = false

	passion            = GameConstants.Passion.BELUM_DIKETAHUI
	passion_clue_level = 0

	point_akademik       = 0
	point_tanggung_jawab = 0
	point_passion        = 0
	point_dimanjakan     = 0
	point_tertekan       = 0
	point_kemalasan      = 0

	aksi_terakhir = GameConstants.Aksi.NONE
	_reset_streak()

	lomba_terdaftar     = false
	lomba_cabang        = GameConstants.Passion.BELUM_DIKETAHUI
	lomba_sudah_selesai = false
	lomba_hasil_menang  = false

	random_events_triggered.clear()


func _reset_streak() -> void:
	for key in streak:
		streak[key]["today"]  = 0
		streak[key]["streak"] = 0

func add_mood(delta: int) -> void:
	mood = clamp(mood + delta, GameConstants.Mood.AWFUL, GameConstants.Mood.GREAT)
	emit_signal("mood_changed", mood)


func add_mental(delta: int) -> void:
	var cap := GameConstants.Mental.BIASA if mental_capped else GameConstants.Mental.SANGAT_SEHAT
	mental = clamp(mental + delta, GameConstants.Mental.RUSAK, cap)
	emit_signal("mental_changed", mental)


func get_mood_multiplier() -> float:
	match mood:
		GameConstants.Mood.GREAT: return 1.5
		GameConstants.Mood.GOOD:  return 1.25
		_: return 1.0



func to_dict() -> Dictionary:
	return {
		"fase": fase, "hari": hari, "hari_max": hari_max,
		"latar": latar, "action_point": action_point,
		"is_hari_libur": is_hari_libur,
		"parent_gender": parent_gender, "parent_name": parent_name,
		"child_name": child_name, "child_gender": child_gender,
		"mood": mood, "mental": mental,
		"anak_sakit": anak_sakit, "mental_capped": mental_capped,
		"passion": passion, "passion_clue_level": passion_clue_level,
		"point_akademik": point_akademik,
		"point_tanggung_jawab": point_tanggung_jawab,
		"point_passion": point_passion,
		"point_dimanjakan": point_dimanjakan,
		"point_tertekan": point_tertekan,
		"point_kemalasan": point_kemalasan,
		"aksi_terakhir": aksi_terakhir,
		"streak": streak,
		"lomba_terdaftar": lomba_terdaftar,
		"lomba_cabang": lomba_cabang,
		"lomba_sudah_selesai": lomba_sudah_selesai,
		"lomba_hasil_menang": lomba_hasil_menang,
		"random_events_triggered": random_events_triggered,
	}


func from_dict(d: Dictionary) -> void:
	fase          = d.get("fase",          GameConstants.Fase.SD)
	hari          = d.get("hari",          1)
	hari_max      = d.get("hari_max",      14)
	latar         = d.get("latar",         GameConstants.Waktu.PAGI)
	action_point  = d.get("action_point",  GameConstants.AP_PAGI)
	is_hari_libur = d.get("is_hari_libur", false)

	parent_gender = d.get("parent_gender", "ayah")
	parent_name   = d.get("parent_name",   "")
	child_name    = d.get("child_name",    "")
	child_gender  = d.get("child_gender",  "x")

	mood          = d.get("mood",          GameConstants.Mood.BIASA)
	mental        = d.get("mental",        GameConstants.Mental.BIASA)
	anak_sakit    = d.get("anak_sakit",    false)
	mental_capped = d.get("mental_capped", false)

	passion            = d.get("passion",            GameConstants.Passion.BELUM_DIKETAHUI)
	passion_clue_level = d.get("passion_clue_level", 0)

	point_akademik       = d.get("point_akademik",       0)
	point_tanggung_jawab = d.get("point_tanggung_jawab", 0)
	point_passion        = d.get("point_passion",        0)
	point_dimanjakan     = d.get("point_dimanjakan",     0)
	point_tertekan       = d.get("point_tertekan",       0)
	point_kemalasan      = d.get("point_kemalasan",      0)

	aksi_terakhir = d.get("aksi_terakhir", GameConstants.Aksi.NONE)
	streak        = d.get("streak",        streak)

	lomba_terdaftar     = d.get("lomba_terdaftar",     false)
	lomba_cabang        = d.get("lomba_cabang",        GameConstants.Passion.BELUM_DIKETAHUI)
	lomba_sudah_selesai = d.get("lomba_sudah_selesai", false)
	lomba_hasil_menang  = d.get("lomba_hasil_menang",  false)

	random_events_triggered = d.get("random_events_triggered", [])
