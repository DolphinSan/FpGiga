class_name GameConstants

enum Fase    { SD = 1, SMP = 2, SMA = 3 }
enum Waktu   { PAGI, SIANG, MALAM }
enum Mood    { AWFUL = 0, BAD = 1, BIASA = 2, GOOD = 3, GREAT = 4 }
enum Mental  { RUSAK = 0, BIASA = 1, SANGAT_SEHAT = 2 }
enum Passion { BELUM_DIKETAHUI = 0, OLAHRAGA = 1, AKADEMIK = 2, SENI = 3, MUSIK = 4 }

enum Ending {
	NONE,
	SUKSES_AKADEMIK,
	NORMAL,
	NORMAL_TIDAK_JELAS,
	PEMALAS,
	SUKSES_PASSION,
	MEMBERONTAK,
	DEPRESI,
	MANDIRI_BAHAGIA,
	TRUE_ENDING,
}

enum Aksi {
	NONE,
	NURTURE_1,
	NURTURE_2,
	NURTURE_3,
	NURTURE_4,
	NURTURE_5,
	REST,
	RECREATION,
	INFIRMARY,
	LOMBA
}

const AP_PAGI   := 3
const AP_SIANG  := 4
const AP_MALAM  := 4

const AP_COST_DEFAULT := 1
const AP_COST_SPECIAL := 2

const BAD_STREAK_DAYS := 3

# Nama display untuk passion
const PASSION_NAMA := {
	Passion.BELUM_DIKETAHUI: "?",
	Passion.OLAHRAGA:        "Olahraga",
	Passion.AKADEMIK:        "Akademik",
	Passion.SENI:            "Seni",
	Passion.MUSIK:           "Musik",
}
