extends Control

var data:Dictionary

onready var _icon:TextureRect = find_node("Icon")
onready var _name:Label = find_node("Name")
onready var _energy:Label = find_node("Energy")
onready var _metal:Label = find_node("Metal")

func _ready():
  _icon.texture = load("res://sprites/buildings/" + data.id + ".png")
  _name.text = data.id
  _energy.text = "Energy: " + str(data.cost_energy)
  _metal.text = "Metal: " + str(data.cost_metal)
