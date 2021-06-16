extends KinematicBody2D
class_name Ship



var mass = 10

var velocity: Vector2 = Vector2(0, 0)

var colliding_steps = 0

var acceleration: float = 0.0
var brake_speed: float = 0.0
var turn_speed: float = 0.0
var max_speed: float = 0.0
var boost_power: float = 0.0

var previous_acceleration_state = "NONE"
var next_acceleration_state = "NONE"

var stats = {

}


var damage_timeout = 0.0


func death():
	pass

func take_damage(damage: int):
	damage_timeout = 0.0
	var damage_absorbed_by_shields = damage if stats.shields > damage else stats.shields
	var damage_to_hull = damage - damage_absorbed_by_shields
	if damage_absorbed_by_shields > 0:
		stats.shields -= damage_absorbed_by_shields
		print("Shields were damaged")
	if damage_to_hull > 0:
		stats.health -= damage_to_hull
		print("Hull was damage")
	if stats.health <= 0:
		print("I was deleted!")
		$Explosion.set_emitting(true)
		$Visual.hide()
		collision_layer = 0
		collision_mask = 0
		set_physics_process(false)
		yield(get_tree().create_timer(2.0), "timeout")
		death()
		queue_free()


func get_orientation():
	return Vector2(0, -1).rotated(rotation)

func load_stats(ship_stats):
	stats.health = ship_stats.max_health
	stats.max_health = ship_stats.max_health
	stats.shields = ship_stats.max_shields
	stats.max_shields = ship_stats.max_shields
	acceleration = ship_stats.acceleration
	brake_speed = ship_stats.brake_speed
	turn_speed = ship_stats.turn_speed
	max_speed = ship_stats.max_speed
	boost_power = ship_stats.boost_power


func brake(delta):
	velocity -= velocity * delta * brake_speed
	if velocity.length() < 3:
		velocity = Vector2()

	if next_acceleration_state != "NONE":
		next_acceleration_state = "NONE"


func accelerate(delta, acceleration_boost = 1.0):
	velocity += delta * get_orientation() * acceleration * acceleration_boost


func turn_left(delta):
	rotation -= turn_speed * delta


func turn_right(delta):
	rotation += turn_speed * delta


func handle_rigidbody_collision(collision, delta):
	if collision != null:
		if colliding_steps != 0:
			return
		if not collision.collider is RigidBody2D:
			print("Collided with non-rigidbody...")
			return

		var collider: RigidBody2D = collision.collider
		var collider_position = collider.position
		var collider_velocity = collision.collider_velocity
		var speed_difference = velocity - collider_velocity
		var force = Vector2()
		var force_collider = Vector2()
		if sign(velocity.x) == sign(collider_velocity.x):
			if sign(velocity.x) == 1:
				if collider_velocity.x > velocity.x:
					if collider_position.x > position.x:
						pass
					else:
						force_collider.x = collider.mass * (collider_velocity.x - velocity.x)
				elif collider_velocity.x < velocity.x:
					if collider_position.x > position.x:
						force.x = mass * (velocity.x - collider_velocity.x)
					else:
						pass
			else:
				# negative velocities
				if collider_velocity.x < velocity.x:
					if collider_position.x < position.x:
						pass
					else:
						force_collider.x = collider.mass * (collider_velocity.x - velocity.x)
				elif collider_velocity.x > velocity.x:
					if collider_position.x < position.x:
						force.x = mass * (velocity.x - collider_velocity.x)
					else:
						pass
		else:
			force.x = mass * velocity.x
			force_collider.x  = collider.mass * collider_velocity.x

		if sign(velocity.y) == sign(collider_velocity.y):
			if sign(velocity.y) == 1:
				if collider_velocity.y > velocity.y:
					if collider_position.y > position.y:
						pass
					else:
						force_collider.y = collider.mass * (collider_velocity.y - velocity.y)
				elif collider_velocity.y < velocity.y:
					if collider_position.y > position.y:
						force.y = mass * (velocity.y - collider_velocity.y)
					else:
						pass
			else:
				# negative velocities
				if collider_velocity.y < velocity.y:
					if collider_position.y < position.y:
						pass
					else:
						force_collider.y = collider.mass * (collider_velocity.y - velocity.y)
				elif collider_velocity.y > velocity.y:
					if collider_position.y < position.y:
						force.y = mass * (velocity.y - collider_velocity.y)
					else:
						pass
		else:
			force.y = mass * velocity.y
			force_collider.y  = collider.mass * collider_velocity.y

		var delta_v = (force_collider * mass - force * collider.mass ) / mass * delta / 2
		# print(force_collider, force, delta_v)
		var impulse = (force - force_collider) * delta

#		velocity = velocity + (force_collider - force) * delta * delta * 0.5 / weight * collider.weight
#		velocity = velocity + (force_collider * weight - force * collider.weight) * delta * delta * 0.5 / weight
#		collider.apply_impulse(Vector2(0, 0), (force * collider.weight - force_collider * weight) * delta * delta * 0.5 / collider.weight * weight)
		var max_knockback = 20
		if mass > 2 * collider.mass:
			max_knockback = 0
		elif collider.mass > 4 * mass:
			max_knockback = 30
		if velocity.x > 0:
			velocity.x = max(velocity.x + delta_v.x, -max_knockback)
		else:
			velocity.x = min(velocity.x + delta_v.x, max_knockback)
		if velocity.y > 0:
			velocity.y = max(velocity.y + delta_v.y, -max_knockback)
		else:
			velocity.y = min(velocity.y + delta_v.y, max_knockback)

		collider.apply_impulse(Vector2(0, 0), impulse * mass / collider.mass / 2)

		colliding_steps += 1
	else:
		colliding_steps = 0

func _ready():
	pass
