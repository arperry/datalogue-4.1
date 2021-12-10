@tool
class_name DatalogueClassifForm
extends Control


signal request_close()
signal submitted(id: String, values: Array[String], mode: int)


@onready var _id_edit: LineEdit = $MainLayout/IdEdit
@onready var _value_edit: LineEdit = $MainLayout/InputLayout/ValueEdit
@onready var _value_list: ItemList = $MainLayout/ValueLayout/ValueList
@onready var _add_value_btn: Button = $MainLayout/InputLayout/AddValueBtn
@onready var _remove_value_btn: Button = $MainLayout/ValueLayout/ValueTools/RemoveValueBtn
@onready var _error_lbl: Label = $MainLayout/ErrorLbl
@onready var _create_btn: Button = $MainLayout/ButtonLayout/CreateBtn


var _mode := DlEnums.CREATE_MODE_NEW
var _validation: Callable = _default_validation
var _selected := -1


func clear() -> void:
	_create_btn.disabled = true
	_add_value_btn.disabled = true
	_remove_value_btn.disabled = true
	_id_edit.text = ""
	_value_edit.text = ""
	_value_list.clear()
	_error_lbl.text = ""
	_selected = -1


func set_mode(mode: int, validation: Callable) -> void:
	_mode = mode
	_validation = validation
	
	match mode:
		DlEnums.CREATE_MODE_NEW:
			_create_btn.text = "Create"
		DlEnums.CREATE_MODE_MODIFY:
			_create_btn.text = "Modify"
		DlEnums.CREATE_MODE_COPY:
			_create_btn.text = "Duplicate"


func _submit() -> void:
	_error_lbl.text = ""
	
	var values :=  _values_to_array()
	var error: String = _validation.call(_id_edit.text, values)
	if not error.is_empty():
		_error_lbl.text = error
	else:
		emit_signal("submitted", _id_edit.text, values, _mode)
		emit_signal("request_close")


func _add_value() -> void:
	if not _add_value_btn.disabled:
		_value_list.add_item(_value_edit.text)
		_value_list.deselect_all()
		_selected = -1
		_value_edit.text = ""
		_add_value_btn.disabled = true
		_remove_value_btn.disabled = true
		_update_create_btn()


func _update_create_btn() -> void:
	if _id_edit.text.is_empty() or _value_list.items_count <= 0:
		_create_btn.disabled = true
	else:
		_create_btn.disabled = false


func _values_to_array() -> Array[String]:
	var result: Array[String]
	
	for i in range(_value_list.items_count):
		result.append(_value_list.get_item_text(i))
	
	return result


func _default_validation(id: String, values: Array[String]) -> String:
	return "Internal error"


func _on_CreateBtn_pressed() -> void:
	_submit()


func _on_CancelBtn_pressed() -> void:
	emit_signal("request_close")


func _on_IdEdit_text_changed(new_text: String) -> void:
	_update_create_btn()


func _on_IdEdit_text_submitted(new_text: String) -> void:
	if not _create_btn.disabled:
		_submit()


func _on_IdEdit_text_change_rejected(rejected_substring: String) -> void:
	emit_signal("request_close")


func _on_ValueEdit_text_changed(new_text: String) -> void:
	if new_text.is_empty():
		_add_value_btn.disabled = true
	else:
		_add_value_btn.disabled = false


func _on_ValueEdit_text_submitted(new_text: String) -> void:
	_add_value()


func _on_AddValueBtn_pressed() -> void:
	_add_value()


func _on_ValueEdit_text_change_rejected(rejected_substring: String) -> void:
	_value_edit.text = ""
	_add_value_btn.disabled = true


func _on_ValueList_item_selected(index: int) -> void:
	_selected = index
	if _selected >= 0:
		_remove_value_btn.disabled = false
	else:
		_remove_value_btn.disabled = true


func _on_RemoveValueBtn_pressed() -> void:
	if _selected >= 0:
		_value_list.remove_item(_selected)
		_remove_value_btn.disabled = true
		_selected = -1
		_update_create_btn()
