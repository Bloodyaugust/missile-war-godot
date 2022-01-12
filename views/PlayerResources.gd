extends Control

onready var _energy_label:Label = find_node("Energy")
onready var _tech_label:Label = find_node("Tech")
onready var _metal_label:Label = find_node("Metal")

func _update_screen() -> void:
  var _player_data = Store.state["player_data_" + str(Store.state.active_team)]

  _energy_label.text = "Energy: " + str(stepify(_player_data.energy, 0.1))
  _metal_label.text = "Metal: " + str(stepify(_player_data.metal, 0.1))

  if _player_data.techs.keys().size() > 0:
    var _tech_list = ""
    _tech_label.visible = true
    for _tech in _player_data.techs.keys():
      _tech_list += _tech + "\r\n"
    _tech_label.text = _tech_list
  else:
    _tech_label.visible = false

func _on_store_state_changed(state_key:String, substate) -> void:
  match state_key:
    "active_team":
      _update_screen()

  if "player_data" in state_key:
    _update_screen()


func _ready():
  Store.connect("state_changed", self, "_on_store_state_changed") 
