extends Panel

@onready var description_panel: MarginContainer  = $DescriptionPanel
@onready var title_label: Label                  = $DescriptionPanel/DescriptionText/Label
@onready var desc_label: Label                   = $DescriptionPanel/DescriptionText/Label2
@onready var grid: GridContainer                 = $GridContainer

@export var nurture_menu_scene: PackedScene

var current_selected: BaseButton = null
var is_confirmed: bool           = false
var nurture_menu_instance        = null

const BUTTON_AKSI := {
	"rest":       GameConstants.Aksi.REST,
	"recreation": GameConstants.Aksi.RECREATION,
	"infirmary":  GameConstants.Aksi.INFIRMARY,
	"lomba":      GameConstants.Aksi.LOMBA,
}

# Debug Helper
func _dbg(msg: String) -> void:
	print("[ActionMenu] ", msg)

func _dbg_state() -> void:
	print("[ActionMenu] ── STATE ──────────────────────────────")
	print("[ActionMenu]   AP         : ", GameState.action_point)
	print("[ActionMenu]   Mood       : ", GameState.mood, " (", _mood_str(), ")")
	print("[ActionMenu]   Mental     : ", GameState.mental)
	print("[ActionMenu]   Anak sakit : ", GameState.anak_sakit)
	print("[ActionMenu]   Hari libur : ", GameState.is_hari_libur)
	print("[ActionMenu]   Aksi terakhir: ", GameState.aksi_terakhir)
	print("[ActionMenu] ─────────────────────────────────────────")

func _mood_str() -> String:
	match GameState.mood:
		GameConstants.Mood.AWFUL: return "AWFUL"
		GameConstants.Mood.BAD:   return "BAD"
		GameConstants.Mood.BIASA: return "BIASA"
		GameConstants.Mood.GOOD:  return "GOOD"
		GameConstants.Mood.GREAT: return "GREAT"
	return "?"

# Ready
func _ready() -> void:
	_dbg("_ready() dipanggil")

	var nurture_btn := grid.get_node_or_null("Nurture")
	if nurture_btn:
		nurture_btn.pressed.connect(_on_nurture_pressed)
		_dbg("Nurture button ditemukan & terhubung")
	else:
		_dbg("⚠ Nurture button TIDAK ditemukan di GridContainer!")

	var connected_count := 0
	for button in grid.get_children():
		print("[ActionMenu] Child: ", button.name, " | class: ", button.get_class())
		if not (button is TextureButton or button is Button):
			print("[ActionMenu] ⚠ Skip — bukan button")
			continue
		if button.name.to_lower() == "nurture":
			continue
		button.pressed.connect(_on_action_button_pressed.bind(button))
		connected_count += 1
		print("[ActionMenu] ✓ Signal connected: ", button.name)

	_dbg("Total tombol terhubung (non-nurture): " + str(connected_count))

	GameState.ap_changed.connect(_on_ap_changed)
	GameState.anak_sakit_changed.connect(_on_anak_sakit_changed)
	GameState.latar_changed.connect(_on_latar_changed)
	RandomEventManager.event_triggered.connect(_on_random_event)
	_dbg("Signal GameState & RandomEvent terhubung")

	_refresh_all_buttons()

# Handler Klik
func _on_action_button_pressed(button: BaseButton) -> void:
	var aksi: int = BUTTON_AKSI.get(button.name.to_lower(), GameConstants.Aksi.NONE)
	_dbg("Tombol diklik: %s | aksi: %d | selected: %s | confirmed: %s" % [
		button.name, aksi,
		current_selected.name if current_selected else "null",
		str(is_confirmed)
	])

	close_nurture_menu()

	if current_selected != null and current_selected != button:
		_dbg("Pindah ke tombol lain — reset selection")
		_reset_selection()

	if current_selected == null:
		_dbg("Klik 1 → tampilkan deskripsi")
		current_selected = button
		is_confirmed     = false
		_show_description(aksi)
		_set_visual(button, "selected")

	elif not is_confirmed:
		_dbg("Klik 2 → coba eksekusi")
		_try_execute(button, aksi)

	else:
		_dbg("Klik 3 → reset")
		_reset_selection()

# Eksekusi
func _try_execute(button: BaseButton, aksi: int) -> void:
	_dbg("_try_execute: aksi=%d" % aksi)
	_dbg_state()

	if not ActionManager.can_execute(aksi):
		_dbg("can_execute = false → tampilkan pesan gagal")
		_show_gagal(aksi)
		return

	if aksi == GameConstants.Aksi.LOMBA:
		_dbg("→ Buka lomba UI")
		_open_lomba_ui()
		_reset_selection()
		return

	var sukses := ActionManager.execute(aksi)
	_dbg("ActionManager.execute(%d) → sukses: %s" % [aksi, str(sukses)])

	if not sukses:
		_show_gagal(aksi)
		return

	is_confirmed = true
	_set_visual(button, "confirmed")
	_show_hasil(aksi)
	_dbg_state()

	if aksi == GameConstants.Aksi.NURTURE_1:
		_post_nurture1()


