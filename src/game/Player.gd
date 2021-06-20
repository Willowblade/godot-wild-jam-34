extends Ship
class_name Player


onready var origin = position

var destinations = []

export var shell_name = "default"

var swappable_shell = null

var carrying = null

var should_update_stats = false

var sun = null
var heat = 0.0
var heat_max = 100.0
var heat_timeout = 0.0

var heat_released = false
var heat_recharge: float = 0.5
var heat_recharge_rate: float = 3.0
var heat_recharge_tick: float = 0.1
var heat_recharge_tick_timer: float = 0.0

var playing_beam = false
var played_beam = false


func update_heat(delta):
	if heat > 80:
		$Visual/Hull.modulate = Color(1.0, 0.9 - (heat - 80) / 30 * 0.7, 0.9 - (heat - 80) / 30 * 0.7, 1)
	else:
		$Visual/Hull.modulate = Color(1 ,1 ,1, 1)

	if heat_timeout > heat_recharge:
		if not heat_released:
			heat_released = true
			if heat > heat_max * 0.8:
				AudioEngine.play_effect("heat_release")
		heat_recharge_tick_timer += delta
		if heat_recharge_tick_timer > heat_recharge_tick:
			heat = max(0, heat - heat_recharge_rate)
			heat_recharge_tick_timer = 0.0
		should_update_stats = true
	else:
		heat_released = false
		heat_timeout += delta

func _ready():
	refresh_stats()

	smoke_emitter.set_intensity(1.0 - stats.health / stats.max_health)

	$MarkerRecognition.connect("area_entered", self, "_on_area_entered_marker_area")
	$MarkerRecognition.connect("area_exited", self, "_on_area_exited_marker_area")

	faction = "Player"

	mass = 100


func take_damage_extra():
	should_update_stats = true

func _on_area_entered_marker_area(area):
	if area in destinations:
		return
	print("area entered", area)
	if GameFlow.is_planet(area) or GameFlow.is_station(area):
		destinations.append(area)

		if GameFlow.markers:
			GameFlow.markers.make_markers(self, destinations)
			GameFlow.markers.update_visible_destinations(destinations)

func _on_area_exited_marker_area(area):
	if not area in destinations:
		return
	if GameFlow.is_planet(area) or GameFlow.is_station(area):
		if area in destinations:
			destinations.erase(area)

		if GameFlow.markers:
			GameFlow.markers.make_markers(self, destinations)
			GameFlow.markers.update_visible_destinations(destinations)



func refresh_stats():
	var player_stats = Flow.get_player_stats(shell_name)
	load_stats(player_stats)
	should_update_stats = true
#	emit_signal("updated_stats", stats)


func update_acceleration_animation():
	# TODO Use one trail but change properties -> might be  more elegant approach to
	# properly swap between different trails.
	if next_acceleration_state == "NONE":
		AudioEngine.stop_thruster()
		$NormalEmission.emitting = false
		$BoostEmission.emitting = false
	elif next_acceleration_state == "NORMAL":
#		AudioEngine.play_thruster("thrusters", false)
		AudioEngine.play_thruster("jet", false)
		$NormalEmission.emitting = true
		$BoostEmission.emitting = false
	elif next_acceleration_state == "BOOST":
		AudioEngine.play_thruster("jet", true)
		$NormalEmission.emitting = false
		$BoostEmission.emitting = true

	previous_acceleration_state = next_acceleration_state


func heal(percent):
	stats.health = min(stats.health + stats.max_health * percent, stats.max_health)
	smoke_emitter.set_intensity(1.0 - stats.health / stats.max_health)
	$Healing.emitting = true
	should_update_stats = true


func take_hull_damage(damage: float):
	if stats.health <= 0:
		print("You can't kill what's already dead...")
		return

	if damage > 0:
		stats.health -= damage

	smoke_emitter.set_intensity(1.0 - stats.health / stats.max_health)

	if stats.health <= 0:
		play_explosion()
		impact_explosion()

		collision_layer = 0
		collision_mask = 0
		set_physics_process(false)
		predeath()
		yield(get_tree().create_timer(2.0), "timeout")
		emit_signal("died", self)
		death()
		if faction.to_lower() != "player":
			queue_free()


