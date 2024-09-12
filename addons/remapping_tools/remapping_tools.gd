@tool
extends EditorPlugin

var input_remap_inspector: InputRemapInspector
var last_actions: Array[StringName]
var listening: bool = false
var action_key: StringName = ""
var prev_event_index: int = -1

func _enter_tree() -> void:
	#get_editor_interface().get_editor_settings().settings_changed.connect(_on_input_map_changed)
	project_settings_changed.connect(_on_project_settings_changed)
	
	input_remap_inspector = InputRemapInspector.new()
	input_remap_inspector.on_request_start_listening.connect(_on_request_start_listening)
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


func _on_request_start_listening(event_index: int, key: StringName) -> void:
	prev_event_index = event_index
	action_key = key
	listening = true

func _input(event: InputEvent) -> void:
	if not listening: return
	if event is InputEventKey:
		if event.is_pressed():
			if event.keycode != KEY_ESCAPE:
				input_remap_inspector.on_receive_input(prev_event_index, event, action_key)
			else:
				input_remap_inspector.on_stop_listening(prev_event_index, action_key)

			listening = false
			action_key = ""
			prev_event_index = -1
			get_viewport().set_input_as_handled()