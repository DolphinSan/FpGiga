extends Node
# TimeManager — mengurus alur latar waktu, hari, dan fase.

func next_latar() -> void:
	GameState.aksi_terakhir = GameConstants.Aksi.NONE

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
	_check_sakit_duration()

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
		if not GameState.unlocked_endings.has(ending):
			GameState.unlocked_endings.append(ending)

		GameState.current_ending = ending
		GameState.emit_signal("game_over", ending)
		
		SaveSystem.save_global()
		SaveSystem.auto_save()
		
		if GameState.current_save_slot != -1:
			SaveSystem.delete_slot(GameState.current_save_slot)

		get_tree().change_scene_to_file("res://Scene/Ending.tscn")


func _check_sakit_duration() -> void:
	if not GameState.anak_sakit:
		GameState.hari_sakit = 0
		return

	GameState.hari_sakit += 1
	print("[TimeManager] Hari sakit: %d" % GameState.hari_sakit)

	if GameState.hari_sakit >= 7:
		print("[TimeManager] ⚠ Sakit terlalu lama — mood & mental drop!")
		GameState.mood   = GameConstants.Mood.AWFUL
		GameState.mental = GameConstants.Mental.RUSAK
		GameState.emit_signal("mood_changed",   GameState.mood)
		GameState.emit_signal("mental_changed", GameState.mental)


func _reset_daily_counters() -> void:
	for key in GameState.streak:
		GameState.streak[key]["today"] = 0


func _apply_mood_ap_penalty() -> void:
	match GameState.mood:
		GameConstants.Mood.BAD:
			GameState.action_point = max(0, GameState.action_point - 1)
		GameConstants.Mood.AWFUL:
			GameState.action_point = max(0, GameState.action_point - 2)
	GameState.emit_signal("ap_changed", GameState.action_point)


func is_minggu_pertama() -> bool:
	return GameState.hari <= 7

func is_waktu_lomba() -> bool:
	return GameState.hari > 5 and GameState.is_hari_libur
