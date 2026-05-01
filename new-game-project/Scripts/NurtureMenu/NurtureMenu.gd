extends Panel

signal menu_closed

@onready var desc_title: Label = $DescriptionPanel/DescriptionText/Label
@onready var desc_body: Label  = $DescriptionPanel/DescriptionText/Label2
@onready var desc_panel        = $DescriptionPanel

# Map nama node tombol → GameConstants.Aksi
const NURTURE_AKSI := {
	"AjakBerbicara": GameConstants.Aksi.NURTURE_1,
	"BeriHadiah":    GameConstants.Aksi.NURTURE_2,
	"BeriPerhatian": GameConstants.Aksi.NURTURE_3,
	"SuruhBelajar":  GameConstants.Aksi.NURTURE_4,
	"BersihBersih":  GameConstants.Aksi.NURTURE_5,
}

var current_selected: BaseButton = null
var is_confirmed: bool           = false

func _ready() -> void:
	for node_name in NURTURE_AKSI:
		var btn := get_node_or_null(node_name)
		if btn:
			btn.pressed.connect(_on_nurture_btn_pressed.bind(btn))

	GameState.ap_changed.connect(_on_ap_changed)
	_refresh_all()

#  HANDLER KLIK
func _on_nurture_btn_pressed(button: BaseButton) -> void:
	var aksi: int = NURTURE_AKSI.get(button.name, GameConstants.Aksi.NONE)

	if current_selected != null and current_selected != button:
		_reset_selection()

	if current_selected == null:
		# Klik 1: tampilkan deskripsi
		current_selected = button
		is_confirmed     = false
		_show_description(aksi)
		_set_visual(button, "selected")

	elif not is_confirmed:
		# Klik 2: eksekusi
		_try_execute(button, aksi)

	else:
		# Klik 3: tutup menu
		emit_signal("menu_closed")
		queue_free()

#  EKSEKUSI
func _try_execute(button: BaseButton, aksi: int) -> void:
	if not ActionManager.can_execute(aksi):
		desc_body.text = "AP tidak cukup."
		return

	var sukses := ActionManager.execute(aksi)
	if not sukses:
		desc_body.text = "Aksi gagal dilakukan."
		return

	is_confirmed = true
	_set_visual(button, "confirmed")
	_show_hasil(aksi)

#  DESKRIPSI — Klik 1
func _show_description(aksi: int) -> void:
	desc_panel.visible = true
	match aksi:
		GameConstants.Aksi.NURTURE_1:
			desc_title.text = "AJAK BERBICARA"
			desc_body.text  = (
				"Mengobrol dengan anak.\n"
				+ "Menggali informasi tentang ketertarikan, kondisi, dan kesehatan anak.\n\n"
				+ "Jika mental anak rusak → sedikit memulihkan mental.\n"
				+ "Jika anak sakit → membuka opsi Infirmary.\n\n"
				+ "Klik lagi untuk mengonfirmasi."
			)
		GameConstants.Aksi.NURTURE_2:
			desc_title.text = "BERI HADIAH"
			desc_body.text  = (
				"Memberikan hadiah kepada anak.\n"
				+ "Menambah mood anak.\n"
				+ "Bonus jika dilakukan setelah belajar/bersih-bersih → mood + mental naik.\n\n"
				+ "⚠ Terlalu sering (2x/hari selama 3 hari) → menambah sifat dimanjakan.\n\n"
				+ "Klik lagi untuk mengonfirmasi."
			)
		GameConstants.Aksi.NURTURE_3:
			desc_title.text = "BERI PERHATIAN"
			desc_body.text  = (
				"Memberikan perhatian kepada anak.\n"
				+ "Menambah mood & sedikit memulihkan mental.\n"
				+ "Jika mental rusak → efek pemulihan lebih besar.\n\n"
				+ "⚠ Terlalu sering (2x/hari selama 3 hari) → menambah sifat dimanjakan.\n\n"
				+ "Klik lagi untuk mengonfirmasi."
			)
		GameConstants.Aksi.NURTURE_4:
			desc_title.text = "SURUH BELAJAR"
			desc_body.text  = (
				"Menyuruh anak belajar.\n"
				+ "Menambah poin Akademik & Tanggung Jawab.\n"
				+ "Mood anak yang baik meningkatkan poin yang didapat.\n\n"
				+ "⚠ Terlalu sering (2x/hari selama 3 hari) → anak merasa tertekan.\n\n"
				+ "Klik lagi untuk mengonfirmasi."
			)
		GameConstants.Aksi.NURTURE_5:
			desc_title.text = "BERSIH-BERSIH"
			desc_body.text  = (
				"Menyuruh anak membereskan rumah.\n"
				+ "Menambah poin Tanggung Jawab.\n\n"
				+ "⚠ Terlalu sering (2x/hari selama 3 hari) → anak merasa tertekan.\n\n"
				+ "Klik lagi untuk mengonfirmasi."
			)
			
