extends Node

var team:int

var _command_building:Node2D

func _on_command_destroyed(data:Dictionary, team_index:int) -> void:
  print("AI on team " + str(team_index) + " lost their command building")

func _ready():
  var _buildings:Array = get_tree().get_nodes_in_group("buildings")

  for _building in _buildings:
    if _building.id == "command" && _building.team == team:
      _command_building = _building
      print("AI on team " + str(team) + " found command building")

      _command_building.connect("destroyed", self, "_on_command_destroyed")
