extends Control

const SELF_MODULATE_IDLE:Color = Color("ffffff")
const SELF_MODULATE_SELECTED:Color = Color("fffd90")

var data:Dictionary

onready var _icon:TextureRect = find_node("Icon")
onready var _name:Label = find_node("Name")
onready var _energy:Label = find_node("Energy")
onready var _metal:Label = find_node("Metal")

func _gui_input(event):
  if event.is_action_pressed("ui_select") || (event is InputEventMouseButton && event.button_index == BUTTON_LEFT && event.is_pressed()):
    Store.set_state("building_card_selected", self)

func _on_store_state_changed(state_key: String, substate) -> void:
  match state_key:
    "building_card_selected":
      if GDUtil.reference_safe(substate) && substate == self:
        self_modulate = SELF_MODULATE_SELECTED
      else:
        self_modulate = SELF_MODULATE_IDLE

func _ready():
  Store.connect("state_changed", self, "_on_store_state_changed")

  _icon.texture = load("res://sprites/buildings/" + data.id + ".png")
  _name.text = data.id
  _energy.text = "Energy: " + str(data.cost_energy)
  _metal.text = "Metal: " + str(data.cost_metal)
