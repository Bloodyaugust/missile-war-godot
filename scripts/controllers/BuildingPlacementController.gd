extends Node2D

const _building_scene:PackedScene = preload("res://actors/Building.tscn")

onready var _buildings_container:Node = get_tree().get_root().find_node("Buildings", false) if get_tree().get_root().find_node("Buildings", false) else get_tree().get_root()

var _building_sprite:Sprite

func _initialize() -> void:
  _building_sprite = Sprite.new()
  _building_sprite.name = "BuildingSprite"
  _building_sprite.self_modulate = Color(1, 1, 1, 0.5)

  get_tree().get_root().add_child(_building_sprite)

func _input(event):
  if GDUtil.reference_safe(Store.state.building_card_selected) && event.is_action_pressed("building_place"):
    var _new_building:Node2D = _building_scene.instance()

    _new_building.team = 0
    _new_building.id = Store.state.building_card_selected.data.id
    _new_building.global_position = _building_sprite.global_position

    _buildings_container.add_child(_new_building)

func _on_store_state_changed(state_key: String, substate) -> void:
  match state_key:
    "building_card_selected":
      if GDUtil.reference_safe(substate):
        _building_sprite.visible = true
        _building_sprite.texture = load("res://sprites/buildings/" + substate.data.id + ".png")
      else:
        _building_sprite.visible = false

func _process(_delta):
  if GDUtil.reference_safe(Store.state.building_card_selected):
    _building_sprite.global_position = _building_sprite.get_global_mouse_position()

func _ready():
  Store.connect("state_changed", self, "_on_store_state_changed")

  call_deferred("_initialize")