extends Control

onready var _active_team_label:Label = find_node("ActiveTeam")
onready var _team0_button:Button = find_node("Team0")
onready var _team1_button:Button = find_node("Team1")

func _on_store_state_changed(state_key: String, substate) -> void:
  match state_key:
    "active_team":
      _active_team_label.text = "Active Team: " + str(substate)

func _on_team0_pressed() -> void:
  Store.set_state("active_team", 0)

func _on_team1_pressed() -> void:
  Store.set_state("active_team", 1)

func _input(event):
  if event.is_action_pressed("debug"):
    visible = !visible

func _ready():
  Store.connect("state_changed", self, "_on_store_state_changed")

  visible = false

  _team0_button.connect("pressed", self, "_on_team0_pressed")
  _team1_button.connect("pressed", self, "_on_team1_pressed")
