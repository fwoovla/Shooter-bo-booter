extends Area

signal hit
export var power : int = 100
export var muzzle_velocity = 40
export var g = Vector3.DOWN * 20

var velocity = Vector3.ZERO


func _physics_process(delta):
	#velocity += g * delta
	look_at(transform.origin + velocity.normalized(), Vector3.UP)
	transform.origin += velocity * delta


func _on_Timer_timeout():
	queue_free()


func _on_rocket_body_entered(body):
	if body.is_in_group("enemy"):
		emit_signal("hit", transform.origin)
		body.take_damage(power)
	if body.is_in_group("player"):
		body.take_damage(power /2)
		emit_signal("hit", transform.origin)
	queue_free()

