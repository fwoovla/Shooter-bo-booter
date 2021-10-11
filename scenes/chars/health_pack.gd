extends Area

var item_name = "health_pack"
var picked_up = false
export var ammo_count : int = 10

func _ready():
	scale = Vector3(1,1,1)
	$AnimationPlayer.play("spin")


func _on_health_pack_body_entered(body):
	if body.is_in_group("player") and not picked_up:
		picked_up = true
		body.pickup_item(self)
		$AnimationPlayer.play("pick_up")
		yield(get_node("AnimationPlayer"), "animation_finished" )
		queue_free()
