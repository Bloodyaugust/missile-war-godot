extends Node2D

signal destroyed(data, team)
signal resource_generated(resource, amount, team)

export var id:String
export var team:int

onready var data:Dictionary = Castledb.get_entry("buildings", id)

onready var _collider:Area2D = $"./Collider"
onready var _building_sprite:Sprite = $"./Sprite"
onready var _range_area2d:Area2D = $"./RangeArea2D"
onready var _selection_indicator:ColorRect = $"./SelectionIndicator"

var _clip_index:int
var _clip_interval:float
var _current_battery:float
var _current_health:float
var _dead:bool
var _target:Node2D
var _time_to_reloaded:float

func damage(amount:float) -> void:
  _current_health = clamp(_current_health - amount, 0, data.health)

func die() -> void:
  if !_dead:
    _dead = true
    emit_signal("destroyed", data, team)
    queue_free()

func fire() -> void:
  if _time_to_reloaded <= 0:
    if _clip_interval <= 0:
      var _new_projectile = load("res://actors/Projectile.tscn").instance()

      _new_projectile.id = data.clips[_clip_index].projectile
      _new_projectile.target = _target
      _new_projectile.team = team
      _new_projectile.global_position = global_position

      get_tree().get_root().call_deferred("add_child", _new_projectile)

      _clip_index += 1

      if _clip_index == data.clips.size():
        _clip_index = 0
        _clip_interval = 0
        _time_to_reloaded = data.reload_time
      else:
        _clip_interval = data.clips[_clip_index - 1].interval

func repair(amount:float) -> void:
  _current_health = clamp(_current_health + amount, 0, data.health)

func targetable() -> bool:
  return !_dead

func _find_target() -> void:
  var _overlapping_areas:Array = _range_area2d.get_overlapping_areas()

  for _area in _overlapping_areas:
    var _potential_target = _area.get_owner()

    match data.type:
      "defense":
        if _potential_target.team != team && _potential_target.is_in_group("projectiles") && GDUtil.reference_safe(_potential_target):
          _target = _potential_target
          return

      "silo":
        if _potential_target.team != team && _potential_target.is_in_group("buildings") && GDUtil.reference_safe(_potential_target):
          _target = _potential_target
          return

  return

func _on_collider_input_event(_viewport:Node, event:InputEvent, _shape_index:int):
  if event is InputEventMouseButton && event.is_pressed():
    Store.set_state("selection", self)

func _process(delta):
  if !_dead:
    _clip_interval = clamp(_clip_interval - delta, 0, _clip_interval)
    _current_battery = clamp(_current_battery + (data.recharge_rate * delta), 0, data.battery)
    _time_to_reloaded = clamp(_time_to_reloaded - delta, 0, data.reload_time)

    match data.type:
      "resource":
        if data.resource_rate_energy > 0:
          emit_signal("resource_generated", "energy", delta * data.resource_rate_energy, team)
          Store.gain_resource("energy", delta * data.resource_rate_energy, team)
        if data.resource_rate_metal > 0:
          emit_signal("resource_generated", "metal", delta * data.resource_rate_metal, team)
          Store.gain_resource("metal", delta * data.resource_rate_metal, team)

      "silo":
        if GDUtil.reference_safe(_target) && _target.targetable() && _target.global_position.distance_to(global_position) <= data.range:
          fire()
        else:
          _find_target()

      "defense":
        if GDUtil.reference_safe(_target) && _target.targetable() && _target.global_position.distance_to(global_position) <= data.range:
          fire()
        else:
          _find_target()

      _:
        pass

    if _current_health <= 0:
      die()

func _ready():
  _collider.connect("input_event", self, "_on_collider_input_event")

  _building_sprite.texture = load("res://sprites/buildings/" + id + ".png")

  _current_battery = 0
  _current_health = data.health
  _dead = false
  if data.range > 0:
    var _range_shape:CircleShape2D = CircleShape2D.new()

    _range_shape.radius = data.range

    _range_area2d.shape_owner_clear_shapes(0)
    _range_area2d.shape_owner_add_shape(0, _range_shape)

  _time_to_reloaded = data.reload_time

  add_to_group(data.type)
