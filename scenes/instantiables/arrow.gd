extends Node2D


const _ANIM_TIME := 0.5

var to: Vector2


func _ready() -> void:
	var peak := minf(position.y - Board.TILE_HEIGHT, to.y - Board.TILE_HEIGHT)
	var tween := get_tree().create_tween().bind_node(self).set_parallel(true)
	tween.tween_property(self, ^"position:x", to.x, _ANIM_TIME)
	tween.tween_property(self, ^"position:y", peak, _ANIM_TIME * 0.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, ^"position:y", to.y, _ANIM_TIME * 0.5).set_delay(_ANIM_TIME * 0.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	tween.tween_callback(queue_free).set_delay(_ANIM_TIME)
