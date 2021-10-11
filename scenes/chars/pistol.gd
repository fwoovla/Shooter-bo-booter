extends Spatial

export (PackedScene) var bullet_hit

var can_shoot = true
var shot = RayCast
var parent
export var power : int = 10
var gun_range = 100
var target_point = Vector3()
var ammo_count = 30
signal hit


func _ready():
	$muzzle_flash.hide()
	parent = get_parent()
	shot = $shot


func _process(delta):
	target_point = Vector3(0, 0, global_transform.origin.z -1000)
	
	
func shoot():
	if can_shoot and ammo_count > 0:
		ammo_count -=1
		can_shoot = false
		$cooldown_timer.start(.2)
		#$AnimationPlayer.play("recoil")
		var collider = shot.get_collider()
		if collider:
			var hit = bullet_hit.instance()
			collider.add_child(hit)
			hit.global_transform.origin = shot.get_collision_point()
#
			if collider.is_in_group("enemy") or collider.is_in_group("player"):
				var shape = shot.get_collider_shape()
				var hit_shape = collider.shape_owner_get_owner(shape)
				#print(hit_shape.name)
				if hit_shape.name == "Head_Box":
					collider.take_damage(power * 3)
				if hit_shape.name == "Body_Box":
					collider.take_damage(power)
										
				emit_signal("hit", collider)

				
		$muzzle_flash.show()
		yield(get_tree().create_timer(.1), "timeout")
		$muzzle_flash.hide()
	elif ammo_count <=0:
		print("out of bullets")
		return
		
		
func _on_cooldown_timer_timeout():
	can_shoot = true
	$muzzle_flash.hide()
	#shot.show()