#  HASIL — Klik 2 (berhasil)
func _show_hasil(aksi: int) -> void:
	desc_panel.visible = true
	var chain := GameState.aksi_terakhir in [GameConstants.Aksi.NURTURE_4, GameConstants.Aksi.NURTURE_5]

	match aksi:
		GameConstants.Aksi.NURTURE_1:
			desc_title.text = "AJAK BERBICARA ✓"
			var hint := _get_passion_hint()
			desc_body.text  = "Mengobrol dengan anak." + ("\n\n💬 " + hint if hint != "" else "")
			if GameState.anak_sakit:
				desc_body.text += "\n\n🤒 Anak terlihat tidak sehat. Pertimbangkan Infirmary."
		GameConstants.Aksi.NURTURE_2:
			desc_title.text = "BERI HADIAH ✓"
			desc_body.text  = "Mood anak naik." + (" (Chain bonus! Mood + mental naik)" if chain else "")
		GameConstants.Aksi.NURTURE_3:
			desc_title.text = "BERI PERHATIAN ✓"
			desc_body.text  = "Mood & mental anak membaik." + (" (Chain bonus!)" if chain else "")
		GameConstants.Aksi.NURTURE_4:
			desc_title.text = "SURUH BELAJAR ✓"
			desc_body.text  = "Poin Akademik & Tanggung Jawab bertambah."
		GameConstants.Aksi.NURTURE_5:
			desc_title.text = "BERSIH-BERSIH ✓"
			desc_body.text  = "Poin Tanggung Jawab bertambah."

	desc_body.text += "\n\nKlik lagi untuk menutup menu."


func _get_passion_hint() -> String:
	match GameState.passion_clue_level:
		1: return "Anak seperti menyukai sesuatu, tapi belum jelas."
		2: return "Anak bersemangat membicarakan sesuatu..."
		3:
			match GameState.passion:
				GameConstants.Passion.OLAHRAGA: return "Anak sangat antusias tentang olahraga!"
				GameConstants.Passion.AKADEMIK:  return "Anak suka belajar hal-hal baru."
				GameConstants.Passion.SENI:      return "Anak sering bercerita soal seni."
	return ""

#  REFRESH & VISUA
func _refresh_all() -> void:
	for node_name in NURTURE_AKSI:
		var btn := get_node_or_null(node_name)
		if btn:
			var aksi: int = NURTURE_AKSI[node_name]
			btn.disabled = not ActionManager.can_execute(aksi)


func _set_visual(button: BaseButton, state: String) -> void:
	match state:
		"selected":  button.modulate = Color(1.2, 1.2, 0.6)
		"confirmed": button.modulate = Color(0.6, 1.2, 0.6)
		"normal":    button.modulate = Color(1.0, 1.0, 1.0)


func _reset_selection() -> void:
	if current_selected:
		_set_visual(current_selected, "normal")
	current_selected = null
	is_confirmed     = false
	desc_panel.visible = false

#  SIGNAL
func _on_ap_changed(_ap: int) -> void:
	_refresh_all()


func _exit_tree() -> void:
	if GameState.ap_changed.is_connected(_on_ap_changed):
		GameState.ap_changed.disconnect(_on_ap_changed)
	emit_signal("menu_closed")
