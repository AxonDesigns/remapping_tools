@tool
extends EditorPlugin

var input_remap_inspector: InputRemapInspector
var last_actions: Array[StringName]

func _enter_tree() -> void:
	#get_editor_interface().get_editor_settings().settings_changed.connect(_on_input_map_changed)
	project_settings_changed.connect(_on_project_settings_changed)
	
	input_remap_inspector = InputRemapInspector.new()
	input_remap_inspector.editor_interface = get_editor_interface()
	add_inspector_plugin(input_remap_inspector)


func _exit_tree() -> void:
	if is_instance_valid(input_remap_inspector):
		remove_inspector_plugin(input_remap_inspector)

func _on_project_settings_changed() -> void:
	InputMap.load_from_project_settings()
	var new_actions := InputMap.get_actions()

	if last_actions != new_actions:
		input_remap_inspector.refresh_property(new_actions)
		last_actions = new_actions