func _post_nurture1() -> void:
	_dbg("_post_nurture1 — passion_clue_level: %d | anak_sakit: %s" % [
		GameState.passion_clue_level, str(GameState.anak_sakit)
	])
	var hint := ""
	if GameState.passion_clue_level > 0:
		match GameState.passion_clue_level:
			1: hint = "Anak seperti menyukai sesuatu, tapi belum jelas."
			2: hint = "Anak terlihat bersemangat membicarakan sesuatu..."
			3:
				match GameState.passion:
					GameConstants.Passion.OLAHRAGA: hint = "Anak sangat antusias tentang olahraga!"
					GameConstants.Passion.AKADEMIK:  hint = "Anak suka belajar hal-hal baru."
					GameConstants.Passion.SENI:      hint = "Anak sering bercerita soal seni."
	if hint != "":
		desc_label.text += "\n\n💬 " + hint
	_refresh_button("infirmary")


func _open_lomba_ui() -> void:
	_dbg("⚠ Lomba UI belum disambungkan ke scene.")
	push_warning("Lomba UI belum dibuat.")

# Deskripsi Klik 1
func _show_description(aksi: int) -> void:
	description_panel.visible = true
	match aksi:
		GameConstants.Aksi.REST:
			title_label.text = "REST"
			desc_label.text  = (
				"Beristirahat.\n"
				+ "Netral — tidak menambah atau mengurangi apapun.\n"
				+ "Jika anak tidak enak badan, bisa membantu pemulihan.\n\n"
				+ "⚠ Terlalu sering → menambah kemalasan.\n\n"
				+ "Klik lagi untuk mengonfirmasi."
			)
		GameConstants.Aksi.RECREATION:
			title_label.text = "RECREATION  (2 AP)"
			desc_label.text  = (
				"Aktivitas rekreasi bersama anak.\n"
				+ "Menambah mood anak.\n"
				+ "Bonus jika dilakukan setelah belajar/bersih-bersih.\n\n"
				+ "Hanya tersedia di hari libur.\n\n"
				+ "Klik lagi untuk mengonfirmasi."
			)
		GameConstants.Aksi.INFIRMARY:
			title_label.text = "INFIRMARY  (2 AP)"
			desc_label.text  = (
				"Bawa anak ke dokter.\n"
				+ "Menyembuhkan kondisi sakit anak.\n\n"
				+ "Hanya tersedia setelah Ajak Berbicara\n"
				+ "dan anak terlihat sakit.\n\n"
				+ "Klik lagi untuk mengonfirmasi."
			)
		GameConstants.Aksi.LOMBA:
			title_label.text = "LOMBA"
			desc_label.text  = (
				"Ikutkan anak dalam perlombaan.\n"
				+ "Menang → +2 poin passion.\n"
				+ "Kalah  → +1 poin passion.\n\n"
				+ "⚠ Cabang tidak sesuai passion → merusak mood & mental.\n\n"
				+ "Klik lagi untuk membuka menu lomba."
			)

# Hasil Klik 2
func _show_hasil(aksi: int) -> void:
	description_panel.visible = true
	var chain: bool = GameState.aksi_terakhir in [GameConstants.Aksi.NURTURE_4, GameConstants.Aksi.NURTURE_5]
	match aksi:
		GameConstants.Aksi.REST:
			title_label.text = "REST ✓"
			var extra := " Anak mulai pulih." if not GameState.anak_sakit else ""
			desc_label.text  = "Beristirahat." + extra
		GameConstants.Aksi.RECREATION:
			title_label.text = "RECREATION ✓"
			desc_label.text  = "Rekreasi selesai." + (" (Chain bonus!)" if chain else " Mood naik.")
		GameConstants.Aksi.INFIRMARY:
			title_label.text = "INFIRMARY ✓"
			desc_label.text  = "Anak dibawa ke dokter. Kondisi membaik."
	desc_label.text += "\n\nKlik lagi untuk menutup."

# Gagal
func _show_gagal(aksi: int) -> void:
	description_panel.visible = true
	_dbg("_show_gagal: aksi=%d" % aksi)
	match aksi:
		GameConstants.Aksi.RECREATION:
			desc_label.text = "Rekreasi hanya tersedia di hari libur." if not GameState.is_hari_libur else "AP tidak cukup. (Butuh 2 AP)"
		GameConstants.Aksi.INFIRMARY:
			desc_label.text = "Anak tidak terlihat sakit.\nCoba Ajak Berbicara dulu." if not GameState.anak_sakit else "AP tidak cukup. (Butuh 2 AP)"
		GameConstants.Aksi.LOMBA:
			desc_label.text = "Belum mendaftarkan anak ke lomba." if not GameState.lomba_terdaftar else "Bukan waktu lomba."
		_:
			desc_label.text = "AP tidak cukup."

