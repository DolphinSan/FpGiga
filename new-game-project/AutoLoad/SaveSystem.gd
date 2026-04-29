extends Node

#  SaveSystem ke JSON, 3 slot.

const SAVE_DIR     := "user://saves/"
const SAVE_VERSION := 1

signal save_completed(slot: int)
signal load_completed(slot: int)
signal save_failed(slot: int, reason: String)
signal load_failed(slot: int, reason: String)

# save

func save_game(slot: int) -> void:
	_ensure_dir()
	var data          := GameState.to_dict()
	data["_version"]  = SAVE_VERSION
	data["_saved_at"] = Time.get_datetime_string_from_system()
	data["_slot"]     = slot

	var file := FileAccess.open(_path(slot), FileAccess.WRITE)
	if file == null:
		emit_signal("save_failed", slot, "Error membuka file: %d" % FileAccess.get_open_error())
		return

	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	emit_signal("save_completed", slot)

# Auto Save
func auto_save(slot: int = 0) -> void:
	_ensure_dir()
	var data          := GameState.to_dict()
	data["_version"]  = SAVE_VERSION
	data["_saved_at"] = Time.get_datetime_string_from_system()
	data["_auto"]     = true

	var file := FileAccess.open(_path(slot), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()

# Load

func load_game(slot: int) -> void:
	if not FileAccess.file_exists(_path(slot)):
		emit_signal("load_failed", slot, "Save tidak ditemukan.")
		return

	var file := FileAccess.open(_path(slot), FileAccess.READ)
	if file == null:
		emit_signal("load_failed", slot, "Tidak bisa membaca file save.")
		return

	var raw  := file.get_as_text()
	file.close()

	var json := JSON.new()
	if json.parse(raw) != OK:
		emit_signal("load_failed", slot, "File save rusak (baris %d)." % json.get_error_line())
		return

	var data: Dictionary = json.get_data()
	if data.get("_version", 0) != SAVE_VERSION:
		push_warning("[SaveSystem] Versi save berbeda — beberapa data mungkin tidak kompatibel.")

	GameState.from_dict(data)
	emit_signal("load_completed", slot)

#Slot Info

func get_all_slots() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for i in range(3):
		result.append(get_slot_info(i))
	return result


func get_slot_info(slot: int) -> Dictionary:
	var empty := { "slot": slot, "exists": false, "saved_at": "",
				   "fase": 0, "hari": 0, "child_name": "" }

	if not FileAccess.file_exists(_path(slot)):
		return empty

	var file := FileAccess.open(_path(slot), FileAccess.READ)
	if file == null:
		return empty

	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		file.close()
		return empty
	file.close()

	var d: Dictionary = json.get_data()
	return {
		"slot":       slot,
		"exists":     true,
		"saved_at":   d.get("_saved_at",   ""),
		"fase":       d.get("fase",         0),
		"hari":       d.get("hari",         0),
		"child_name": d.get("child_name",   ""),
	}


func slot_exists(slot: int) -> bool:
	return FileAccess.file_exists(_path(slot))


func delete_slot(slot: int) -> void:
	if slot_exists(slot):
		DirAccess.remove_absolute(_path(slot))

# Helper

func _path(slot: int) -> String:
	return SAVE_DIR + "slot_%d.json" % slot


func _ensure_dir() -> void:
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(SAVE_DIR)
