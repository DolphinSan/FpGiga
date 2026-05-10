extends CanvasLayer
# Panel Konfirmasi & Eksekusi Lomba
# Muncul di minggu kedua saat hari Sabtu/Minggu

signal lomba_selesai(hasil: Dictionary)

@onready var label_judul:     Label      = $Panel/LabelJudul
@onready var label_info:      Label      = $Panel/LabelInfo
@onready var label_sakit:     Label      = $Panel/LabelSakit
@onready var btn_mulai:       BaseButton = $Panel/HBoxContainer/BtnMulai
@onready var btn_batal:       BaseButton = $Panel/HBoxContainer/BtnBatal

# Panel konfirmasi sakit (hidden by default)
@onready var panel_sakit:     Control    = $PanelKonfirmasiSakit
@onready var label_sakit_msg: Label      = $PanelKonfirmasiSakit/Label
@onready var btn_tetap_ikut:  BaseButton = $PanelKonfirmasiSakit/HBox/BtnTetapIkut
@onready var btn_istirahat:   BaseButton = $PanelKonfirmasiSakit/HBox/BtnIstirahat

# Apakah sakit terdeteksi (hanya jika bicara_count >= 3)
var _sakit_terdeteksi: bool = false

func _ready() -> void:
	panel_sakit.visible = false
	_setup_info()

	btn_mulai.pressed.connect(_on_mulai_diklik)
	btn_batal.pressed.connect(_on_batal)
	btn_tetap_ikut.pressed.connect(_on_tetap_ikut)
	btn_istirahat.pressed.connect(_on_istirahat)

func _setup_info() -> void:
	var cabang_nama: String = GameConstants.PASSION_NAMA.get(
		GameState.lomba_cabang, "?"
	)
	label_judul.text = "Hari Lomba Tiba!"
	label_info.text  = "Cabang: %s\nLomba akan segera dimulai." % cabang_nama

	# Sakit hanya terdeteksi jika sudah cukup bicara
	_sakit_terdeteksi = GameState.sakit_diketahui

	if _sakit_terdeteksi:
		label_sakit.text    = "🤒 Anak terlihat tidak sehat hari ini."
		label_sakit.visible = true
	else:
		label_sakit.visible = false

	print("[LombaStartPanel] Cabang: %s | Sakit: %s | Terdeteksi: %s" % [
		cabang_nama,
		str(GameState.anak_sakit),
		str(_sakit_terdeteksi)
	])

func _on_mulai_diklik() -> void:
	# Jika sakit terdeteksi → tampilkan konfirmasi dulu
	if _sakit_terdeteksi:
		_tampilkan_konfirmasi_sakit()
		return
	# Langsung jalankan lomba
	_jalankan_lomba(false)

func _tampilkan_konfirmasi_sakit() -> void:
	panel_sakit.visible  = true
	btn_mulai.disabled   = true
	btn_batal.disabled   = true
	label_sakit_msg.text = (
		"Anak terlihat tidak sehat.\n"
		+ "Tetap ikutkan lomba berisiko memperburuk kondisinya.\n\n"
		+ "Apa yang akan kamu lakukan?"
	)

func _on_tetap_ikut() -> void:
	panel_sakit.visible = false
	LombaManager.handle_sakit_sebelum_lomba(true)
	_jalankan_lomba(true)

func _on_istirahat() -> void:
	panel_sakit.visible = false
	LombaManager.handle_sakit_sebelum_lomba(false)
	var hasil := { "menang": false, "kasus": "istirahat" }
	print("[LombaStartPanel] Anak diistirahatkan — tidak ikut lomba")
	emit_signal("lomba_selesai", hasil)
	queue_free()

func _jalankan_lomba(paksa_sakit: bool) -> void:
	var hasil := LombaManager.jalankan_lomba()
	print("[LombaStartPanel] Hasil lomba: ", hasil)
	_tampilkan_hasil(hasil)

func _tampilkan_hasil(hasil: Dictionary) -> void:
	btn_mulai.visible = false
	btn_batal.visible = false

	var teks := ""
	match hasil.get("kasus", ""):
		"normal":
			teks = "✓ Menang!" if hasil["menang"] else "Kalah, tapi anak sudah berusaha."
		"sick":
			teks = "Anak bertanding walau sakit.\n"
			teks += "✓ Menang!" if hasil["menang"] else "Kalah. Kondisi anak memburuk."
		"wrong_passion":
			teks = "Cabang tidak sesuai passion anak.\nAnak terlihat sangat tertekan."
		"worst":
			teks = "Cabang salah dan anak sakit.\nMental anak sangat terguncang."
		"istirahat":
			teks = "Anak tidak jadi ikut lomba.\nIstirahat lebih penting."

	label_info.text = teks

	# Tombol tutup
	btn_mulai.text    = "Tutup"
	btn_mulai.visible = true
	btn_mulai.pressed.disconnect(_on_mulai_diklik)
	btn_mulai.pressed.connect(func():
		emit_signal("lomba_selesai", hasil)
		queue_free()
	)

func _on_batal() -> void:
	queue_free()
