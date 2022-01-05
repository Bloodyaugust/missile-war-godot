extends Node

const GRID_SIZE:float = 100.0
const grid_scene:PackedScene = preload("res://doodads/Grid.tscn")

onready var _tree = get_tree()

var _grid:TileMap

func cell_building_allowed(position:Vector2) -> bool:
  var _buildings:Array = _tree.get_nodes_in_group("buildings")
  var _aligned_position:Vector2 = get_snapped_position(position)

  for _building in _buildings:
    if _building.global_position.distance_squared_to(_aligned_position) <= 0.1:
      return false

  return true

func get_snapped_position(position:Vector2) -> Vector2:
  return _grid.to_global(_grid.map_to_world((_grid.world_to_map(position)))) + Vector2(GRID_SIZE / 2, GRID_SIZE / 2)

func _align_scene_buildings() -> void:
  var _buildings:Array = _tree.get_nodes_in_group("buildings")
  _grid = grid_scene.instance()
  _grid.cell_size = Vector2(GRID_SIZE, GRID_SIZE)

  _tree.get_root().add_child(_grid)

  for _building in _buildings:
    _building.global_position = get_snapped_position(_building.global_position)

func _ready():
  call_deferred("_align_scene_buildings")
