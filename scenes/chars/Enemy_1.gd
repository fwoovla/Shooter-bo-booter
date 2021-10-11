extends KinematicBody


export var move_speed : float = 10
export var agro_dist :float = 10
export var speed : float = 6
export var turn_speed : float = 5
export var gravity : float = .98
export var acc : float = 15
export var air_acc : float = 5
export var max_speed :float = 20
export var jump_power : float = 20
export var health :int = 100
var see_player = false
var velocity : Vector3
var y_velocity : float
var target = null
var can_shoot = true
var current_gun = null
onready var anim_player = $AnimationPlayer
var is_alive = true
enum {IDLE, WALK, SHOOT, HAS_TARGET, WEP_UP, WEP_DOWN}
var state = IDLE
var wepon_state = WEP_DOWN

var normal_material = SpatialMaterial.new()
var agro_material = SpatialMaterial.new()

onready var mesh = $Armature/Skeleton/mesh
var player : KinematicBody
var parent

signal dead

func _ready():
	#parent = get_parent()
	#player = parent.get_node("Player")
	#print(parent.name)
	#print(player.name)
	normal_material.albedo_color = Color.aqua
	agro_material.albedo_color = Color.red
	mesh.set_surface_material(0, normal_material)
	$Heal_label_base.hide()

func _process(delta):
	if is_alive:
	
		if state == WALK:
			$AnimationPlayer.play("walk")
			
		if state == IDLE:
			$AnimationPlayer.play("idle")
		
		if state == SHOOT:
			if can_shoot:
				$AnimationPlayer.play("shoot")
				#yield(get_tree().create_timer(1), "timeout")
				$Shot_timer.start(rand_range(.5, 2))
				$new_gun_controller.shoot_current()
				can_shoot = false		
			elif not can_shoot and not $AnimationPlayer.is_playing():
				$AnimationPlayer.play("walk")
		
		$line_of_sight.look_at(player.global_transform.origin, Vector3.UP)	
		$Heal_label_base.look_at(player.global_transform.origin, Vector3.UP)
		$Heal_label_base/Head_label.scale.x = health/20

	
func _physics_process(delta):
	if is_alive:
		if $Detect_Area.get_overlapping_bodies().has(player) and $line_of_sight.get_collider() == player:
			target = player
			var new_transform = global_transform.looking_at(player.global_transform.origin, Vector3.UP)
			global_transform  = global_transform.interpolate_with(new_transform, turn_speed * delta)
			$hand.rotation_degrees = $hand.rotation_degrees.linear_interpolate($line_of_sight.rotation_degrees, turn_speed * delta)
			$hand.rotation_degrees.z = 0
			$hand.rotation_degrees.y = 0
			
			state = WALK
			rotation_degrees.x = 0
			rotation_degrees.z = 0
		if find_player(delta) == true:
			var _acc = acc if is_on_floor() else air_acc
			if global_transform.origin.distance_to(target.global_transform.origin) > 20:
				velocity = velocity.linear_interpolate(global_transform.basis.z * -speed, _acc * delta)	
				
			if global_transform.origin.distance_to(target.global_transform.origin) < 20:
				velocity = velocity.linear_interpolate(global_transform.basis.x * -speed, _acc * delta)	
				
			if is_on_floor():
				y_velocity = -.01
			else:
				y_velocity = clamp(y_velocity -gravity, -max_speed, max_speed)
			
			state = SHOOT

		else: 
			state = IDLE
			var _acc = acc if is_on_floor() else air_acc
			velocity = velocity * -speed *delta
			if is_on_floor():
				y_velocity = -.01
			else:
				y_velocity = clamp(y_velocity -gravity, -max_speed, max_speed)
		velocity.y = y_velocity
		velocity = move_and_slide(velocity, Vector3.UP)


func take_damage(dmg):
	health -= dmg
	if health <= 0:
		is_alive = false
		$AnimationPlayer.play("die")


func show_head_label():
	$Heal_label_base.show()


func hide_head_label():
	$Heal_label_base.hide()


func _on_gun_hit(hit_target):
	pass


func find_player(delta):
	if $Detect_Area.get_overlapping_bodies().has(player) and $line_of_sight.get_collider() == player:
		target = player
		var new_transform = global_transform.looking_at(player.global_transform.origin, Vector3.UP)
		global_transform  = global_transform.interpolate_with(new_transform, turn_speed * delta)
		$hand.rotation_degrees = $hand.rotation_degrees.linear_interpolate($line_of_sight.rotation_degrees, turn_speed * delta)
		$hand.rotation_degrees.z = 0
		$hand.rotation_degrees.y = 0
		
		state = WALK
		rotation_degrees.x = 0
		rotation_degrees.z = 0
		return true
	else:
		return false


func _on_Detect_Area_body_entered(body):
	if body.is_in_group("player"):
		$line_of_sight.look_at(body.global_transform.origin, Vector3.UP)
		if $line_of_sight.is_colliding() and $line_of_sight.get_collider() == player:
			#print("i see the player")
			target = body
			mesh.set_surface_material(0, agro_material)
			state = WALK


func _on_Detect_Area_body_exited(body):
	if body.is_in_group("player"):
		target = null
		mesh.set_surface_material(0, normal_material)
		state = IDLE


func _on_Shot_timer_timeout():
	can_shoot = true


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "die":
		emit_signal("dead", self)
		queue_free()
