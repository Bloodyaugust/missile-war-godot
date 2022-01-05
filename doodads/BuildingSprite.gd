extends Sprite

const BUILDING_SPRITE_ALLOWED_MOD:Color = Color.green
const BUILDING_SPRITE_FORBIDDEN_MOD:Color = Color.red

func _draw():
  if GDUtil.reference_safe(Store.state.building_card_selected):
    draw_rect(Rect2(-50, -50, 100, 100), Color.black, false)

func _process(_delta):
  update()
  if GDUtil.reference_safe(Store.state.building_card_selected):
    global_position = MapController.get_snapped_position(get_global_mouse_position())

    if MapController.cell_building_allowed(global_position):
      self_modulate = BUILDING_SPRITE_ALLOWED_MOD
    else:
      self_modulate = BUILDING_SPRITE_FORBIDDEN_MOD
