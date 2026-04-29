# ActionMenu.gd
extends Panel

@onready var description_panel: MarginContainer = $DescriptionPanel
@onready var title_label: Label = $DescriptionPanel/DescriptionText/Label
@onready var desc_label: Label = $DescriptionPanel/DescriptionText/Label2

@export var nurture_menu_scene: PackedScene

var current_selected: BaseButton = null
var nurture_menu_instance = null

func _ready():
	var nurture_button = $GridContainer.get_node_or_null("Nurture")
	if nurture_button:
		nurture_button.pressed.connect(_on_nurture_pressed)
	
	for button in $GridContainer.get_children():
		if button is TextureButton or button is Button:
			if button.name.to_lower() == "nurture":
				continue
			button.pressed.connect(_on_action_button_pressed.bind(button))

func _on_action_button_pressed(button: BaseButton):
	close_nurture_menu()           # Tutup nurture menu kalau ada
	hide_description()             # ← Tambahan penting: sembunyikan deskripsi
	
	if current_selected == button:
		current_selected = null
		return
	
	current_selected = button
	show_description(button)

func show_description(button: BaseButton):
	var action_name = button.name.to_lower()
	
	description_panel.visible = true
	
	match action_name:
		"rest":
			title_label.text = "REST"
			desc_label.text = "Beristirahat untuk memulihkan stamina dan mood karakter."
		"recreation":
			title_label.text = "RECREATION"
			desc_label.text = "Melakukan aktivitas rekreasi untuk meningkatkan mood dan kondisi mental."
		"infirmary":
			title_label.text = "INFIRMARY"
			desc_label.text = "Memulihkan kondisi kesehatan karakter ketika sedang sakit atau lelah."
		"lomba":
			title_label.text = "LOMBA"
			desc_label.text = "Mengikuti lomba untuk mendapatkan poin, pengalaman, dan hadiah."
		_:
			title_label.text = ""
			desc_label.text = ""

func hide_description():
	description_panel.visible = false
	if title_label: title_label.text = ""
	if desc_label: desc_label.text = ""

# ================== NURTURE MENU ==================
func _on_nurture_pressed():
	close_nurture_menu()   # Tutup instance lama kalau ada
	hide_description()     # Sembunyikan deskripsi saat membuka nurture menu
	
	if nurture_menu_scene == null:
		push_error("Nurture Menu Scene belum di-assign!")
		return
	
	if nurture_menu_instance != null:
		nurture_menu_instance.queue_free()
		nurture_menu_instance = null

	nurture_menu_instance = nurture_menu_scene.instantiate()
	get_parent().add_child(nurture_menu_instance)
	nurture_menu_instance.position = Vector2(80, 280)   # sesuaikan posisi

	nurture_menu_instance.visible = true
	
func close_nurture_menu():
	if nurture_menu_instance != null:
		nurture_menu_instance.queue_free()
		nurture_menu_instance = null

func _exit_tree():
	close_nurture_menu()
