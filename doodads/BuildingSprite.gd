extends Sprite

func _draw():
  if GDUtil.reference_safe(Store.state.building_card_selected):
    var _local_snapped_position:Vector2 = to_local(MapController.get_snapped_position(get_global_mouse_position()))
    draw_rect(Rect2(_local_snapped_position.x - 35, _local_snapped_position.y - 35, 65, 65), Color.red, false)
    # draw_circle(_local_snapped_position, 50, Color.red)

func _process(_delta):
  update()
