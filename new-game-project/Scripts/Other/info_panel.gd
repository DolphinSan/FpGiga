extends Panel

@onready var label_hari:       Label = $Hari
@onready var label_latar:      Label = $"Latar Waktu"
@onready var label_ap:         Label = $"Action Point"
@onready var label_mood:       Label = $Mood
@onready var label_mental:     Label = $Mental
@onready var label_sakit:      Label = $Sakit
@onready var label_akademik:   Label = $VBoxContainer/Akademik
@onready var label_tgg_jawab:  Label = $VBoxContainer/"Tgg Jawab"
@onready var label_passion:    Label = $VBoxContainer/Passion
@onready var label_dimanjakan: Label = $VBoxContainer/Dimanjakan
@onready var label_tertekan:   Label = $VBoxContainer/Tertekan
@onready var label_kemalasan:  Label = $VBoxContainer/Kemalasan

# Urutan reveal berdasarkan bicara_count
# key = bicara_count minimum untuk terlihat
const REVEAL_ORDER := {
	1: "mood",
	2: "mental",
	3: "akademik",
	4: "tgg_jawab",
	5: "passion",
	6: "dimanjakan",
	7: "tertekan",
	8: "kemalasan",
}

func _ready() -> void:
	GameState.ap_changed.connect(func(_v): _update())
	GameState.mood_changed.connect(func(_v): _update())
	GameState.mental_changed.connect(func(_v): _update())
	GameState.latar_changed.connect(func(_v): _update())
	GameState.hari_changed.connect(func(_h, _f): _update())
	GameState.anak_sakit_changed.connect(func(_v): _update())
	GameState.bicara_changed.connect(func(_v): _update())
	_update()

func _update() -> void:
	var bc := GameState.bicara_count

	# Selalu terlihat
	label_hari.text  = "HARI KE - %d        %s" % [GameState.hari, _latar_str()]
	label_ap.text    = "ACTION POINT - %d" % GameState.action_point

	# Sakit — khusus, pakai sakit_diketahui
	label_sakit.text    = "ANAK SAKIT" if GameState.sakit_diketahui else ""
	label_sakit.visible = GameState.sakit_diketahui

	# Stats dengan reveal progresif
	label_mood.text       = "MOOD - %s"          % (_mood_str()   if bc >= 1 else "???")
	label_mental.text     = "MENTAL - %s"         % (_mental_str() if bc >= 2 else "???")
	label_akademik.text   = "AKADEMIK - %s"       % (str(GameState.point_akademik)       if bc >= 3 else "???")
	label_tgg_jawab.text  = "TANGGUNG JAWAB - %s" % (str(GameState.point_tanggung_jawab) if bc >= 4 else "???")
	label_passion.text    = "PASSION - %s"        % (str(GameState.point_passion)        if bc >= 5 else "???")
	label_dimanjakan.text = "DIMANJAKAN - %s"     % (str(GameState.point_dimanjakan)     if bc >= 6 else "??")
	label_tertekan.text   = "TERTEKAN - %s"       % (str(GameState.point_tertekan)       if bc >= 7 else "???")
	label_kemalasan.text  = "KEMALASAN - %s"      % (str(GameState.point_kemalasan)      if bc >= 8 else "???")

func _mood_str() -> String:
	match GameState.mood:
		GameConstants.Mood.AWFUL: return "AWFUL"
		GameConstants.Mood.BAD:   return "BAD"
		GameConstants.Mood.BIASA: return "BIASA"
		GameConstants.Mood.GOOD:  return "GOOD"
		GameConstants.Mood.GREAT: return "GREAT"
	return "?"

func _mental_str() -> String:
	match GameState.mental:
		GameConstants.Mental.RUSAK:        return "RUSAK"
		GameConstants.Mental.BIASA:        return "BIASA"
		GameConstants.Mental.SANGAT_SEHAT: return "SEHAT"
	return "?"

func _latar_str() -> String:
	match GameState.latar:
		GameConstants.Waktu.PAGI:  return "PAGI"
		GameConstants.Waktu.SIANG: return "SIANG"
		GameConstants.Waktu.MALAM: return "MALAM"
	return "?"
