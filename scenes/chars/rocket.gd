extends Area

var speed = 1
var power = 100
var gun_range = 100
var velocity = Vector3.ZERO

signal hit

func _ready():
	pass

func _physics_process(delta):
	#velocity -= transform.basis.z * speed
	transform.origin += transform.basis.z * delta

func _on_Area_body_entered(body):
	print(body)
	if body.is_in_group("enemy"):
		body.hurt(power)
		emit_signal("hit", body)
		
	if body.is_in_group("player"):
		body.hurt(power/2)
		emit_signal("hit", body)
	queue_free()


func _on_Timer_timeout():
	queue_free()

