extends KinematicBody2D
class_name Ship


export var faction = "Armada"

onready var explosion_area = $ExplosionArea
onready var smoke_emitter = $SmokeEmitter

onready var shield = $Shield

onready var weapons = $Weapons.get_children()

export var orbit_speed = 1.0

var mass = 10

var velocity: Vector2 = Vector2(0, 0)

var colliding_steps = 0

var acceleration: float = 0.0
var brake_speed: float = 0.0
var turn_speed: float = 0.0
var max_speed: float = 0.0
var boost_power: float = 0.0

var shield_recharge: float = 5.0
var shield_recharge_rate: float = 5.0
var shield_recharge_tick: float = 0.3
var shield_recharge_tick_timer: float = 0.0

var previous_acceleration_state = "NONE"
var next_acceleration_state = "NONE"


var stats = {

}

export var explosion_damage = 50.0


var damage_timeout = 0.0

signal shoot(shot)
signal died(ship)

var minimum_shooting_distance = 9999.0
var maximum_shooting_distance = 0.0

func _ready():
	for weapon in weapons:
		weapon.shooter = self
		weapon.faction = faction
		minimum_shooting_distance = min(minimum_shooting_distance, weapon.shoot_distance_min)
		maximum_shooting_distance = max(maximum_shooting_distance, weapon.shoot_distance_max)


func shoot(weapons_eligible_for_shooting = null):
	var weapons_to_shoot = weapons_eligible_for_shooting
	if weapons_eligible_for_shooting == null:
		weapons_to_shoot = weapons

	for weapon in weapons_to_shoot:
		var shot_result = weapon.shoot()
		if shot_result != null:
			GameFlow.projectiles_spawner.fire_projectile(shot_result)
			return

func weapons_safe_for_shooting(distance: float):
	var safe_weapons = []
	for weapon in weapons:
		if weapon.is_within_shooting_distance(distance):
			safe_weapons.append(weapon)
	return safe_weapons


func death():
	pass


func update_shields(delta):
	if stats.max_shields == 0:
		return

	if damage_timeout > shield_recharge:
		shield_recharge_tick_timer += delta
		if shield_recharge_tick_timer > shield_recharge_tick:
			stats.shields += shield_recharge_rate
			if stats.shields - shield_recharge_rate <= 0:
				$ShieldShape.disabled = false
				if shield:
					shield.enable()
			stats.shields = min(stats.shields, stats.max_shields)
			if shield:
				shield.set_intensity(float(stats.shields) / stats.max_shields)
			shield_recharge_tick_timer = 0.0
	else:
		damage_timeout += delta

func take_damage(damage: int):
	if stats.health <= 0:
		print("You can't kill what's already dead...")
		return
	damage_timeout = 0.0
	shield_recharge_tick_timer = 0.0
	var damage_absorbed_by_shields = damage if stats.shields > damage else stats.shields
	var damage_to_hull = damage - damage_absorbed_by_shields
	if damage_absorbed_by_shields > 0:
		stats.shields -= damage_absorbed_by_shields
		if stats.shields <= 0:
			$ShieldShape.disabled = true
		if shield != null:
			if stats.shields <= 0:
				shield.break_shield()
			else:
				shield.get_hit()
				shield.set_intensity(float(stats.shields)/stats.max_shields)
	if damage_to_hull > 0:
		stats.health -= damage_to_hull

	print("HP: ", stats.health)
	print("SP: ", stats.shields)

	smoke_emitter.set_intensity(1.0 - stats.health / stats.max_health)
	if stats.health <= 0:
		play_explosion()
		impact_explosion()

		collision_layer = 0
		collision_mask = 0
		set_physics_process(false)
		yield(get_tree().create_timer(2.0), "timeout")
		emit_signal("died", self)
		death()
		queue_free()


func impact_explosion():
	var impacted_bodies = explosion_area.get_overlapping_bodies()
	for impacted_body in impacted_bodies:
		var difference = (impacted_body.global_position - explosion_area.global_position)
		var direction = difference.normalized()
		var distance =  difference.length()
		var impact = explosion_damage * 30.0 * 2 / (50 + distance)
		if GameFlow.is_enemy(impacted_body) or GameFlow.is_player(impacted_body):
			if distance < 100:
				print("Taking this much damage ", int(impact))
				impacted_body.take_damage(int(impact))
			impacted_body.velocity += direction * (1000.0 * 20 / (50 + distance))
		if GameFlow.is_asteroid(impacted_body):
			print("Applying impulse in direction ", direction)
			impacted_body.apply_impulse(Vector2(0, 0), direction * (1000.0 * 20 / (20 + distance)) * impacted_body.mass)





func play_explosion():
	$Explosion.set_emitting(true)
	$Explosion.visible = true
	$Visual.hide()
	$NormalEmission.emitting = false
	$BoostEmission.emitting = false
	$TurnLeftEmission.emitting = false
	$TurnRightEmission.emitting = false
	$SmokeEmitter.emitting = false


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
	if velocity.length() < 10:
		velocity = Vector2()
	elif velocity.length() < 20:
		velocity -= 2 * velocity * delta * brake_speed


	if next_acceleration_state != "NONE":
		next_acceleration_state = "NONE"


func accelerate(delta, acceleration_boost = 1.0):
	velocity += delta * get_orientation() * acceleration * acceleration_boost


func turn_left(delta):
	rotation -= turn_speed * delta


func turn_right(delta):
	rotation += turn_speed * delta



func get_forces(collision):
	var collider: RigidBody2D = collision.collider
	var collider_position = collider.position
	var collider_velocity = collision.collider_velocity
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

	return {
		"force_ship": force,
		"force_collider": force_collider
	}


func handle_rigidbody_collision(collision, delta):
	if collision != null:
		if colliding_steps != 0:
			return
		if not collision.collider is RigidBody2D:
			print("Collided with non-rigidbody...")
			return

		var collider = collision.collider

		var forces = get_forces(collision)
		var force_ship = forces.force_ship
		var force_collider = forces.force_collider

		var delta_v = (force_collider * mass - force_ship * collider.mass ) / mass * delta / 3
		# print(force_collider, force, delta_v)
		var impulse = (force_ship - force_collider) * delta
		print(impulse)

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

		collider.apply_impulse(Vector2(0, 0), impulse * sqrt(mass / collider.mass))

		GameFlow.hit_emitter.spawn_hit(collision.position)

		colliding_steps += 1
	else:
		colliding_steps = 0
