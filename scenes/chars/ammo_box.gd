extends Area

var item_name = "ammo_box"
var picked_up = false
export var ammo_count : int = 10

func _ready():
	scale = Vector3(1,1,1)
	$Cube/AnimationPlayer.play("spin")

func _on_ammo_box_body_entered(body):
	if body.is_in_group("player") and not picked_up:
		picked_up = true
		body.pickup_item(self)
		$Cube/AnimationPlayer.play("pick_up")
		yield($Cube.get_node("AnimationPlayer"), "animation_finished" )
		queue_free()
