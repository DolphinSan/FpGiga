extends Node

func calculate() -> int:
	if (GameState.point_dimanjakan <= 25 and
		GameState.point_tertekan >= 40 and
		GameState.point_kemalasan <= 25 and
		GameState.point_tanggung_jawab > 50 and
		GameState.point_akademik > 50 and
		GameState.point_passion >= 50 and
		GameState.mood == GameConstants.Mood.AWFUL and
		GameState.mental == GameConstants.Mental.RUSAK):
		return GameConstants.Ending.DEPRESI

	if (GameState.point_dimanjakan <= 25 and 
		GameState.point_tertekan >= 25 and 
		GameState.point_kemalasan <= 25 and
		GameState.point_tanggung_jawab >= 100 and
		GameState.point_akademik >= 100 and
		GameState.point_passion <= 25 and
		GameState.mood <= GameConstants.Mood.BIASA):
		return GameConstants.Ending.MEMBERONTAK

	if (GameState.point_dimanjakan >= 50 and 
		GameState.point_tertekan <= 25 and 
		GameState.point_kemalasan >= 50 and
		GameState.point_tanggung_jawab < 100 and
		GameState.point_akademik < 100 and
		GameState.point_passion < 50):
		return GameConstants.Ending.PEMALAS

	if (GameState.point_dimanjakan <= 25 and 
		GameState.point_tertekan <= 25 and 
		GameState.point_kemalasan <= 25 and
		GameState.point_tanggung_jawab >= 100 and
		GameState.point_passion >= 75 and
		GameState.mood >= GameConstants.Mood.BIASA):
		return GameConstants.Ending.SUKSES_PASSION

	if (GameState.point_dimanjakan <= 25 and 
		GameState.point_tertekan <= 25 and 
		GameState.point_kemalasan <= 25 and
		GameState.point_tanggung_jawab >= 100 and
		GameState.point_akademik >= 150 and
		GameState.point_passion >= 0 and
		GameState.mood >= GameConstants.Mood.BIASA and
		GameState.mental >= GameConstants.Mental.BIASA):
		return GameConstants.Ending.SUKSES_AKADEMIK

	if (GameState.point_dimanjakan <= 10 and 
		GameState.point_tertekan <= 10 and 
		GameState.point_kemalasan <= 10 and
		GameState.point_tanggung_jawab >= 100 and
		GameState.point_akademik >= 150 and
		GameState.point_passion >= 75 and
		GameState.mood == GameConstants.Mood.GREAT and
		GameState.mental == GameConstants.Mental.SANGAT_SEHAT):
		return GameConstants.Ending.MANDIRI_BAHAGIA
		
	var point_buruk = GameState.point_dimanjakan + GameState.point_tertekan + GameState.point_kemalasan
	var point_baik  = GameState.point_akademik + GameState.point_passion + GameState.point_tanggung_jawab
	
	if point_baik > point_buruk:
		return GameConstants.Ending.NORMAL
	elif point_buruk > point_baik:
		return GameConstants.Ending.NORMAL_TIDAK_JELAS

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
