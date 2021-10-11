extends KinematicBody

export var speed : float = 10
export var gravity : float = .98
export var acc : float = 15
export var air_acc : float = 5
export var max_speed :float = 20
export var jump_power : float = 20
export var min_camera_tilt : float = -50
export var max_camera_tilt : float = 50
export var health :int = 100
export(float, .0, 1) var mouse_sensitivity :float = .3
var is_ducking = false
var velocity : Vector3
var y_velocity : float
onready var blood_splat = $Camera_base/Camera/Hud/Blood_splat

enum {IDLE, WALK, SHOOT, WEP_UP, WEP_DOWN}
var state = IDLE
var wepon_state = WEP_DOWN
var current_gun : Spatial = null
onready var camera_base = $Camera_base
onready var camera = $Camera_base/Camera
onready var anim_player = $AnimationPlayer

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	state = IDLE

func _process(delta):
	update_aim()

			
	if state == IDLE and not is_ducking:
		anim_player.play("idle")
		
	if state == WALK and not is_ducking:
			anim_player.play("walk")
#
		
	if state == SHOOT:
		#if current_gun.can_shoot:
		anim_player.play("shoot")	
		#new_gun_controller.shoot_current()
			
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
		
func _input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * mouse_sensitivity
		camera_base.rotation_degrees.y -= event.relative.x * mouse_sensitivity
		if camera_base.rotation_degrees.y <-30:
			camera_base.rotation_degrees.y = -30
			rotation_degrees.y -=event.relative.x * mouse_sensitivity
			
		if camera_base.rotation_degrees.y > 30:
			camera_base.rotation_degrees.y = 30
			rotation_degrees.y -=event.relative.x * mouse_sensitivity
			
		camera_base.rotation_degrees.x -= event.relative.y * mouse_sensitivity
		camera_base.rotation_degrees.x = clamp(camera_base.rotation_degrees.x, min_camera_tilt, max_camera_tilt)

	$hand.rotation_degrees.y = camera_base.rotation_degrees.y
	$hand.rotation_degrees.x = camera_base.rotation_degrees.x
	$hand.rotation_degrees.z = camera_base.rotation_degrees.z
	
func _physics_process(delta):
	process_key_input(delta)
	
func process_key_input(delta):
	var direction = Vector3()
	
	if Input.is_action_pressed("move_forward"):
		direction -= global_transform.basis.z * speed * delta
	if Input.is_action_pressed("move_backward"):
		direction += global_transform.basis.z * speed * delta
	if Input.is_action_pressed("move_left"):
		direction -= global_transform.basis.x * speed * delta
	if Input.is_action_pressed("move_right"):
		direction += global_transform.basis.x * speed * delta		
	if Input.is_action_just_pressed("duck"):
		is_ducking = true
		$AnimationPlayer.play("duck")
	if Input.is_action_just_released("duck"):
		is_ducking = false
		
	direction = direction.normalized()
	
	var _acc = acc if is_on_floor() else air_acc
	velocity = velocity.linear_interpolate(direction * speed, _acc * delta)	
	
	if is_on_floor():
		y_velocity = -.01
	else:
		y_velocity = clamp(y_velocity -gravity, -max_speed, max_speed)
		
	if Input.is_action_just_pressed("jump"):
		y_velocity= jump_power

	if Input.is_action_pressed("mouse_fire"):
		state = SHOOT
		$new_gun_controller.shoot_current()
		#wepon_state = WEP_UP
		
	if Input.is_action_just_released("mouse_fire"):
		state = IDLE
		#wepon_state = WEP_DOWN
		
	if direction != Vector3.ZERO and state != SHOOT:
		state = WALK
	elif direction == Vector3.ZERO and state != SHOOT:
		state = IDLE
	
	velocity.y = y_velocity
	velocity = move_and_slide(velocity, Vector3.UP)


func update_aim():
	$hand/Aim_ray.cast_to = $new_gun_controller.current_gun.target_point
	if $hand/Aim_ray.is_colliding():
		var point = $hand/Aim_ray.get_collision_point()
		$hand/crosshair.global_transform.origin = point
		#$hand/crosshair.scale = Vector3(1,1,1)
		$hand/crosshair.look_at(self.global_transform.origin, Vector3.UP)
		
		if $hand/Aim_ray.get_collider().is_in_group("enemy"):
			$hand/Aim_ray.get_collider().show_head_label()


func take_damage(dmg):
	health -= dmg
	#print(health)
	blood_splat.show()
	yield(get_tree().create_timer(.1), "timeout")
	blood_splat.hide()


func pickup_item(item):
	if item.item_name == "ammo_box":
		current_gun.ammo_count += item.ammo_count
	if item.item_name == "health_pack":
		health += 50
		if health > 100:
			health = 100
	pass


func _on_gun_hit(hit_target):
	#print(hit_target)
	pass


func put_wepon_down():
	$new_gun_controller.current_gun.hide()


func put_wepon_up():
	$new_gun_controller.current_gun.show()
