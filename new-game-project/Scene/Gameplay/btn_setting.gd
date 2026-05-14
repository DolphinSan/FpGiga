extends Button

@onready var setting_panel = $"../../Setting"

func _ready() -> void:
	pressed.connect(_on_setting_pressed)
	
func _on_setting_pressed() -> void:
	setting_panel.visible = true
