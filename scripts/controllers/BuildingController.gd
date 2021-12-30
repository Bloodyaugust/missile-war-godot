extends Node

onready var building_entries:Array = Castledb.get_entries("buildings")

var _building_entry_dictionary:Dictionary = {}

func can_build(building_id:String, team:int) -> bool:
  var _building = _building_entry_dictionary[building_id]
  var _player_data

  if !Store.state.has("player_data_" + str(team)):
    return false

  _player_data = Store.state["player_data_" + str(team)]

  # check resource costs against bank
  if _building.cost_metal > _player_data.metal:
    return false

  if _building.cost_energy > _player_data.energy:
    return false

  # check against tech requirements
  for _requirement in _building.requirements:
    if !_player_data.techs.has(_requirement.tech):
      return false
  
  return true

func _ready():
  for _entry in building_entries:
    _building_entry_dictionary[_entry.id] = _entry
