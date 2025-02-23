@tool
extends EditorPlugin

var export_plugin: HTMLExportPlugin

const LoaderEditor = preload("res://addons/custom-html-loader/Editor/LoaderEditor.tscn")
var loader_editor


func _enter_tree():
	# Initialization of the plugin goes here.
	export_plugin = load("res://addons/custom-html-loader/export_plugin.gd").new()
	add_export_plugin(export_plugin)
	
	# Init main screen scene
	loader_editor = LoaderEditor.instantiate()
	loader_editor.updated.connect(settings_update)
	EditorInterface.get_editor_main_screen().add_child(loader_editor)
	_make_visible(false)
	

func _exit_tree():
	# Clean-up of the plugin goes here.
	remove_export_plugin(export_plugin)


func _has_main_screen():
	return true
	
	
func _make_visible(visible):
	if loader_editor:
		loader_editor.visible = visible


func _get_plugin_name():
	return "LoaderEditor"
	

func _get_plugin_icon():
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")


func settings_update() -> void:
	export_plugin.settings = loader_editor.settings
