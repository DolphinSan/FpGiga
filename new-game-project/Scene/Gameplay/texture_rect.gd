extends TextureRect

var time := 0.0
var start_pos := Vector2.ZERO

func _ready():
	start_pos = position

func _process(delta):
	time += delta
	position.y = start_pos.y + sin(time * 0.5) * 8
