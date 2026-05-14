extends Sprite2D

# Path sprite per fase
const SPRITES := {
	"pagi": "res://Asset/Background/MainUi/Story_Ryōshū_and_Araya's_Room_BG.png",
	"Siang": "res://Asset/Background/MainUi/Story_Ryōshū_and_Araya's_Room_BG.png",
	"malam": "res://Asset/Background/MainUi/Story_The_House_of_Spiders_Rooftop,_a_Certain_Day_BG (1).png"
}

func _ready() -> void:
	GameState.latar_changed.connect(_on_latar_changed)
	_update_sprite()

func _on_latar_changed(_latar: int) -> void:
	_update_sprite()

func _update_sprite() -> void:
	var key := _get_sprite_key()
	var path: String = SPRITES[key]

	print("[BGSprite] Key: %s | Path: %s" % [key, path])

	if ResourceLoader.exists(path):
		texture = load(path)
	else:
		push_warning("[BGSprite] Sprite tidak ditemukan: " + path)

func _get_sprite_key() -> String:
	if GameState.latar == GameConstants.Waktu.PAGI:
		return "pagi"
	
	if GameState.latar == GameConstants.Waktu.SIANG:
		return "Siang"
		
	if GameState.latar == GameConstants.Waktu.MALAM:
		return "malam"
	
	return "pagi"
