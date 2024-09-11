@tool
class_name RemapProperty extends PanelContainer

var action_name: Label:
  get: return get_node("%ActionName") as Label

var delete_button: Button:
  get: return get_node("%DeleteButton") as Button

var add_button: Button:
  get: return get_node("%AddButton") as Button

var fold_button: Button:
  get: return get_node("%FoldButton") as Button

var fold_icon: TextureRect:
  get: return get_node("%FoldIcon") as TextureRect

var events: VBoxContainer:
  get: return get_node("%Events") as VBoxContainer

var events_panel: PanelContainer:
  get: return get_node("%EventsPanel") as PanelContainer

var warning_icon: TextureRect:
  get: return get_node("%WarningIcon") as TextureRect

const FOLDED_ICON_NAME: StringName = &"CodeFoldedRightArrow"
const UNFOLDED_ICON_NAME: StringName = &"CodeFoldDownArrow"
const EVENT_TILE_PATH: String = "res://addons/remapping_tools/scenes/remap_event_tile.tscn"

signal event_requested_delete(event: InputEvent)
signal fold_changed(value: bool)

var folded: bool = true
var editor_control: Control
var input_events: Array[InputEvent]

func init(editor_control: Control) -> void:
  self.editor_control = editor_control
  fold_icon.texture = editor_control.get_theme_icon(FOLDED_ICON_NAME, &"EditorIcons")
  delete_button.icon = editor_control.get_theme_icon(&"Remove", &"EditorIcons")
  add_button.icon = editor_control.get_theme_icon(&"Add", &"EditorIcons")
  warning_icon.texture = editor_control.get_theme_icon(&"NodeWarning", &"EditorIcons")
  fold_icon.modulate = Color.TRANSPARENT if input_events.is_empty() else Color.WHITE
  add_button.pressed.connect(_on_add_button_pressed)
  fold_button.pressed.connect(_on_fold_button_pressed)

  var icon_name := FOLDED_ICON_NAME if folded else UNFOLDED_ICON_NAME
  fold_icon.texture = editor_control.get_theme_icon(icon_name, &"EditorIcons")
  events_panel.visible = not folded

  for event in input_events:
    var event_tile := load(EVENT_TILE_PATH).instantiate() as RemapEventTile
    event_tile.init(editor_control)
    event_tile.event_button.text = event.as_text()
    event_tile.delete_button.pressed.connect(_on_event_tile_delete.bind(event))
    events.add_child(event_tile)


func _on_fold_button_pressed() -> void:
  if input_events.is_empty(): return
  _set_fold(not folded)

func _on_add_button_pressed() -> void:
  _set_fold(false)

func _on_event_tile_delete(event: InputEvent) -> void:
  event_requested_delete.emit(event)

func _set_fold(value: bool) -> void:
  folded = value
  var icon_name := FOLDED_ICON_NAME if folded else UNFOLDED_ICON_NAME
  fold_icon.texture = editor_control.get_theme_icon(icon_name, &"EditorIcons")
  events_panel.visible = not folded
  fold_changed.emit(folded)