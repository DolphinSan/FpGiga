extends Node2D

@onready var label_judul: Label = $Panel/Label
@onready var label_desc:  Label = $Panel/Label2
@onready var btn_menu:    Button = $Panel/VBoxContainer/Button

const ENDING_DATA := {
	GameConstants.Ending.SUKSES_AKADEMIK: {
		"judul": "Ending: Sukses Akademik",
		"desc":  "Anakmu sukses secara akademik, dia menjadi peringkat pertama di sekolah\n Mungkin di suatu tempat ada yang hanya berleha leha tanpa ada pembelajaran"
	},
	GameConstants.Ending.PEMALAS: {
		"judul": "Ending: Si Pemalas",
		"desc":  "Anakmu Tumbuh menjadi orang yang pemalasa, terkadang memanjakan anak berlebihan tidaklah baik\n Mungkin apabila dia lebih mengejar passion mungkin akan berbeda"
	},
	GameConstants.Ending.SUKSES_PASSION: {
		"judul": "Ending: Sukses Passion",
		"desc":  "Anakmu sukses secara passion nya terhadap musik dan banyak memenangkan perlombaan\n Mungkin di suatu tempat ada yang mencoba memberontak karena terlalu dipaksa"
	},
	GameConstants.Ending.MEMBERONTAK: {
		"judul": "Ending: Memberontak",
		"desc":  "Anakmu menjadi susah diatur, bahkan sekedar ditanya keaadaan pun dia malas menjawab\n Terkadang kita tidak bisa memaksakan nya sesuai keheendak kita\n terlebih ada kemungkinan sang anak hanya bisa menurut\n tanpa ada perlawanan hingga menjadi depresi"
	},
	GameConstants.Ending.DEPRESI: {
		"judul": "Ending: Depresi",
		"desc":  "Anakmu mungkin sukses, namun mentalnya hancur, dia depresi karena tujuannya selalu diatur olehmu\n terkadang kita harus menanyakan apa maunya, serta mengarahkan ke arah yang benar tanpa paksaan"
	},
	GameConstants.Ending.MANDIRI_BAHAGIA: {
	"judul": "Ending: Mandiri & Bahagia",
	"desc": "Anakmu tumbuh menjadi anak yang mandiri dan bahagia, setidaknya inilah kondisi idealnya\n karena mungkin masih ada satu hal yang belum kamu lihat"
	},
	GameConstants.Ending.NORMAL: {
	"judul": "Ending: Normal",
	"desc": "Anak mu tumbuh normal, menjalani hidup normal, prestasinya pun normal\n tidak buruk namun bisa lebih baik entah ke sisi akademik ataupun passionnya"
	},
	GameConstants.Ending.NORMAL_TIDAK_JELAS: {
	"judul": "Ending: Normal(?)",
	"desc": "Anak TUmbuh Normal, menjalani hidup normal, prestasinya pun normal\n namun hidupnya tidak jelas, dia tidak tahu apa tujuannya setelah ini karena kamu tdk pernah megnarahkannya"
	},
}

func _ready() -> void:
	btn_menu.text = "Kembali ke Menu"
	btn_menu.pressed.connect(_on_kembali)

	_tampilkan_ending(GameState.current_ending)


func _tampilkan_ending(ending: int) -> void:
	var data: Dictionary = ENDING_DATA.get(ending, {
		"judul": "Ending",
		"desc":  "Cerita telah berakhir."
	})
	label_judul.text = data["judul"]
	label_desc.text  = data["desc"]
	print("[EndingScreen] Ending: ", ending, " | ", data["judul"])

func _on_kembali() -> void:
	
	get_tree().change_scene_to_file("res://Scene/Gameplay/MainMenu.tscn")
