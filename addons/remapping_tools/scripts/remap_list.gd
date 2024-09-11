@tool
class_name RemapList extends VBoxContainer

var properties: VBoxContainer:
  get: return get_node("%Properties") as VBoxContainer

var add_button: Button:
  get: return get_node("%AddButton") as Button

var input_option_button: OptionButton:
  get: return get_node("%InputOptionButton") as OptionButton

var refresh_button: Button:
  get: return get_node("%RefreshButton") as Button

func init() -> void:
  pass