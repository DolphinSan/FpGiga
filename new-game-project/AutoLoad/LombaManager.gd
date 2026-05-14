extends Node
#  LombaManager, logika pendaftaran & eksekusi lomba.
# Dipanggil saat pemain memilih cabang lomba di minggu 1
func daftar_lomba(cabang: int) -> void:
	GameState.lomba_terdaftar = true
	GameState.lomba_cabang    = cabang

# Dipanggil otomatis di minggu 2 (Sabtu/Minggu)
# Kembalikan Dictionary hasil untuk ditampilkan UI
func jalankan_lomba() -> Dictionary:
	var cabang    := GameState.lomba_cabang
	var passion   := GameState.passion
	var sakit     := GameState.anak_sakit

	var sesuai    := (cabang == GameConstants.Passion.MUSIK) # sementara begini dulu aja karena gaada sprite yang cocok (GW NYARI SENDIRI ANJ)
	var result    := { "menang": false, "kasus": "" }

	if not sesuai and sakit:
		result["kasus"] = "worst"          # salah cabang + sakit
		_apply_worst()

	elif not sesuai:
		result["kasus"] = "wrong_passion"  # hanya salah cabang
		_apply_wrong_passion()

	elif sakit:
		result["kasus"] = "sick"           # benar tapi sakit
		result["menang"] = _roll_win(0.40)
		_apply_sick_loss(result["menang"])

	else:
		result["kasus"] = "normal"
		result["menang"] = _roll_win(0.75)

	# Tambah point passion
	if result["menang"]:
		GameState.point_passion += 20
		_apply_win_bonus()
	elif result["kasus"] in ["normal", "sick"]:
		GameState.point_passion += 5   # gagal tapi tetap usaha

	GameState.lomba_hasil_menang  = result["menang"]
	GameState.lomba_sudah_selesai = true
	return result


# Efek

func _apply_worst() -> void:
	# Salah cabang + sakit: mental di-cap ke BIASA selamanya
	GameState.add_mood(-2)
	GameState.mental_capped = true
	GameState.mental = min(GameState.mental, GameConstants.Mental.BIASA)
	GameState.emit_signal("mental_changed", GameState.mental)


func _apply_wrong_passion() -> void:
	GameState.add_mood(-1)
	GameState.add_mental(-1)


func _apply_sick_loss(menang: bool) -> void:
	if not menang:
		GameState.add_mood(-1)
		GameState.add_mental(-1)


func _roll_win(chance: float) -> bool:
	return randf() <= chance


# Random Event Khusus: Anak Sakit Sehari Sebelum Lomba 

# Dipanggil UI saat pemain memilih "Tetap Ikut" atau "Istirahat"
func handle_sakit_sebelum_lomba(tetap_ikut: bool) -> void:
	if tetap_ikut:
		# Risiko: mental turun + kemungkinan gagal lebih besar
		GameState.add_mental(-1)
	else:
		# Aman: anak tidak ikut, mental terjaga
		GameState.lomba_terdaftar     = false
		GameState.lomba_sudah_selesai = true
		GameState.lomba_hasil_menang  = false

func _apply_win_bonus() -> void:
	var bonus_passion   := int(GameState.point_passion        * 0.20)
	var bonus_akademik  := int(GameState.point_akademik       * 0.20)
	var bonus_tgg_jawab := int(GameState.point_tanggung_jawab * 0.20)

	# Minimal bonus 1 agar tetap terasa
	GameState.point_passion        += max(1, bonus_passion)
	GameState.point_akademik       += max(1, bonus_akademik)
	GameState.point_tanggung_jawab += max(1, bonus_tgg_jawab)

	print("[LombaManager] Bonus menang → passion +%d | akademik +%d | tgg_jawab +%d" % [
		max(1, bonus_passion),
		max(1, bonus_akademik),
		max(1, bonus_tgg_jawab)
	])
