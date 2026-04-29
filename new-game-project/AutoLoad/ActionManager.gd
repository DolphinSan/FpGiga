extends Node
#  ActionManager, eksekusi aksi pemain + streak tracker

# Kembalikan false jika AP tidak cukup
func execute(aksi: int) -> bool:
	if not _use_ap(aksi):
		return false

	_track_streak(aksi)

	match aksi:
		GameConstants.Aksi.NURTURE_1: _nurture1()
		GameConstants.Aksi.NURTURE_2: _nurture2()
		GameConstants.Aksi.NURTURE_3: _nurture3()
		GameConstants.Aksi.NURTURE_4: _nurture4()
		GameConstants.Aksi.NURTURE_5: _nurture5()
		GameConstants.Aksi.REST:       _rest()
		GameConstants.Aksi.RECREATION: _recreation()
		GameConstants.Aksi.INFIRMARY:  _infirmary()

	GameState.aksi_terakhir = aksi
	return true


func can_execute(aksi: int) -> bool:
	# Validasi tambahan di luar AP
	match aksi:
		GameConstants.Aksi.INFIRMARY:
			# Hanya bisa jika anak terlihat sakit (setelah Nurture 1)
			return GameState.anak_sakit and _has_enough_ap(aksi)
		GameConstants.Aksi.RECREATION:
			return GameState.is_hari_libur and _has_enough_ap(aksi)
		GameConstants.Aksi.LOMBA:
			return GameState.lomba_terdaftar and TimeManager.is_waktu_lomba()
		_:
			return _has_enough_ap(aksi)

# Action Point

func _has_enough_ap(aksi: int) -> bool:
	return GameState.action_point >= _cost(aksi)


func _use_ap(aksi: int) -> bool:
	if not _has_enough_ap(aksi):
		return false
	GameState.action_point -= _cost(aksi)
	GameState.emit_signal("ap_changed", GameState.action_point)
	return true


func _cost(aksi: int) -> int:
	if aksi in [GameConstants.Aksi.INFIRMARY, GameConstants.Aksi.RECREATION]:
		return GameConstants.AP_COST_SPECIAL
	return GameConstants.AP_COST_DEFAULT

# Nurture 1, Ajak Berbicara 

func _nurture1() -> void:
	# Ungkap clue passion lebih dalam setiap kali dipakai
	if GameState.passion != GameConstants.Passion.BELUM_DIKETAHUI:
		GameState.passion_clue_level = min(GameState.passion_clue_level + 1, 3)

	# Chain: jika mental rusak > perbaiki sedikit
	if GameState.mental == GameConstants.Mental.RUSAK:
		GameState.add_mental(1)

	# UI harus membaca GameState.anak_sakit setelah aksi ini
	# untuk menampilkan opsi Infirmary

# Nurture 2, Beri Hadiah

func _nurture2() -> void:
	if _prev_was_task():
		# Chain bonus: sesudah belajar/bersih
		GameState.add_mood(2)
		GameState.add_mental(1)
	else:
		GameState.add_mood(1)

# Nurture 3, Beri Perhatian

func _nurture3() -> void:
	if _prev_was_task():
		# Chain: sama seperti Nurture 2
		GameState.add_mood(2)
		GameState.add_mental(1)
	else:
		# Lebih kecil dari N2
		GameState.add_mood(1)

	# Bonus: perbaiki mental jika rusak (lebih besar dari N1)
	if GameState.mental == GameConstants.Mental.RUSAK:
		GameState.add_mental(2)

# Nurture 4, Suruh Belajar

func _nurture4() -> void:
	var m := GameState.get_mood_multiplier()
	GameState.point_akademik       += int(1 * m)
	GameState.point_tanggung_jawab += int(1 * m)

# Nurture 5 Suruh Bersih-Bersih 

func _nurture5() -> void:
	var m := GameState.get_mood_multiplier()
	# Tanggung jawab lebih kecil dari N4
	GameState.point_tanggung_jawab += max(1, int(0.75 * m))

# Rest

func _rest() -> void:
	# Chain: sembuhkan jika anak tidak enak badan (bukan parah)
	if GameState.anak_sakit and GameState.mental > GameConstants.Mental.RUSAK:
		GameState.anak_sakit = false
		GameState.emit_signal("anak_sakit_changed", false)
	# Efek normal: netral

# Recreation

func _recreation() -> void:
	if _prev_was_task():
		# Chain bonus
		GameState.add_mood(2)
		GameState.add_mental(1)
	else:
		# Mood lebih besar dari N2
		GameState.add_mood(2)

# Infirmary

func _infirmary() -> void:
	GameState.anak_sakit = false
	GameState.emit_signal("anak_sakit_changed", false)

#  STREAK TRACKER

func _track_streak(aksi: int) -> void:
	if GameState.streak.has(aksi):
		GameState.streak[aksi]["today"] += 1


# Dipanggil oleh TimeManager setiap akhir hari
func evaluate_daily_streaks() -> void:
	for aksi in GameState.streak:
		var data: Dictionary = GameState.streak[aksi]

		if data["today"] >= 2:
			data["streak"] += 1
		else:
			data["streak"] = 0

		if data["streak"] >= GameConstants.BAD_STREAK_DAYS:
			_apply_bad_effect(aksi)
			data["streak"] = 0


func _apply_bad_effect(aksi: int) -> void:
	match aksi:
		GameConstants.Aksi.NURTURE_2:
			GameState.point_dimanjakan += 2
		GameConstants.Aksi.NURTURE_3:
			GameState.point_dimanjakan += 1   # lebih kecil dari N2
		GameConstants.Aksi.NURTURE_4:
			GameState.point_tertekan   += 2
			GameState.add_mood(-1)
			GameState.add_mental(-1)
		GameConstants.Aksi.NURTURE_5:
			GameState.point_tertekan   += 1   # lebih kecil dari N4
			GameState.add_mood(-1)
			GameState.add_mental(-1)
		GameConstants.Aksi.REST:
			GameState.point_kemalasan  += 2

# ── Helper ──────────────────────────────────────────────

func _prev_was_task() -> bool:
	return GameState.aksi_terakhir in [
		GameConstants.Aksi.NURTURE_4,
		GameConstants.Aksi.NURTURE_5
	]
