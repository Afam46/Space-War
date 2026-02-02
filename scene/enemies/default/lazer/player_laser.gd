extends Area2D

var damage = randi_range(10, 15) + GameData.damage_bonus
var targets: Array = []

func _on_body_entered(body):
	if body.is_in_group("enemies") or body.is_in_group("bullets") and body.has_method("destroy"):
		if not targets.has(body):
			targets.append(body)
			body.destroy(damage)
		if targets.size() == 1:
			$HitTimer.start()

func _on_body_exited(body):
	if targets.has(body):
		targets.erase(body)
		if targets.is_empty():
			$HitTimer.stop()

func _on_hit_timer_timeout():
	targets = targets.filter(func(target): return is_instance_valid(target))
	for target in targets:
		target.destroy(damage)
	if targets.is_empty():
		$HitTimer.stop()
