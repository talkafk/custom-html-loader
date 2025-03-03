@tool
extends MarginContainer

signal updated()


var settings = {
	"is_back_color": false,
	"back_color": "",
	"loader_back_color": "",
	"loader_progress_color": "",
	"border_radius": 0,
	"loader_width": 10,
	"progress_type": "circle",
}


func _ready() -> void:
	_load_config()
	updated.emit()


func _on_back_color_color_changed(color:Color) -> void:
	settings.back_color = color.to_html()
	updated.emit()
	_save_config()


func _on_loader_color_color_changed(color) -> void:
	settings.loader_progress_color = color.to_html()
	updated.emit()
	_save_config()


func _on_loader_back_color_color_changed(color) -> void:
	settings.loader_back_color = color.to_html()
	updated.emit()
	_save_config()


func _on_border_radius_value_changed(value) -> void:
	settings.border_radius = value
	updated.emit()
	_save_config()



func _on_loader_width_value_changed(value) -> void:
	settings.loader_width = value
	updated.emit()
	_save_config()

func _save_config() -> void:
	var config = ConfigFile.new()
	for key in settings.keys():
		config.set_value("config", key, settings[key])
	config.save("res://addons/custom-html-loader/Editor/settings.cfg")


func _load_config() -> void:
	var config = ConfigFile.new()
	var err = config.load("res://addons/custom-html-loader/Editor/settings.cfg")
	if err != OK:
		_save_config()
		return
	for key in config.get_section_keys("config"):
		settings[key] = config.get_value("config", key)
	update_ui()
	
@onready var loader_type = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer3/loader_type
@onready var border_radius = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer5/border_radius


func _on_option_button_item_selected(index) -> void:
	settings.progress_type = loader_type.get_item_text(index)
	_update_progress_type_ui()
	updated.emit()
	_save_config()


func update_ui() -> void:
	$PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/back_color.color = Color.html(settings.back_color)
	$PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/loader_color.color = Color.html(settings.loader_progress_color)
	$PanelContainer/MarginContainer/VBoxContainer/HBoxContainer4/loader_back_color.color = Color.html(settings.loader_back_color)
	border_radius.value = settings.border_radius
	$PanelContainer/MarginContainer/VBoxContainer/HBoxContainer6/loader_width.value = settings.loader_width
	$PanelContainer/MarginContainer/VBoxContainer/HBoxContainer7/IsBackFromPS.button_pressed = settings.is_back_color
	_update_progress_type_ui()
	_update_is_back_ui()


func _update_progress_type_ui() -> void:
	match settings.progress_type:
		"circle":
			$PanelContainer/MarginContainer/VBoxContainer/HBoxContainer5.hide()
			loader_type.select(1)
		"bar":
			$PanelContainer/MarginContainer/VBoxContainer/HBoxContainer5.show()
			loader_type.select(0)


func _on_is_back_from_ps_toggled(toggled_on: bool) -> void:
	settings.is_back_color = toggled_on
	_update_is_back_ui()
	updated.emit()
	_save_config()
	
	
func _update_is_back_ui() -> void:
	if settings.is_back_color:
		$PanelContainer/MarginContainer/VBoxContainer/HBoxContainer.hide()
	else:
		$PanelContainer/MarginContainer/VBoxContainer/HBoxContainer.show()
		
