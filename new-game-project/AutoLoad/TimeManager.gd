extends Node
#  TimeManager, mengurus alur latar waktu, hari, dan fase.

# Maju ke latar berikutnya. Dipanggil UI saat AP habis
# atau pemain menekan tombol "Lanjut".
func next_latar() -> void:
	GameState.aksi_terakhir = GameConstants.Aksi.NONE   # reset chain tracker

	if GameState.is_hari_libur:
		match GameState.latar:
			GameConstants.Waktu.PAGI:
				_set_latar(GameConstants.Waktu.SIANG, GameConstants.AP_SIANG)
			GameConstants.Waktu.SIANG:
				_set_latar(GameConstants.Waktu.MALAM, GameConstants.AP_MALAM)
			GameConstants.Waktu.MALAM:
				_advance_hari()
	else:
		match GameState.latar:
			GameConstants.Waktu.PAGI:
				_set_latar(GameConstants.Waktu.MALAM, GameConstants.AP_MALAM)
			GameConstants.Waktu.MALAM:
				_advance_hari()

	_apply_mood_ap_penalty()


func _set_latar(waktu: int, ap: int) -> void:
	GameState.latar        = waktu
	GameState.action_point = ap
	GameState.emit_signal("latar_changed", waktu)
	GameState.emit_signal("ap_changed", ap)


func _advance_hari() -> void:
	ActionManager.evaluate_daily_streaks()

	GameState.hari += 1
	if GameState.hari > GameState.hari_max:
		_advance_fase()
		return

	var dow := ((GameState.hari - 1) % 7) + 1
	GameState.is_hari_libur = (dow >= 6)

	_set_latar(GameConstants.Waktu.PAGI, GameConstants.AP_PAGI)
	_reset_daily_counters()
	GameState.emit_signal("hari_changed", GameState.hari, GameState.fase) 
	
func _advance_fase() -> void:
	if GameState.fase < GameConstants.Fase.SMA:
		GameState.fase       += 1
		GameState.hari        = 1
		GameState.is_hari_libur = false
		_set_latar(GameConstants.Waktu.PAGI, GameConstants.AP_PAGI)
		_reset_daily_counters()
		GameState.emit_signal("hari_changed", GameState.hari, GameState.fase)
	else:
		var ending := EndingManager.calculate()
		GameState.emit_signal("game_over", ending)


func _reset_daily_counters() -> void:
	for key in GameState.streak:
		GameState.streak[key]["today"] = 0


# Penalti AP akibat mood buruk — dipanggil tiap ganti latar
func _apply_mood_ap_penalty() -> void:
	match GameState.mood:
		GameConstants.Mood.BAD:
			GameState.action_point = max(0, GameState.action_point - 1)
		GameConstants.Mood.AWFUL:
			GameState.action_point = max(0, GameState.action_point - 2)
	GameState.emit_signal("ap_changed", GameState.action_point)


# Cek apakah hari ini adalah minggu pertama fase (untuk buka pendaftaran lomba)
func is_minggu_pertama() -> bool:
	return GameState.hari <= 7


# Cek apakah sekarang waktu lomba (Sabtu/Minggu minggu kedua)
func is_waktu_lomba() -> bool:
	return GameState.hari > 7 and GameState.is_hari_libur
