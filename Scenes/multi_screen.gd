extends Node3D

var peer = ENetMultiplayerPeer.new()
@export var player_scene: PackedScene

var mmenu = preload("res://Scenes/main_menu.tscn")

func _on_host_pressed():
	peer.create_server(5030,2)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(add_player)
	add_player()
	$CanvasLayer.hide()

func add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child",player)

func _on_join_pressed():
	peer.create_client("localhost",5030)
	multiplayer.multiplayer_peer = peer
	$CanvasLayer.hide()

func exit_game(id):
	multiplayer.peer_disconnected.connect(del_player)
	del_player(id)

func del_player(id):
	rpc("del_player",id)
	
@rpc("any_peer","call_local")
func _del_player(id):
	get_node(str(id)).queue_free()


func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
