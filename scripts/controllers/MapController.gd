extends Node

const GRID_SIZE:float = 100.0

onready var _tree = get_tree()

func cell_building_allowed(position:Vector2) -> bool:
  var _buildings:Array = _tree.get_nodes_in_group("buildings")
  var _aligned_position:Vector2 = get_snapped_position(position)

  for _building in _buildings:
    if _building.global_position.distance_squared_to(_aligned_position) <= 0.1:
      return false

  return true

func get_snapped_position(position:Vector2) -> Vector2:
  var _possible_positions:Array = []
  var _closest_position:Vector2

  _possible_positions.append(Vector2(position.x - fmod(position.x, GRID_SIZE), position.y - fmod(position.y, GRID_SIZE)))
  _possible_positions.append(Vector2(position.x + fmod(position.x, GRID_SIZE), position.y - fmod(position.y, GRID_SIZE)))
  _possible_positions.append(Vector2(position.x + fmod(position.x, GRID_SIZE), position.y + fmod(position.y, GRID_SIZE)))
  _possible_positions.append(Vector2(position.x - fmod(position.x, GRID_SIZE), position.y + fmod(position.y, GRID_SIZE)))
  # TODO: Find closest possible grid position

  _closest_position = _possible_positions[0]
  for _possible_position in _possible_positions:
    if _possible_position.distance_squared_to(position) < _closest_position.distance_squared_to(position):
      _closest_position = _possible_position

  return _closest_position

func _align_scene_buildings() -> void:
  var _buildings:Array = _tree.get_nodes_in_group("buildings")

  for _building in _buildings:
    _building.global_position.x = _building.global_position.x - fmod(_building.global_position.x, GRID_SIZE)
    _building.global_position.y = _building.global_position.y - fmod(_building.global_position.y, GRID_SIZE)

func _ready():
  call_deferred("_align_scene_buildings")