func increase_heat(increment):
	# heat factor should be like a bit reduced imo
	increment = increment * 0.8
	heat += increment
	if heat > heat_max + 10:
		take_hull_damage((heat - heat_max - 10) / 2)
		heat = heat_max + 10

	if heat > 80:
		$Visual/Hull.modulate = Color(1.0, 0.9 - (heat - 80) / 30 * 0.7, 0.9 - (heat - 80) / 30 * 0.7, 1)

	heat_timeout = 0.0

	should_update_stats = true


func update_stats():
	GameFlow.overlays.hud.update_stats({
		"health": float(stats.health) / stats.max_health,
		"shield": float(stats.shields) / stats.max_shields,
		"heat": float(heat) / heat_max,
	})

func weapon_shot(weapon):
	if weapon.type == "rocket":
		AudioEngine.play_effect("weapon_rocket")
		increase_heat(5.0)
	if weapon.type == "beam":
		if not playing_beam:
			AudioEngine.play_effect("weapon_thiccbeam" + str(1 + (randi() % 3)))
		played_beam = true
		increase_heat(0.06)
	if weapon.type == "projectile":
		AudioEngine.play_effect("weapon_projectile")
		increase_heat(0.55)

func increase_heat_from_sun():
	if sun == null:
		return
	var distance_from_sun = position.distance_to(sun.position)
	if distance_from_sun < 600:
		increase_heat(0.5)
	else:
		increase_heat(0.4 * (900 - (distance_from_sun - 600)) / 900)

func _physics_process(delta):
	played_beam = false
	if heat > 0:
		update_heat(delta)
	if sun != null:
		increase_heat_from_sun()
	update_shields(delta)
	if damage_timeout > shield_recharge:
		should_update_stats = true

	var acceleration_boost = 1.0
	next_acceleration_state = "NONE"

	if Input.is_action_just_pressed("interact"):
		if swappable_shell:
			if carrying != null:
				GameFlow.overlays.popup.show_popup_custom("You can't swap when on a delivery", Vector2(0, 40), "info", 3)
				AudioEngine.play_effect("ui_negative" + str(1 + (randi() % 4)))
			else:
				AudioEngine.play_effect("ui_positive" + str(1 + (randi() % 5)))
				print("Interacting with swappable shell")
				GameFlow.canvas.swap_player(swappable_shell, null)
				return
		else:
			AudioEngine.play_effect("ui_negative" + str(1 + (randi() % 4)))

	if Input.is_action_pressed("sprint"):
		next_acceleration_state = "BOOST"
		acceleration_boost = boost_power

	if Input.is_action_pressed("accelerate"):
		accelerate(delta, acceleration_boost)
		if next_acceleration_state == "NONE":
			next_acceleration_state = "NORMAL"
	else:
		if next_acceleration_state == "BOOST":
			next_acceleration_state = "NONE"

	if Input.is_action_pressed("decelerate"):
		brake(delta)

	if Input.is_action_pressed("turn_left"):
		turn_left(delta)
		$TurnLeftEmission.emitting = true
	else:
		$TurnLeftEmission.emitting = false

	if Input.is_action_pressed("turn_right"):
		turn_right(delta)
		$TurnRightEmission.emitting = true
	else:
		$TurnRightEmission.emitting = false

	if Input.is_action_pressed("shoot"):
		shoot()

	playing_beam = played_beam

	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed

	update_acceleration_animation()

	if next_acceleration_state == "BOOST":
		increase_heat(0.4)

	if should_update_stats:
		update_stats()
		should_update_stats = false

	var collision: KinematicCollision2D = move_and_collide(velocity * delta, false, true, true)
	move_and_collide(velocity * delta, true)
	handle_rigidbody_collision(collision, delta)


#		velocity -= collision * delta * brake_speed
#	position += velocity * delta
