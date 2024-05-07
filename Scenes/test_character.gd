extends CharacterBody3D

const SPEED := 22.25
const JUMP_VELOCITY := 6.5
const MOUSE_SENS := 0.002

var speed_multiplier := 10.0
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")*1.3
var moving := true
var running := false

var default_fov := 75.0

@export var Equipment : Inventory
@export var Steps := preload("res://SFX/PlayerSteps.tres")

@onready var RayCast : RayCast3D = $Pivot/PlayerCamera/Pointer
@onready var Target : Sprite3D = $test_interaction
@onready var PlayerInv := $InventoryViewport/InventoryViewport/CanvasLayer/Inventory
@onready var ContainerInv := $InventoryViewport/InventoryViewport/CanvasLayer/Container
@onready var Dot := $InventoryViewport/InventoryViewport/CanvasLayer/Dot
@onready var Hand := $Pivot/PlayerCamera/Hand
@onready var DropPoint := $Pivot/PlayerCamera/Pointer/DropPoint
@onready var PlayerCam := $Pivot/PlayerCamera
@onready var NormalCam := $InventoryViewport/InventoryViewport/CanvasLayer/NormalCam
@onready var PlayCam := $InventoryViewport/PlayerViewport/Camera3D
@onready var ItemCam := $InventoryViewport/ItemViewport/ItemCam
@onready var UsePlayer := $UsePlayer
@onready var StepsPlayer := $StepsPlayer

var looking_at
var current_item : Item = null

func _enter_tree():
	set_multiplayer_authority(name.to_int())

func _ready():
	if is_multiplayer_authority():
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		$PlayerSprite2.layers = 256
		NormalCam.current = is_multiplayer_authority()
	else:
		call_deferred("remove_child",$InventoryViewport)

func _process(_delta):
	if is_multiplayer_authority():
		PlayCam.global_transform = PlayerCam.global_transform
		NormalCam.global_transform = PlayerCam.global_transform
		ItemCam.global_transform = PlayerCam.global_transform

func _physics_process(delta):
	if is_multiplayer_authority():
		interaction()
		escape()
		movement(delta)
		raycast()
		inventory_toggle()
		drop()
		
		move_and_slide()
	
func _unhandled_input(event):
	if is_multiplayer_authority():
		if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			rotate_y(-event.relative.x * MOUSE_SENS)
			$Pivot.rotate_x(-event.relative.y * MOUSE_SENS)
			$Pivot.rotation.x = clamp($Pivot.rotation.x, -1.2, 1.2)

func hide_inv():
	PlayerInv.visible = false
	hide_cont()
	Dot.visible = true
	moving = true
	clear(PlayerInv)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func hide_cont():
	ContainerInv.visible = false

func clear(inventory):
	var grid : GridContainer = inventory.get_node("InvRect/InvGrid")
	for child in grid.get_children():
		grid.remove_child(child)

func open_inv(sending = false):
	update_inv(PlayerInv, Equipment, 'Inventory', sending)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	PlayerInv.visible = true
	Dot.visible = false
	moving = false

func update_inv(inventory : Control, slotage : Inventory, title='Inventory', sending = false):
	clear(inventory)
	var grid : GridContainer = inventory.get_node("InvRect/InvGrid")
	for item : Item in slotage.slots:
		var new_slot = preload("res://Scenes/test_slot.tscn").instantiate()
		new_slot.get_node("Name").text = item.name
		new_slot.get_node("Image").texture = item.texture
		var move_but : TextureButton = new_slot.get_node("Move")
		var take_but : TextureButton = new_slot.get_node("Take")
		var use_but : TextureButton = new_slot.get_node("Use")
		if sending:
			move_but.pressed.connect(take.bind(slotage, item, sending))
			move_but.visible = true
			take_but.visible = false
			use_but.visible = false
		else:
			take_but.pressed.connect(item.take.bind(self, current_item))
			use_but.pressed.connect(item.use.bind(self))
			move_but.visible = false
			take_but.visible = true
			use_but.visible = true
		grid.add_child(new_slot)
		if title:
			inventory.get_node("InvRect/Title/TitleName").text = title

###########
###########
###########
# Podepnij sygnał, żeby wszystkim graczom grał dźwięk
func interaction():
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and Input.is_action_just_pressed("interaction"):
		var sound_play = null
		if looking_at != null and looking_at is Interactive and looking_at.usable:
			if looking_at is ButtonInt or looking_at is Door:
				sound_play = looking_at.use()
				
			elif looking_at is ContainerInt:
				var container_data = looking_at.get_inv()
				update_inv(ContainerInv, container_data[0], container_data[1], Equipment)
				ContainerInv.visible = true
				open_inv(container_data[0])
				sound_play = looking_at.use()
				#add close inventory sound
				
			elif looking_at is Pickable and looking_at.pickable:
				Equipment.slots.append(looking_at.pickup())
				#sound_play = pickup_sfx
		elif looking_at != null and looking_at is Interactive:
			sound_play = preload("res://SFX/Uses/sfxUnusable.wav")
		elif Hand.get_child_count() > 0:
				sound_play = Hand.get_child(0).use()
		if sound_play != null:
			play_use(sound_play)

