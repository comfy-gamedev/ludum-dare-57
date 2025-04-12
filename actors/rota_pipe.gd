class_name RotaPipe
extends Sprite2D

var prevs: Array[Vector2i]
var is_fixed: bool = false

@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D

func _ready() -> void:
	rotation = TAU / 4.0

func fix() -> void:
	is_fixed = true
	var t = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	t.tween_property(self, "rotation", 0.0, 0.2)
	await t.finished
	cpu_particles_2d.emitting = true
