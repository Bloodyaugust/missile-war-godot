extends Control

const _building_card:PackedScene = preload("res://views/components/BuildingCard.tscn")

onready var _building_screen:Control = find_node("Building")
onready var _construction_screen:Control = find_node("Construction")

onready var _info_container:Control = find_node("Info")
onready var _info_description:Label = _info_container.find_node("Description")
onready var _info_icon:TextureRect = _info_container.find_node("Icon")
onready var _info_name:Label = _info_container.find_node("Name")
onready var _info_health_progress:ProgressBar = _info_container.find_node("HealthProgress")
onready var _info_reload_progress:ProgressBar = _info_container.find_node("ReloadProgress")

onready var _status_container:Control = find_node("Status")
onready var _status_health:Label = _status_container.find_node("Health")
onready var _status_battery:Label = _status_container.find_node("Battery")
onready var _status_energy:Label = _status_container.find_node("Energy")
onready var _status_metal:Label = _status_container.find_node("Metal")

onready var _defense_buildings:GridContainer = _construction_screen.find_node("DefenseBuildings")
onready var _resource_buildings:GridContainer = _construction_screen.find_node("ResourceBuildings")
onready var _silo_buildings:GridContainer = _construction_screen.find_node("SiloBuildings")
onready var _tech_buildings:GridContainer = _construction_screen.find_node("TechBuildings")
onready var _misc_buildings:GridContainer = _construction_screen.find_node("MiscBuildings")

func _input(event):
  if event.is_action_pressed("ui_cancel"):
    if GDUtil.reference_safe(Store.state.selection):
      Store.set_state("selection", null)

    if GDUtil.reference_safe(Store.state.building_card_selected):
      Store.set_state("building_card_selected", null)

func _on_state_changed(state_key: String, substate):
  match state_key:
    "selection":
      if GDUtil.reference_safe(substate):
        _show_building_screen()
        Store.set_state("building_card_selected", null)
      else:
        _show_construction_screen()

func _show_building_screen() -> void:
  _construction_screen.visible = false
  _building_screen.visible = true

  _update_building_screen()

func _show_construction_screen() -> void:
  _building_screen.visible = false
  _construction_screen.visible = true

func _process(_delta):
  if GDUtil.reference_safe(Store.state.selection):
    _update_building_screen()
  else:
    if Store.state.selection != null:
      Store.set_state("selection", null)

func _ready():
  var _building_entries:Array = Castledb.get_entries("buildings")

  Store.connect("state_changed", self, "_on_state_changed")

  GDUtil.queue_free_children(_resource_buildings)

  for _building in _building_entries:
    var _new_building_card:Control = _building_card.instance()

    _new_building_card.data = _building

    match _building.type:
      "defense":
        _defense_buildings.add_child(_new_building_card)

      "resource":
        _resource_buildings.add_child(_new_building_card)

      "silo":
        _silo_buildings.add_child(_new_building_card)

      "tech":
        _tech_buildings.add_child(_new_building_card)
      
      _:
        _misc_buildings.add_child(_new_building_card)


func _update_building_screen() -> void:
  var _building:Node2D = Store.state.selection

  _info_description.text = _building.data.type
  _info_icon.texture = load("res://sprites/buildings/" + _building.data.id + ".png")
  _info_name.text = _building.data.id
  _info_health_progress.value = clamp(lerp(0, 100, _building._current_health / _building.data.health), 0, 100)
  _status_health.text = "Health: " + str(int(round(_building._current_health))) + "/" + str(int(round(_building.data.health)))

  if _building.data.type == "silo":
    _info_reload_progress.visible = true
    _info_reload_progress.value = clamp(lerp(100, 0, _building._time_to_reloaded / _building.data.reload_time), 0, 100)
  else:
    _info_reload_progress.visible = false

  if _building.data.battery > 0:
    _status_battery.visible = true
    _status_battery.text = "Battery: " + str(int(round(_building._current_battery))) + "/" + str(int(round(_building.data.battery)))
  else:
    _status_battery.visible = false

  if _building.data.resource_rate_energy > 0:
    _status_energy.visible = true
    _status_energy.text = "Energy: " + str(stepify(_building.data.resource_rate_energy, 0.1)) + "/min"
  else:
    _status_energy.visible = false

  if _building.data.resource_rate_metal > 0:
    _status_metal.visible = true
    _status_metal.text = "Metal: " + str(stepify(_building.data.resource_rate_metal, 0.1)) + "/min"
  else:
    _status_metal.visible = false
