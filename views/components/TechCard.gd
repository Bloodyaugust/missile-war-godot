extends Control

const MODULATE_IDLE:Color = Color("ffffff")
const MODULATE_NOT_PURCHASABLE:Color = Color("474747")

var data:Dictionary

onready var _icon:TextureRect = find_node("Icon")
onready var _name:Label = find_node("Name")
onready var _description:Label = find_node("Description")

var _clickable:bool = false

func _gui_input(event):
  if (event.is_action_pressed("ui_select") || (event is InputEventMouseButton && event.button_index == BUTTON_LEFT && event.is_pressed())) && _clickable:
    Store.state.selection.upgrade(data)

func _on_store_state_changed(state_key: String, substate) -> void:
  if "player_data_" + str(Store.state.active_team) == state_key:
    if substate.techs.has(data.id) || substate.energy < data.cost_energy:
      modulate = MODULATE_NOT_PURCHASABLE
      _clickable = false
    else:
      modulate = MODULATE_IDLE
      _clickable = true

func _ready():
  Store.connect("state_changed", self, "_on_store_state_changed")

  _icon.texture = load("res://sprites/techs/" + data.id + ".png")
  _name.text = data.id
  _description.text = "Energy: " + str(data.cost_energy) + "\r\n" + "Time: " + str(data.time)
