extends Control

onready var _active_team_label:Label = find_node("ActiveTeam")
onready var _add_team:Button = find_node("AddTeam")
onready var _team_buttons:Control = find_node("TeamButtons")

func _on_store_state_changed(state_key: String, substate) -> void:
  match state_key:
    "active_team":
      _active_team_label.text = "Active Team: " + str(substate)
    "debug":
      visible = substate

func _on_active_team_set_pressed(team:int) -> void:
  Store.set_state("active_team", team)

func _on_add_team_pressed() -> void:
  var _num_teams:int = 0

  for _key in Store.state.keys():
    if "player_data_" in _key:
      _num_teams += 1

  Store.add_player(_num_teams, true)
  _update_team_buttons()

func _update_team_buttons() -> void:
  GDUtil.queue_free_children(_team_buttons)

  var _team_index:int = 0
  for _key in Store.state.keys():
    if "player_data_" in _key:
      var _new_button:Button = Button.new()

      _new_button.text = "Team " + str(_team_index)
      _new_button.connect("pressed", self, "_on_active_team_set_pressed", [_team_index])
      _team_index += 1

      _team_buttons.add_child(_new_button)


func _input(event):
  if event.is_action_pressed("debug"):
    Store.set_state("debug", !Store.state.debug)

func _ready():
  Store.connect("state_changed", self, "_on_store_state_changed")

  visible = false

  _add_team.connect("pressed", self, "_on_add_team_pressed")
