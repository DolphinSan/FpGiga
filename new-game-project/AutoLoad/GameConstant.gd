class_name GameConstants

enum Fase    { SD = 1, SMP = 2, SMA = 3 }
enum Waktu   { PAGI, SIANG, MALAM }
enum Mood    { AWFUL = 0, BAD = 1, BIASA = 2, GOOD = 3, GREAT = 4 }
enum Mental  { RUSAK = 0, BIASA = 1, SANGAT_SEHAT = 2 }
enum Passion { BELUM_DIKETAHUI = 0, OLAHRAGA = 1, AKADEMIK = 2, SENI = 3 }

enum Ending {
	NONE,
	SUKSES_AKADEMIK,
	PEMALAS,
	SUKSES_PASSION,
	MEMBERONTAK,
	DEPRESI,
	MANDIRI_BAHAGIA   # true ending
}

enum Aksi {
	NONE,
	NURTURE_1,   # Ajak Berbicara
	NURTURE_2,   # Beri Hadiah
	NURTURE_3,   # Beri Perhatian
	NURTURE_4,   # Suruh Belajar
	NURTURE_5,   # Suruh Bersih-Bersih
	REST,
	RECREATION,
	INFIRMARY,
	LOMBA
}

# Action Point per latar waktu
const AP_PAGI   := 3
const AP_SIANG  := 4
const AP_MALAM  := 4

# Biaya AP
const AP_COST_DEFAULT := 1
const AP_COST_SPECIAL := 2   # Infirmary & Recreation

# Berapa hari streak sebelum efek buruk muncul
const BAD_STREAK_DAYS := 3
