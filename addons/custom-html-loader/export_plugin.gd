@tool
extends EditorExportPlugin


var plugin_path: String = get_script().resource_path.get_base_dir()
var export_path := ""
var _features: Array

var settings: Dictionary

func _get_name():
	return "LoaderEditor"


func _export_begin(features: PackedStringArray , is_debug: bool, path: String, flags: int) -> void:
	export_path = path
	_features = features


func _export_end() -> void:
	if "web" in _features:
		var file := FileAccess.open(export_path, FileAccess.READ)
		var html := file.get_as_text()
		file.close()
		var back_color:String
		if settings.is_back_color:
			back_color = ProjectSettings.get_setting("application/boot_splash/bg_color").to_html()
		else:
			back_color = settings.back_color
		
		var status_text = "\n#status {
	background-color: #{back_color};
	display: flex;
	flex-direction: column;
	justify-content: center;
	align-items: center;
	visibility: hidden;
}
".format({"back_color": back_color})
		html = replace_bloc(r"\n#status {(\s.*?)*}", status_text, html)
		
		match settings.progress_type:
			"bar":
				var status_progress_text = "/* Общий стиль прогресс-бара */
\n#status-progress {
	bottom: 10%;
	width: 50%;
	height: {loader_width}px;
	margin: 0 auto;
	border-radius: {border_radius}px;
	overflow: hidden;
}

/* Цвет фона прогресс-бара (для Chrome, Safari) */
#status-progress::-webkit-progress-bar {
	background-color: #{loader_back_color}; /* цвет фона */
	border-radius: {border_radius}px;
}

/* Цвет заполненной части прогресс-бара (для Chrome, Safari) */
#status-progress::-webkit-progress-value {
	background-color: #{loader_progress_color}; /* цвет прогресса */
	border-radius: {border_radius}px;
}

/* Цвет заполненной части прогресс-бара (для Firefox) */
#status-progress::-moz-progress-bar {
	background-color: #{loader_progress_color}; /* цвет прогресса */
	border-radius: {border_radius}px;
}".format({"loader_back_color": settings.loader_back_color,
			"loader_progress_color": settings.loader_progress_color,
			"border_radius": settings.border_radius,
			"loader_width": settings.loader_width,
			})
				html = replace_bloc(r"\n#status-progress {(\s.*?)*}", status_progress_text, html)
			"circle":
				var status_progress_text = "/* Общий стиль прогресс-круга */
#status-progress {
	display: block;
	width: 50px;
	height: 50px;
	border: {loader_width}px solid #{loader_back_color};
	border-top: {loader_width}px solid #{loader_progress_color};
	border-radius: 50%;
	animation: spin 1s linear infinite;
	bottom: 10%;
	margin: 0 auto;
}

@keyframes spin {
	0% { transform: rotate(0deg); }
	100% { transform: rotate(360deg); }
}

".format({"loader_back_color": settings.loader_back_color,
			"loader_progress_color": settings.loader_progress_color,
			"border_radius": settings.border_radius,
			"loader_width": settings.loader_width,
			})
				html = replace_bloc(r"\n#status-progress {(\s.*?)*}", status_progress_text, html)
				
				html = replace_bloc(r'<progress id="status-progress"></progress>', '<div id="status-progress"></div>', html)
				
		file = FileAccess.open(export_path, FileAccess.WRITE)
		file.store_string(html)
		file.close()


func replace_bloc(reg:String, new_text:String ,text:String) -> String:
	var regex = RegEx.new()
	regex.compile(reg)
	var result_reg = regex.search(text)
	var pos_start = result_reg.get_start()
	var pos_end = result_reg.get_end()
	text = text.erase(pos_start, pos_end - pos_start)
	return text.insert(pos_start, new_text)


func on_editor_settings_updated(_settings:Dictionary):
	settings = _settings
	