func escape():
	if Input.is_action_just_pressed("ui_cancel") and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and not get_tree().paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		PlayerInv.visible = false
		Dot.visible = false
		moving = false
		
	elif Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		hide_inv()

func movement(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump
	if Input.is_action_just_pressed("move_jump") and is_on_floor() and moving:
		velocity.y = JUMP_VELOCITY
	if Input.is_action_pressed("run"):
		speed_multiplier = 10.0
		PlayCam.fov = lerp(PlayCam.fov,default_fov+30,5*delta)
		running = true
	else:
		running = false
		speed_multiplier = 5.0
		PlayCam.fov = lerp(PlayCam.fov,default_fov,5*delta)

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("strafe_left", "strafe_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction and moving:
		velocity.x = direction.x * SPEED * delta * speed_multiplier
		velocity.z = direction.z * SPEED * delta * speed_multiplier
		rpc("move_anim")
	else:
		if !is_on_floor():
			velocity.x = move_toward(velocity.x, 0, delta)
			velocity.z = move_toward(velocity.z, 0, delta)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED*delta)
			velocity.z = move_toward(velocity.z, 0, SPEED*delta)
		rpc("stop_move_anim")

@rpc("authority","call_local","unreliable_ordered")
func move_anim():
	$MoveAnim.play("Moving")
	if is_on_floor():
		if !StepsPlayer.playing:
			if running:
				StepsPlayer.stream = Steps.run_ground.pick_random()
			else:
				StepsPlayer.stream = Steps.walk_ground.pick_random()
			StepsPlayer.play()

@rpc("authority","call_local","unreliable_ordered")
func stop_move_anim():
	$MoveAnim.stop()

func raycast():
	var collider = RayCast.get_collider()
	if collider != null and collider.has_method("looked_at"):
		var outline_bool = collider.get("pickable")
		if outline_bool == false:
			return
		Target.visible = true
		Target.global_position = RayCast.get_collision_point() + Vector3(0,0.2,0)
		collider.looked_at()
		if collider.has_method("interaction") and Input.is_action_just_pressed("mouse_interact"):
			collider.interaction(self)
	else:
		Target.visible = false
	if looking_at != null and looking_at.has_method("not_looked_at") and looking_at != collider:
		looking_at.not_looked_at()
	looking_at = collider

func inventory_toggle():
	if Input.is_action_just_pressed("inventory"):
		if PlayerInv.visible:
			hide_inv()
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			open_inv()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func take(slotage : Inventory, item : Item, sending : Inventory):
	slotage.slots.erase(item)
	sending.slots.append(item)
	if slotage == Equipment:
		if is_multiplayer_authority():
			update_inv(PlayerInv, slotage, false, sending)
		update_inv(ContainerInv, sending, false, slotage)
		Hand.remove_child(Hand.get_child(0))
		current_item = null
	else:
		if is_multiplayer_authority():
			update_inv(PlayerInv, sending, false, slotage)
		update_inv(ContainerInv, slotage, false, sending)

##### Signal to change content of hand for all peers
func set_cur_item(item : Item):
	current_item = item
	update_inv(PlayerInv, Equipment)
	if current_item != null:
		var holding_item = current_item.name
		spawn_item.rpc(holding_item, name)
	elif Hand.get_child_count()>0:
		remove_item.rpc(name)

@rpc("any_peer","call_local")
func spawn_item(item : String, id):
	var holding_item = Relations.get_obj(item).instantiate()
	get_parent().get_node(str(id)).Hand.call_deferred("add_child",holding_item)
	holding_item.collision_layer = 2
	holding_item.collision_mask = 2
	holding_item.freeze = true
	holding_item.in_hand()

@rpc("any_peer","call_local")
func remove_item(id):
	var hand = get_parent().get_node(str(id)).Hand
	hand.call_deferred("remove_child",hand.get_child(0))

func drop():
	if Input.is_action_just_pressed("drop") and current_item != null:
		Equipment.slots.erase(current_item)
		var item_obj : RigidBody3D = Relations.get_obj(current_item.object_to_spawn).instantiate()
		var drop_pos = DropPoint.global_position
		var item_target_l_velocity = global_position.direction_to(DropPoint.global_position).normalized()*6
		var item_target_a_velocity = Vector3(randi_range(-10,10),randi_range(-10,10),randi_range(-10,10))
		var item_target_g_position = global_position
		var item_target_g_rotation = global_rotation
		rpc("spawn_dropped",item_obj,item_target_l_velocity,item_target_a_velocity,item_target_g_position, item_target_g_rotation)
		Hand.remove_child(Hand.get_child(0))
		current_item = null

@rpc("any_peer","call_local","unreliable_ordered")
func spawn_dropped(item : Pickable, l_vel, a_vel, g_pos, g_rot):
	get_parent().get_child(0).call_deferred("add_child",item)
	item.linear_velocity = l_vel
	item.angular_velocity = a_vel
	item.global_position = g_pos
	item.global_rotation = g_rot
	item.continuous_cd = true

@rpc("any_peer","call_local","unreliable_ordered")
func play_use(sound : AudioStream):
	UsePlayer.stream = sound
	UsePlayer.play()
