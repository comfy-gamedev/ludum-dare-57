extends TextureRect

var _pulse_radius: float = 0.0
var _pulse_alpha: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _draw() -> void:
	if _pulse_radius != 0.0:
		#draw_circle(size / 2.0, _pulse_radius, Color.WHITE, false, 4, false)
		var r = Rect2(size / 2.0, Vector2.ZERO)
		r = r.grow(_pulse_radius)
		draw_texture_rect(texture, r, false, Color(1.0, 1.0, 1.0, _pulse_alpha))

func pulse() -> void:
	var tween = create_tween()
	tween.tween_method(func (x):
		_pulse_radius = x * 48.0
		_pulse_alpha = (1.0 - x)
		queue_redraw()
	, 0.0, 1.0, 0.5).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func ():
		_pulse_radius = 0.0
		queue_redraw()
	)
