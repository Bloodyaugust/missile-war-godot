extends Node2D

export var id:String
export var team:int

onready var data:Dictionary = Castledb.get_entry("projectiles", id)

onready var _projectile_sprite:Sprite = $"./Sprite"

var target:Node2D

var _current_health:float
var _dead:bool

func damage(amount:float) -> void:
  _current_health = clamp(_current_health - amount, 0, data.health)

func die() -> void:
  if !_dead:
    queue_free()

func _process(delta):
  if !_dead:
    if GDUtil.reference_safe(target):
      look_at(target.global_position)
      global_position = global_position.move_toward(target.global_position, delta * data.speed)

      if target.global_position.distance_to(global_position) <= 1:
        target.damage(data.damage)
        die()
    else:
      die()

    if _current_health <= 0:
      die()

func _ready():
  _projectile_sprite.texture = load("res://sprites/projectiles/" + id + ".png")

  _current_health = data.health
  _dead = false
