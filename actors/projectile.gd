extends Node2D

export var id:String
export var team:int

onready var data:Dictionary = Castledb.get_entry("projectiles", id)

onready var _projectile_sprite:Sprite = $"./Sprite"

var target:Node2D

var _current_health:float

func damage(amount:float) -> void:
  _current_health = clamp(_current_health - amount, 0, data.health)

func _process(delta):
  if GDUtil.reference_safe(target):
    look_at(target.global_position)
    global_position = global_position.move_toward(target.global_position, delta * data.speed)

    if target.global_position.distance_to(global_position) <= 1:
      target.damage(data.damage)
      queue_free()
  else:
    queue_free()

  if _current_health <= 0:
    queue_free()

func _ready():
  _projectile_sprite.texture = load("res://sprites/projectiles/" + id + ".png")

  _current_health = data.health
