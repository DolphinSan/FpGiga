extends Node
#  EndingManager, menghitung ending berdasarkan semua stat.
#  Autoload. Hanya membaca GameState.

func calculate() -> int:
	# ── Depresi ─────────────────────────────────────────
	if GameState.mental == GameConstants.Mental.RUSAK and GameState.point_tertekan >= 15:
		return GameConstants.Ending.DEPRESI

	# ── Memberontak ─────────────────────────────────────
	if GameState.point_dimanjakan >= 15:
		return GameConstants.Ending.MEMBERONTAK
	if GameState.point_tertekan >= 12 and GameState.point_tanggung_jawab < 8:
		return GameConstants.Ending.MEMBERONTAK

	# ── Pemalas ─────────────────────────────────────────
	if GameState.point_kemalasan >= 15:
		return GameConstants.Ending.PEMALAS

	# ── True Ending — Mandiri & Bahagia ─────────────────
	var seimbang: bool = (
		GameState.point_tanggung_jawab >= 15
		and GameState.mental >= GameConstants.Mental.BIASA
		and GameState.point_dimanjakan < 8
		and GameState.point_tertekan   < 8
		and GameState.point_kemalasan  < 8
	)
	if seimbang:
		return GameConstants.Ending.MANDIRI_BAHAGIA

	# ── Sukses Passion ──────────────────────────────────
	if GameState.point_passion >= 10 and GameState.lomba_hasil_menang:
		return GameConstants.Ending.SUKSES_PASSION

	# ── Sukses Akademik ─────────────────────────────────
	if GameState.point_akademik >= 15:
		return GameConstants.Ending.SUKSES_AKADEMIK

	return GameConstants.Ending.PEMALAS


# debug
func get_ending_label(ending: int) -> String:
	match ending:
		GameConstants.Ending.SUKSES_AKADEMIK: return "Sukses Akademik"
		GameConstants.Ending.PEMALAS:         return "Pemalas"
		GameConstants.Ending.SUKSES_PASSION:  return "Sukses Passion"
		GameConstants.Ending.MEMBERONTAK:     return "Memberontak"
		GameConstants.Ending.DEPRESI:         return "Depresi"
		GameConstants.Ending.MANDIRI_BAHAGIA: return "Mandiri & Bahagia ★"
		_: return "Unknown"
