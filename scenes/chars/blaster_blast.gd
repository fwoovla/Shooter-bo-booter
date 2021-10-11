extends Spatial

signal hit
export var power : int = 10
export var speed = 100
export var g = Vector3.DOWN * 20

var velocity = Vector3.ZERO


func _physics_process(delta):
	#velocity += g * delta
	look_at(transform.origin + velocity.normalized(), Vector3.UP)
	transform.origin += velocity * delta


func _on_blaster_blast_body_entered(body):
	pass


func _on_blaster_blast_body_shape_entered(body_id, body, body_shape, area_shape):
	if body.is_in_group("enemy"):
		var shape = body_shape
		print(body_shape)
		emit_signal("hit", transform.origin)
		body.take_damage(power)
	if body.is_in_group("player"):
		body.take_damage(power /2)
		emit_signal("hit", transform.origin)
	queue_free()
