@tool
class_name RemapEventTile extends HBoxContainer

var event_button: Button:
  get: return get_node("%EventButton") as Button

var delete_button: Button:
  get: return get_node("%DeleteButton") as Button

var editor_control: Control

func init(editor_control: Control):
  self.editor_control = editor_control
  #event_button.icon = editor_control.get_theme_icon(&"Event", &"EditorIcons")
  delete_button.icon = editor_control.get_theme_icon(&"Remove", &"EditorIcons")