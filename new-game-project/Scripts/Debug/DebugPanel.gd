extends Label

func _process(_delta: float) -> void:
	text = (
		"── WAKTU ──────────────\n"
		+ "Hari   : %d | Fase: %d\n" % [GameState.hari, GameState.fase]
		+ "Latar  : %s | Libur: %s\n" % [_latar_str(), str(GameState.is_hari_libur)]
		+ "AP     : %d\n" % GameState.action_point
		+ "\n── KONDISI ────────────\n"
		+ "Mood   : %s\n" % _mood_str()
		+ "Mental : %s\n" % _mental_str()
		+ "Sakit  : %s\n" % str(GameState.anak_sakit)
		+ "\n── CHAIN ──────────────\n"
		+ "Aksi terakhir: %s\n" % _aksi_str(GameState.aksi_terakhir)
		+ "Chain aktif  : %s\n" % _chain_str()
		+ "\n── POINT ──────────────\n"
		+ "Akademik     : %d\n" % GameState.point_akademik
		+ "Tgg Jawab    : %d\n" % GameState.point_tanggung_jawab
		+ "Passion      : %d\n" % GameState.point_passion
		+ "Dimanjakan   : %d\n" % GameState.point_dimanjakan
		+ "Tertekan     : %d\n" % GameState.point_tertekan
		+ "Kemalasan    : %d\n" % GameState.point_kemalasan
		+ "\n── STREAK ─────────────\n"
		+ _streak_str()
	)

func _chain_str() -> String:
	var prev := GameState.aksi_terakhir
	if prev in [GameConstants.Aksi.NURTURE_4, GameConstants.Aksi.NURTURE_5]:
		return "✓ (N2/N3/Recreation dapat bonus)"
	return "✗"

func _streak_str() -> String:
	var result := ""
	var names := {
		GameConstants.Aksi.NURTURE_2: "BeriHadiah",
		GameConstants.Aksi.NURTURE_3: "BeriPerhatian",
		GameConstants.Aksi.NURTURE_4: "SuruhBelajar",
		GameConstants.Aksi.NURTURE_5: "BersihBersih",
		GameConstants.Aksi.REST:      "Rest",
	}
	for aksi in names:
		var data: Dictionary = GameState.streak.get(aksi, {"today": 0, "streak": 0})
		result += "%s: hari ini %dx | streak %d/%d\n" % [
			names[aksi],
			data.get("today", 0),
			data.get("streak", 0),
			GameConstants.BAD_STREAK_DAYS
		]
	return result

func _aksi_str(aksi: int) -> String:
	match aksi:
		GameConstants.Aksi.NONE:       return "None"
		GameConstants.Aksi.NURTURE_1:  return "AjakBerbicara"
		GameConstants.Aksi.NURTURE_2:  return "BeriHadiah"
		GameConstants.Aksi.NURTURE_3:  return "BeriPerhatian"
		GameConstants.Aksi.NURTURE_4:  return "SuruhBelajar"
		GameConstants.Aksi.NURTURE_5:  return "BersihBersih"
		GameConstants.Aksi.REST:       return "Rest"
		GameConstants.Aksi.RECREATION: return "Recreation"
		GameConstants.Aksi.INFIRMARY:  return "Infirmary"
		GameConstants.Aksi.LOMBA:      return "Lomba"
	return "?"

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
		GameConstants.Mental.SANGAT_SEHAT: return "SANGAT SEHAT"
	return "?"

func _latar_str() -> String:
	match GameState.latar:
		GameConstants.Waktu.PAGI:  return "PAGI"
		GameConstants.Waktu.SIANG: return "SIANG"
		GameConstants.Waktu.MALAM: return "MALAM"
	return "?"
