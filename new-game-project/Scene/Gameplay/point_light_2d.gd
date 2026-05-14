extends PointLight2D

var t := 0.0

func _process(delta):
	t += delta
	energy = 1.8 + sin(t * 3.0) * 0.5
