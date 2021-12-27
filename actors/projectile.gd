extends Node2D

export var id:String
export var team:int

onready var data:Dictionary = Castledb.get_entry("projectiles", id)

onready var _tree = get_tree()
onready var _projectile_sprite:Sprite = $"./Sprite"

var target:Node2D

var _current_health:float
var _dead:bool

func damage(amount:float) -> void:
  _current_health = clamp(_current_health - amount, 0, data.health)

func die() -> void:
  if !_dead:
    var _targetables:Array = _tree.get_nodes_in_group("targetables")
    var _damage_targets:Array = []

    for _target in _targetables:
      if _target != self && GDUtil.reference_safe(_target) && _target.global_position.distance_to(global_position) <= data.radius:
        _damage_targets.append(_target)

    # print(id + "(" + name + ") damaging targets: " + str(_damage_targets))
    for _target in _damage_targets:
      var _damage_done:float = data.damage * lerp(1, 0.1, clamp(global_position.distance_to(_target.global_position), 0, data.radius) / data.radius)

      # print("damage from " + id + "(" + name + ") to (" + _target.name + ":" + _target.data.id + "): " + str(_damage_done))
      _target.damage(_damage_done)

    _dead = true
    queue_free()

func targetable() -> bool:
  return !_dead

func _draw():
  if Store.state.debug:
    draw_arc(Vector2.ZERO, data.radius, 0, 2 * PI, 12, Color.red)

func _physics_process(delta):
  update()
  if !_dead:
    if GDUtil.reference_safe(target) && target.targetable():
      look_at(target.global_position)
      global_position = global_position.move_toward(target.global_position, delta * data.speed)

      if _current_health <= 0:
        # print("projectile " + name + "(" + id + ")" + " died from health loss")
        die()

      if target.global_position.distance_to(global_position) <= 1:
        # print("projectile " + name + "(" + id + ")" + " died from proximity to " + target.name + "(" + target.id + ")")
        die()

    else:
      die()

func _ready():
  _projectile_sprite.texture = load("res://sprites/projectiles/" + id + ".png")

  var _range_shape:CircleShape2D = CircleShape2D.new()

  _range_shape.radius = data.radius

  _current_health = data.health
  _dead = false
