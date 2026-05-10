extends CanvasLayer
# Panel Pendaftaran Lomba
# Muncul di minggu pertama saat pemain klik tombol Lomba

signal pendaftaran_selesai
signal pendaftaran_dibatalkan

@onready var btn_musik:    BaseButton = $Panel/VBoxContainer/BtnMusik
@onready var btn_olahraga: BaseButton = $Panel/VBoxContainer/BtnOlahraga
@onready var btn_akademik: BaseButton = $Panel/VBoxContainer/BtnAkademik
@onready var btn_seni:     BaseButton = $Panel/VBoxContainer/BtnSeni
@onready var btn_daftar:   BaseButton = $Panel/BtnDaftar
@onready var btn_batal:    BaseButton = $Panel/BtnBatal
@onready var label_info:   Label      = $Panel/LabelInfo
@onready var label_hint:   Label      = $Panel/LabelHint

var cabang_dipilih: int = GameConstants.Passion.BELUM_DIKETAHUI

const WARNA_DIPILIH := Color(0.6, 1.2, 0.6)
const WARNA_NORMAL  := Color(1.0, 1.0, 1.0)

func _ready() -> void:
	btn_musik.pressed.connect(_pilih_cabang.bind(GameConstants.Passion.MUSIK))
	btn_olahraga.pressed.connect(_pilih_cabang.bind(GameConstants.Passion.OLAHRAGA))
	btn_akademik.pressed.connect(_pilih_cabang.bind(GameConstants.Passion.AKADEMIK))
	btn_seni.pressed.connect(_pilih_cabang.bind(GameConstants.Passion.SENI))
	btn_daftar.pressed.connect(_on_daftar)
	btn_batal.pressed.connect(_on_batal)

	btn_daftar.disabled = true
	label_info.text = "Pilih cabang lomba untuk anak."
	_update_hint()

func _pilih_cabang(cabang: int) -> void:
	cabang_dipilih = cabang
	btn_daftar.disabled = false

	# Reset semua warna
	for btn in [btn_musik, btn_olahraga, btn_akademik, btn_seni]:
		btn.modulate = WARNA_NORMAL

	# Highlight yang dipilih
	match cabang:
		GameConstants.Passion.MUSIK:    btn_musik.modulate    = WARNA_DIPILIH
		GameConstants.Passion.OLAHRAGA: btn_olahraga.modulate = WARNA_DIPILIH
		GameConstants.Passion.AKADEMIK: btn_akademik.modulate = WARNA_DIPILIH
		GameConstants.Passion.SENI:     btn_seni.modulate     = WARNA_DIPILIH

	label_info.text = "Cabang dipilih: " + GameConstants.PASSION_NAMA[cabang]
	print("[LombaPanel] Cabang dipilih: ", GameConstants.PASSION_NAMA[cabang])

func _update_hint() -> void:
	# Tampilkan hint passion jika sudah cukup bicara
	if GameState.passion_clue_level >= 3 and GameState.passion != GameConstants.Passion.BELUM_DIKETAHUI:
		label_hint.text = "💬 Anak sepertinya tertarik pada: " + GameConstants.PASSION_NAMA[GameState.passion]
	elif GameState.passion_clue_level == 2:
		label_hint.text = "💬 Anak terlihat bersemangat membicarakan sesuatu..."
	elif GameState.passion_clue_level == 1:
		label_hint.text = "💬 Sepertinya ada sesuatu yang anak sukai."
	else:
		label_hint.text = "💬 Coba Ajak Berbicara lebih sering untuk mengetahui passion anak."

func _on_daftar() -> void:
	if cabang_dipilih == GameConstants.Passion.BELUM_DIKETAHUI:
		return
	LombaManager.daftar_lomba(cabang_dipilih)
	print("[LombaPanel] Terdaftar cabang: ", GameConstants.PASSION_NAMA[cabang_dipilih])
	emit_signal("pendaftaran_selesai")
	queue_free()

func _on_batal() -> void:
	emit_signal("pendaftaran_dibatalkan")
	queue_free()
