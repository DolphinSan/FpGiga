extends Sprite2D

# Path sprite per fase
const SPRITES := {
	1: {
		"normal":  "res://Asset/Sprite/Fase1/ArayaNormal.png",
		"great":   "res://Asset/Sprite/Fase1/ArayaGreat.png",
		"awfull":  "res://Asset/Sprite/Fase1/ArayaAwfull.png",
		"rusak":   "res://Asset/Sprite/Fase1/ArayaRusak.png",
		"bahagia": "res://Asset/Sprite/Fase1/ArayaBahagia.png",
	},
	2: {
		"normal":  "res://Asset/Sprite/Fase2/ArayaNormal.png",
		"great":   "res://Asset/Sprite/Fase2/ArayaNormal.png",
		"awfull":  "res://Asset/Sprite/Fase2/ArayaMoodDown.png",
		"rusak":   "res://Asset/Sprite/Fase2/ArayaMoodDown.png",
		"bahagia": "res://Asset/Sprite/Fase2/ArayaNormal.png",
	},
	3: {
		"normal":  "res://Asset/Sprite/Fase3/ArayaNormal.png",
		"great":   "res://Asset/Sprite/Fase3/ArayaGreat.png",
		"awfull":  "res://Asset/Sprite/Fase3/ArayaAwfull.png",
		"rusak":   "res://Asset/Sprite/Fase3/ArayaRusak.png",
		"bahagia": "res://Asset/Sprite/Fase3/ArayaBahagia.png",
	},
}

func _ready() -> void:
	GameState.mood_changed.connect(_on_stat_changed)
	GameState.mental_changed.connect(_on_stat_changed)
	GameState.hari_changed.connect(_on_fase_changed)
	_update_sprite()

func _on_stat_changed(_val: int) -> void:
	_update_sprite()
	
func _on_fase_changed(_hari: int, _fase: int) -> void:
	_update_sprite()

func _update_sprite() -> void:
	var key := _get_sprite_key()
	var fase := GameState.fase
	var path: String = SPRITES[fase][key]

	print("[ArayaSprite] Fase: %d | Key: %s | Path: %s" % [fase, key, path])

	if ResourceLoader.exists(path):
		texture = load(path)
	else:
		push_warning("[ArayaSprite] Sprite tidak ditemukan: " + path)

func _get_sprite_key() -> String:
	# Mental rusak = prioritas tertinggi
	if GameState.mental == GameConstants.Mental.RUSAK:
		return "rusak"

	# Bahagia = mood GREAT + mental SANGAT_SEHAT
	if GameState.mood == GameConstants.Mood.GREAT and GameState.mental == GameConstants.Mental.SANGAT_SEHAT:
		return "bahagia"

	match GameState.mood:
		GameConstants.Mood.GREAT:
			return "great"
		GameConstants.Mood.GOOD:
			return "great"
		GameConstants.Mood.BIASA:
			return "normal"
		GameConstants.Mood.BAD:
			return "awfull"
		GameConstants.Mood.AWFUL:
			return "awfull"

	return "normal"
