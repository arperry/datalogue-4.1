@tool
class_name DatalogueCreateForm
extends Control


signal request_close()


@onready var _id_edit: LineEdit = $MainLayout/IdEdit
@onready var _error_lbl: Label = $MainLayout/ErrorLbl
@onready var _create_btn: Button = $MainLayout/ButtonLayout/CreateBtn


func clear() -> void:
	_clear_field()
	_clear_error()


func _clear_field() -> void:
	_id_edit.text = ""


func _clear_error() -> void:
	_error_lbl.text = ""


func _on_CreateBtn_pressed():
	_clear_error()
	
	var error := Datalogue.validate_db_id(_id_edit.text)
	if not error.is_empty():
		_error_lbl.text = error
	else:
		Datalogue.create_db(_id_edit.text)
		emit_signal("request_close")


func _on_CancelBtn_pressed():
	emit_signal("request_close")


func _on_IdEdit_text_changed(new_text):
	if _id_edit.text.is_empty():
		_create_btn.disabled = true
	else:
		_create_btn.disabled = false