# Refresh Tombol
func _refresh_all_buttons() -> void:
	_dbg("_refresh_all_buttons()")
	for button_name in BUTTON_AKSI:
		_refresh_button(button_name)


func _refresh_button(button_name: String) -> void:
	var node = grid.get_node_or_null(button_name)
	if node == null:
		node = grid.get_node_or_null(button_name.capitalize())
	if node == null:
		_dbg("Tombol '%s' tidak ditemukan di grid" % button_name)
		return
	if not node is BaseButton:
		_dbg("Node '%s' bukan BaseButton" % button_name)
		return

	var btn := node as BaseButton
	var aksi: int = BUTTON_AKSI.get(button_name, GameConstants.Aksi.NONE)
	var bisa := ActionManager.can_execute(aksi)
	btn.disabled = not bisa
	_dbg("Refresh '%s' → can_execute: %s" % [button_name, str(bisa)])

	if button_name == "infirmary":
		btn.modulate = Color(1.0, 0.5, 0.5) if GameState.anak_sakit else Color(0.6, 0.6, 0.6)

# Visual
func _set_visual(button: BaseButton, state: String) -> void:
	match state:
		"selected":  button.modulate = Color(1.2, 1.2, 0.6)
		"confirmed": button.modulate = Color(0.6, 1.2, 0.6)
		"normal":    button.modulate = Color(1.0, 1.0, 1.0)


func _reset_selection() -> void:
	_dbg("_reset_selection()")
	if current_selected:
		_set_visual(current_selected, "normal")
	current_selected = null
	is_confirmed     = false
	hide_description()


func hide_description() -> void:
	description_panel.visible = false
	if title_label: title_label.text = ""
	if desc_label:  desc_label.text  = ""

# Signal Handlers
func _on_ap_changed(ap: int) -> void:
	_dbg("Signal ap_changed → AP: " + str(ap))
	_refresh_all_buttons()

func _on_anak_sakit_changed(sakit: bool) -> void:
	_dbg("Signal anak_sakit_changed → " + str(sakit))
	_refresh_button("infirmary")

func _on_latar_changed(latar: int) -> void:
	_dbg("Signal latar_changed → latar: " + str(latar))
	_reset_selection()
	_refresh_all_buttons()
	RandomEventManager.try_trigger_event()

func _on_random_event(event: Dictionary) -> void:
	_dbg("Random event muncul: " + event["nama"])
	print("[ActionMenu] EVENT  : ", event["nama"])
	print("[ActionMenu] Pilihan 1: ", event["pilihan"][0]["teks"])
	print("[ActionMenu] Pilihan 2: ", event["pilihan"][1]["teks"])
	# TODO: tampilkan popup UI event

# Nurture Menu
func _on_nurture_pressed() -> void:
	_dbg("Nurture button diklik")
	if is_instance_valid(nurture_menu_instance):
		_dbg("Nurture menu sudah terbuka → tutup")
		close_nurture_menu()
		return

	_reset_selection()

	if nurture_menu_scene == null:
		_dbg("nurture_menu_scene belum di-assign di Inspector!")
		push_error("Nurture Menu Scene belum di-assign!")
		return

	nurture_menu_instance = nurture_menu_scene.instantiate()
	get_tree().current_scene.add_child(nurture_menu_instance)
	_dbg("Nurture menu di-instantiate")

	await get_tree().process_frame

	var nurture_btn := grid.get_node_or_null("Nurture")
	var ref_pos: Vector2 = nurture_btn.global_position if nurture_btn else global_position
	nurture_menu_instance.global_position = Vector2(
		ref_pos.x + nurture_btn.size.x + 230,
		ref_pos.y - 20
	)
	nurture_menu_instance.visible = true
	_dbg("Nurture menu posisi: " + str(nurture_menu_instance.global_position))

	if nurture_menu_instance.has_signal("menu_closed"):
		nurture_menu_instance.menu_closed.connect(_on_nurture_menu_closed)


func _on_nurture_menu_closed() -> void:
	_dbg("Nurture menu ditutup")
	nurture_menu_instance = null


func close_nurture_menu() -> void:
	if is_instance_valid(nurture_menu_instance):
		nurture_menu_instance.queue_free()
	nurture_menu_instance = null


func _exit_tree() -> void:
	close_nurture_menu()
	if GameState.ap_changed.is_connected(_on_ap_changed):
		GameState.ap_changed.disconnect(_on_ap_changed)
	if GameState.anak_sakit_changed.is_connected(_on_anak_sakit_changed):
		GameState.anak_sakit_changed.disconnect(_on_anak_sakit_changed)
	if GameState.latar_changed.is_connected(_on_latar_changed):
		GameState.latar_changed.disconnect(_on_latar_changed)
	if RandomEventManager.event_triggered.is_connected(_on_random_event):
		RandomEventManager.event_triggered.disconnect(_on_random_event)
	_dbg("_exit_tree — semua signal diputus")
