extends Node

const _debug_view_scene:PackedScene = preload("res://views/Debug.tscn")

var _debug_view

func _initialize():
  var _root = get_tree().get_root()

  _debug_view = _debug_view_scene.instance()
  _root.add_child(_debug_view)

func _ready():
  call_deferred("_initialize")
