# NurtureMenu.gd
extends Panel

signal nurture_chosen(sub_action: String)

func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var close_btn = find_child("CloseButton", true, false)
	if close_btn:
		close_btn.pressed.connect(_on_close_pressed)

func _on_close_pressed():
	hide_menu()

func hide_menu():
	visible = false                    # Sembunyikan dulu
	get_viewport().set_input_as_handled()
	
	# Tunggu sebentar lalu hapus dengan aman
	await get_tree().process_frame
	queue_free()

func _on_sub_button_pressed(button: BaseButton):
	var action_name = button.name.to_lower()
	nurture_chosen.emit(action_name)
	hide_menu()
