extends Node

signal state_changed(state_key, substate)

var persistent_store:PersistentStore
var state: Dictionary = {
  "client_view": "",
  "game": "",
  "selection": null,
 }

func add_player(team:int) -> void:
  set_state("player_data_" + str(team), {
    "alive": true,
    "energy": 0,
    "metal": 0,
    "techs": [],
  })

func gain_resource(resource:String, amount:float, team:int) -> void:
  var _player_data_key:String = "player_data_" + str(team)
  var _new_state:Dictionary = state[_player_data_key].duplicate(true)

  _new_state[resource] = _new_state[resource] + amount

  set_state(_player_data_key, _new_state)

func spend_resource(resource:String, amount:float, team:int) -> void:
  var _player_data_key:String = "player_data_" + str(team)
  var _new_state:Dictionary = state[_player_data_key].duplicate(true)

  _new_state[resource] = _new_state[resource] - amount

  set_state(_player_data_key, _new_state)

func start_game() -> void:
  set_state("client_view", ClientConstants.CLIENT_VIEW_NONE)
  set_state("game", GameConstants.GAME_STARTING)

func save_persistent_store() -> void:
  if ResourceSaver.save(ClientConstants.CLIENT_PERSISTENT_STORE_PATH, persistent_store) != OK:
    print("Failed to save persistent store")

func set_state(state_key: String, new_state) -> void:
  state[state_key] = new_state
  emit_signal("state_changed", state_key, state[state_key])

  if !"player_data" in state_key:
    print("State changed: ", state_key, " -> ", state[state_key])
  
func _initialize():
  set_state("client_view", ClientConstants.CLIENT_VIEW_SPLASH)
  set_state("game", GameConstants.GAME_OVER)
  set_state("selection", null)
  add_player(0)
  add_player(1)

func _ready():
  if Directory.new().file_exists(ClientConstants.CLIENT_PERSISTENT_STORE_PATH):
    persistent_store = load(ClientConstants.CLIENT_PERSISTENT_STORE_PATH)

  if !persistent_store:
    persistent_store = PersistentStore.new()
    save_persistent_store()

  call_deferred("_initialize")
