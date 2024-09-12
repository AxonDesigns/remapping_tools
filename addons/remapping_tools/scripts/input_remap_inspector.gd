@tool
class_name InputRemapInspector extends EditorInspectorPlugin

var editor_interface: EditorInterface

var input_remap: InputRemap
var property: Dictionary
var remap_list: RemapList
var current_actions: Array[StringName]
var unfolded_actions: Array[StringName] = []
#var current_remaps: Dictionary

const REMAP_PROPERTY_PATH: String = "res://addons/remapping_tools/scenes/remap_property.tscn"

signal on_request_start_listening(event_index: int, key: StringName)

func init() -> void:
  if is_instance_valid(remap_list): remap_list.queue_free()
  remap_list = null

  remap_list = load("res://addons/remapping_tools/scenes/remap_list.tscn").instantiate() as RemapList
  remap_list.refresh_button.icon = editor_interface.get_base_control().get_theme_icon(&"Reload", &"EditorIcons")
  remap_list.add_button.icon = editor_interface.get_base_control().get_theme_icon(&"Add", &"EditorIcons")
  remap_list.add_button.pressed.connect(_on_add_button_pressed)
  remap_list.refresh_button.pressed.connect(func():
    refresh_property()
  )

func _on_add_button_pressed() -> void:
  var selected_action = current_actions[remap_list.input_option_button.get_selected_id()]
  if selected_action in input_remap.remaps: return

  InputMap.load_from_project_settings()
  var events := InputMap.action_get_events(selected_action)

  var new_remap := input_remap.remaps.duplicate()
  new_remap[selected_action] = events
  input_remap.remaps = new_remap
  refresh_property()

func _can_handle(object: Object) -> bool:
    return object is InputRemap

func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool) -> bool:
  if name != "remaps": return false
  init()
  input_remap = object as InputRemap
  refresh_property()
  add_custom_control(remap_list)
  return true

func refresh_property(new_actions: Array[StringName] = []) -> void:
  if remap_list == null: return

  for child in remap_list.properties.get_children():
    child.queue_free()
  
  if new_actions.is_empty():
    InputMap.load_from_project_settings()
  
  var unfiltered_actions := InputMap.get_actions() if new_actions.is_empty() else new_actions

  current_actions = unfiltered_actions.filter(func(action: String) -> bool:
    return not action.begins_with("ui_") and not input_remap.remaps.has(action)
  )

  remap_list.input_option_button.disabled = current_actions.is_empty()
  remap_list.add_button.disabled = current_actions.is_empty()
  
  for action_key: StringName in input_remap.remaps.keys():
    var remap_property := load(REMAP_PROPERTY_PATH).instantiate() as RemapProperty
    remap_property.action_name.text = action_key
    remap_property.action_name.modulate = Color.WHITE if unfiltered_actions.has(action_key) else Color.YELLOW
    remap_property.folded = not unfolded_actions.has(action_key) or input_remap.remaps[action_key].is_empty()
    remap_property.warning_icon.visible = not unfiltered_actions.has(action_key)
    remap_property.delete_button.pressed.connect(_on_property_delete.bind(action_key))
    remap_property.input_events = input_remap.remaps[action_key] as Array[InputEvent]
    remap_property.event_requested_delete.connect(_on_event_requested_delete.bind(action_key))
    remap_property.add_button.pressed.connect(_on_add_event.bind(action_key))
    remap_property.fold_changed.connect(_on_property_fold_changed.bind(action_key))
    remap_property.event_requested_listening.connect(_on_event_requested_listening.bind(action_key))
    remap_property.init(editor_interface.get_base_control())
    remap_list.properties.add_child(remap_property)

  remap_list.input_option_button.clear()
  for action in current_actions:
    remap_list.input_option_button.add_item(action)

func _on_property_delete(key: StringName) -> void:
  if unfolded_actions.has(key):
    unfolded_actions.erase(key)
  
  input_remap.remaps.erase(key)
  refresh_property()

func _on_event_requested_delete(event: InputEvent, key: StringName) -> void:
  var new_remap := input_remap.remaps.duplicate()
  new_remap[key].erase(event)
  input_remap.remaps = new_remap
  refresh_property()

func _on_event_requested_listening(event_index: int, key: StringName) -> void:
  on_request_start_listening.emit(event_index, key)

func _on_add_event(key: StringName) -> void:
  var new_remap := input_remap.remaps.duplicate()
  new_remap[key].append(InputEventKey.new())
  input_remap.remaps = new_remap
  if not unfolded_actions.has(key):
    unfolded_actions.append(key)
  refresh_property()

func _on_property_fold_changed(value: bool, key: StringName) -> void:
  if not value:
    if unfolded_actions.has(key): return
    unfolded_actions.append(key)
  else:
    unfolded_actions.erase(key)

func on_receive_input(prev_event_index: int, event: InputEvent, key: StringName) -> void:
  var new_remap := input_remap.remaps.duplicate()
  new_remap[key][prev_event_index] = event
  input_remap.remaps = new_remap
  refresh_property()

func on_stop_listening(event_index: int, key: StringName) -> void:
  refresh_property()