extends Label

func _ready() -> void:
	text = "Anak sedang sakit"

func _process(_delta: float) -> void:
	visible = GameState.sakit_diketahui
