extends Node2D

export var id:String
export var team:int

onready var data:Dictionary = Castledb.get_entry("projectiles", id)

onready var _area2d:Area2D = $"./Area2D"
onready var _projectile_sprite:Sprite = $"./Sprite"

var target:Node2D

var _current_health:float
var _dead:bool

func damage(amount:float) -> void:
  _current_health = clamp(_current_health - amount, 0, data.health)

func die() -> void:
  if !_dead:
    var _overlapping_areas:Array = _area2d.get_overlapping_areas()
    var _damage_targets:Array = []

    for _area in _overlapping_areas:
      var _area_parent:Node2D = _area.get_owner()
      # print("projectile found overlapping area: " + _area_parent.name + "(" + _area_parent.id + ")")
      
      if "defense" in data.types:
        if _area_parent.is_in_group("projectiles"):
          _damage_targets.append(_area_parent)

    # print(id + "(" + name + ") damaging targets: " + str(_damage_targets))
    for _target in _damage_targets:
      var _damage_done:float = data.damage * lerp(1, 0.1, global_position.distance_to(_target.global_position) / data.radius)

      # print("damage from " + id + "(" + name + "): " + str(_damage_done))
      _target.damage(_damage_done)

    _dead = true
    queue_free()

func targetable() -> bool:
  return !_dead

func _physics_process(delta):
  if !_dead:
    if GDUtil.reference_safe(target) && target.targetable():
      look_at(target.global_position)
      global_position = global_position.move_toward(target.global_position, delta * data.speed)

      if target.global_position.distance_to(global_position) <= 1:
        # print("projectile " + name + "(" + id + ")" + " died from proximity to " + target.name + "(" + target.id + ")")
        die()

func _process(_delta):
  if !_dead:
    if !(GDUtil.reference_safe(target) && target.targetable()):
      # print("projectile " + name + "(" + id + ")" + " died from target loss")
      die()

    if _current_health <= 0:
      # print("projectile " + name + "(" + id + ")" + " died from health loss")
      die()

func _ready():
  _projectile_sprite.texture = load("res://sprites/projectiles/" + id + ".png")

  _area2d.get_node("CollisionShape2D").shape.radius = data.radius
  _current_health = data.health
  _dead = false

func _time_scale_reset() -> void:
  Engine.time_scale = 1
