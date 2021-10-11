extends Control

onready var player = get_parent().get_parent().get_parent()

func _ready():
	$Ammo_count_label.set("custom_colors/font_color", Color.yellow)
	pass
	

func _process(delta):
	$Ammo_count_label.text = str(player.current_gun.ammo_count)
	
	if player.health < 20:
		$Health_label.set("custom_colors/font_color", Color.red)
	else:
		$Health_label.set("custom_colors/font_color", Color.green)
		
	$Health_label.text = str(player.health)	
