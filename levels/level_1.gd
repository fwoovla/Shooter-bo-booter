extends Spatial

var _troop = preload("res://scenes/chars/Player.tscn")
var _enemy = preload("res://scenes/chars/Enemy_1_2.tscn")

var enemy_list = []
onready var player = $Player

var rand = RandomNumberGenerator.new()

export var num_per_wave :int = 1


func _ready():
	rand.randomize()
	for enemy in $Enemies.get_children():
		add_enemy(enemy)


		
		
func _process(delta):
	for enemy in enemy_list:
		enemy.hide_head_label()
		

func _on_enemy_dead(enemy):
	enemy_list.erase(enemy)



func add_enemy(enemy):
		enemy.get_parent().remove_child(enemy)
		self.add_child(enemy)
		enemy_list.append(enemy)
		enemy.parent = self
		enemy.player = player
		enemy.connect("dead", self, "_on_enemy_dead")
		#print("parent " +str(enemy.get_parent().name))


func reset_level():
	pass
