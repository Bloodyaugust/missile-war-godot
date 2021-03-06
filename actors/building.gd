extends Node2D

signal destroyed(data, team)
signal resource_generated(resource, amount, team)

export var id:String
export var team:int

onready var data:Dictionary = Castledb.get_entry("buildings", id)

onready var _collider:Area2D = $"./Collider"
onready var _building_sprite:Sprite = $"./Sprite"
onready var _selection_indicator:ColorRect = $"./SelectionIndicator"
onready var _tree = get_tree()

var _clip_index:int
var _clip_interval:float
var _current_battery:float
var _current_health:float
var _dead:bool
var _target:Node2D
var _time_to_reloaded:float
var _upgrade_time:float
var _upgrade:Dictionary

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

func upgrade(tech:Dictionary) -> void:
  var _has_tech:bool = false

  for _tech in data.techs:
    if _tech.tech == tech.id:
      _has_tech = true
      break
  
  if !_has_tech:
    return

  if _upgrade_time <= 0 && !Store.state["player_data_" + str(team)].techs.has(tech):
    _upgrade_time = tech.time
    _upgrade = tech

func _draw():
  if Store.state.debug:
    draw_arc(Vector2.ZERO, data.range, 0, 2 * PI, 12, Color.red)

  if data.type == "shield":
    draw_arc(Vector2.ZERO, data.range, 0, 2 * PI, 12, Color.blue)

func _find_target() -> void:
  var _targets:Array

  match data.type:
    "defense":
      _targets = _tree.get_nodes_in_group("projectiles")
      for _potential_target in _targets:
        if _potential_target.team != team && GDUtil.reference_safe(_potential_target) && _potential_target.targetable() && _potential_target.global_position.distance_to(global_position) <= data.range:
          _target = _potential_target
          return
    "silo":
      _targets = _tree.get_nodes_in_group("buildings")
      for _potential_target in _targets:
        if _potential_target.team != team && GDUtil.reference_safe(_potential_target) && _potential_target.targetable() && _potential_target.global_position.distance_to(global_position) <= data.range:
          _target = _potential_target
          return

  return

func _on_collider_input_event(_viewport:Node, event:InputEvent, _shape_index:int):
  if event is InputEventMouseButton && event.is_pressed():
    Store.set_state("selection", self)

func _physics_process(_delta):
  if data.type == "shield":
    var _projectiles = _tree.get_nodes_in_group("projectiles")
    var _blockable_projectiles = []

    for _projectile in _projectiles:
      if GDUtil.reference_safe(_projectile) && _projectile.team != team && _current_battery >= _projectile._current_health && (_projectile.global_position.distance_to(global_position) <= data.range + 5 && _projectile.global_position.distance_to(global_position) >= data.range - 5):
        var _damage_done = _projectile._current_health

        _projectile.damage(_damage_done)
        _current_battery -= _damage_done

func _process(delta):
  update()
  if !_dead:
    if _upgrade_time > 0:
      _upgrade_time -= delta

      if _upgrade_time <= 0:
        _upgrade_time = 0
        Store.state["player_data_" + str(team)].techs[_upgrade.id] = _upgrade
        Store.emit_signal("state_changed", "player_data_" + str(team), Store.state["player_data_" + str(team)])
        _upgrade = {}

    else:
      _clip_interval = clamp(_clip_interval - delta, 0, _clip_interval)
      _current_battery = clamp(_current_battery + (data.recharge_rate * delta), 0, data.battery)
      _time_to_reloaded = clamp(_time_to_reloaded - delta, 0, data.reload_time)

      if data.resource_rate_energy > 0:
        emit_signal("resource_generated", "energy", delta * data.resource_rate_energy, team)
        Store.gain_resource("energy", delta * data.resource_rate_energy, team)
      if data.resource_rate_metal > 0:
        emit_signal("resource_generated", "metal", delta * data.resource_rate_metal, team)
        Store.gain_resource("metal", delta * data.resource_rate_metal, team)

      match data.type:
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

  _time_to_reloaded = data.reload_time

  add_to_group(data.type)
