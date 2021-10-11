extends Spatial

export (PackedScene) var rocket

var can_shoot = true
var shot = RayCast
var parent
var power = 10
var ammo_count = 10
var gun_range = 50
var rockets = []
var target_point = Vector3()
export var reload_speed : float = .4

signal hit


func _ready():
	parent = get_parent()
	#print(ammo_count)
	pass


func _process(delta):
	target_point = Vector3(0, 0, global_transform.origin.z -100)
	

func shoot():
	if can_shoot and ammo_count > 0:
		ammo_count -=1
		can_shoot = false
		$cooldown_timer.start(reload_speed)
		var r = rocket.instance()
		parent.get_parent().add_child(r)
		r.global_transform = $Muzzle.global_transform
		r.velocity = -r.transform.basis.z * r.muzzle_velocity
		rocket.connect("hit", self, "_on_hit")
	elif ammo_count <= 0:
		print("out of rounds")
		return


func _on_cooldown_timer_timeout():
	can_shoot = true


func _on_hit(body):
	emit_signal("hit", body)
