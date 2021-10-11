# these are all instances and must be added as a child of the unit's hand

extends Node

export(PackedScene) var pistol
export(PackedScene) var blaster
export(PackedScene) var rocket_launcher

var hand :Position3D
var gun_list = []
var gun_list_index = 0
var current_gun : Spatial = null
var parent


func _ready():
	parent = get_parent()
	hand = get_parent().get_node("hand")
	
	var g = pistol.instance()
	gun_list.append(g)
	current_gun = g
	hand.add_child(g)
	g.hide()

	var b = blaster.instance()
	gun_list.append(b)
	#current_gun = b
	hand.add_child(b)
	b.hide()

	var r = rocket_launcher.instance()
	gun_list.append(r)
	hand.add_child(r)
	r.hide()
	
	equip_gun(current_gun)
	#print("gun equiped " + str(current_gun.name))
#
func _input(event):
	if event is InputEventMouseButton and parent.is_in_group("player"):
		if event.is_pressed():
			if event.button_index == BUTTON_WHEEL_UP:
				#print("wheel up")
				gun_list_index +=1
				if gun_list_index > gun_list.size() -1:
					gun_list_index = 0

				equip_gun(gun_list[gun_list_index])

			if event.button_index == BUTTON_WHEEL_DOWN:
				#print("wheel down")
				gun_list_index -=1
				if gun_list_index < 0:
					gun_list_index = gun_list.size() -1
				equip_gun(gun_list[gun_list_index])
#

func _process(delta):
	pass
#	if Input.is_action_just_pressed("wepon_switch") and parent.is_selected:
#		gun_list_index +=1
#		if gun_list_index > gun_list.size() -1:
#			gun_list_index = 0
#		equip_gun(gun_list[gun_list_index])


func shoot_current():
	current_gun.shoot()
#	if current_gun.ammo_count > 0 and current_gun.can_shoot:
#		parent.get_parent().anim_player.play("shoot")


func equip_gun(gun : Spatial):
	#print(gun.name)
	current_gun.hide()
	current_gun = gun
	current_gun.show()
	current_gun.connect("hit", hand.get_parent(), "_on_gun_hit")
	hand.add_child(current_gun)
	hand.get_parent().current_gun = current_gun
	current_gun.parent = get_parent()	
	#print(current_gun.parent)


func equip_index(gl_index):
	#print(gun_list[gl_index].name)
	current_gun.hide()
	current_gun = gun_list[gl_index]
	current_gun.show()
	current_gun.connect("hit", hand.get_parent(), "_on_gun_hit")
	hand.add_child(current_gun)
	hand.get_parent().current_gun = current_gun
	current_gun.parent = get_parent()	
	#print(current_gun.parent)
