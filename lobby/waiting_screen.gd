class_name LobbyWaitingScreen
extends Control

@onready var player_texture: TextureRect = %PlayerTexture
@onready var player_name: Label = %PlayerName
@onready var role_button: Button = %RoleButton
@onready var ready_button: Button = %ReadyButton
@onready var player_list: VBoxContainer = %PlayerList
@onready var waiting_label: Label = %WaitingLabel
@onready var back_button: Button = %BackButton
@onready var role_container: PanelContainer = %RoleContainer
@onready var role_list: VBoxContainer = %RoleList
@onready var start_timer: Timer = $StartTimer
@onready var game_start_container: PanelContainer = %GameStartContainer
@onready var game_start_counter: Label = %GameStartCounter

var LOBBY_PLAYER_SCENE: PackedScene = preload("res://lobby/lobby_player.tscn")

var map_button: Button
var map_container: PanelContainer
var map_list: VBoxContainer


func _ready() -> void:
	player_name.text = Game.instance.get_current_player().name
	ready_button.pressed.connect(_toggle_ready)
	Game.instance.players_updated.connect(_handle_players_updated)
	Game.instance.player_updated.connect(func(_id: int) -> void: _update_ready_button())
	Game.instance.vote_updated.connect(func(_id: int) -> void: _handle_vote_updated())
	Game.instance.map_updated.connect(_on_map_updated)
	if multiplayer.is_server():
		start_timer.timeout.connect(func() -> void: _start_game.rpc())
	_handle_players_updated()
	role_button.visible = Game.instance.use_roles
	back_button.pressed.connect(_handle_back_pressed)
	role_button.pressed.connect(_handle_role_pressed)
	role_container.hide()
	game_start_container.hide()

	_setup_map_selector()
	_update_ready_button()

	if Game.instance.use_roles:
		_fill_role_container()
		var role: Statics.Role = Game.instance.get_current_player().role
		role_button.text = Statics.get_role_name(role)
		if role == Statics.Role.NONE:
			role_button.text = "Role?"

	if multiplayer.is_server():
		Game.instance.request_set_map(Game.instance.selected_map_index)


func _process(_delta: float) -> void:
	game_start_counter.text = str(int(ceil(start_timer.time_left)))


func _toggle_ready() -> void:
	Game.instance.set_current_player_vote(not Game.instance.get_current_player().vote)
	_update_player()


func _update_player() -> void:
	var player_ready: bool = Game.instance.get_current_player().vote
	player_texture.modulate = Color.GREEN if player_ready else Color.WHITE
	role_container.hide()
	if map_container:
		map_container.hide()


func _setup_map_selector() -> void:
	var column: Node = ready_button.get_parent()
	map_button = Button.new()
	map_button.name = "MapButton"
	map_button.focus_mode = Control.FOCUS_ALL
	column.add_child(map_button)
	column.move_child(map_button, ready_button.get_index())
	map_button.pressed.connect(_handle_map_pressed)
	map_button.disabled = not multiplayer.is_server()

	var anchor := Control.new()
	anchor.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
	anchor.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	anchor.grow_vertical = Control.GROW_DIRECTION_BOTH
	anchor.position = Vector2(16, 0)
	map_button.add_child(anchor)

	map_container = PanelContainer.new()
	map_container.visible = false
	map_container.theme_type_variation = &"Darker"
	anchor.add_child(map_container)

	var margin := MarginContainer.new()
	margin.theme_type_variation = &"Tight"
	map_container.add_child(margin)

	map_list = VBoxContainer.new()
	map_list.theme_type_variation = &"Zero"
	margin.add_child(map_list)

	for i: int in Statics.MAPS.size():
		var button := Button.new()
		button.text = Statics.get_map_name(i)
		var map_index: int = i
		button.pressed.connect(func() -> void: _select_map(map_index))
		map_list.add_child(button)

	_refresh_map_button()


func _handle_map_pressed() -> void:
	if not multiplayer.is_server():
		return
	map_container.visible = not map_container.visible
	role_container.hide()


func _select_map(index: int) -> void:
	if not multiplayer.is_server():
		return
	Game.instance.request_set_map(index)
	map_container.hide()


func _on_map_updated(_index: int) -> void:
	_refresh_map_button()


func _refresh_map_button() -> void:
	if map_button == null:
		return
	var map_name: String = Statics.get_map_name(Game.instance.selected_map_index)
	if multiplayer.is_server():
		map_button.text = "Mapa: %s" % map_name
	else:
		map_button.text = "Mapa: %s (host)" % map_name


func _handle_players_updated() -> void:
	for child: Node in player_list.get_children():
		child.queue_free()
	waiting_label.visible = Game.instance.players.size() == 1
	for player: Statics.PlayerData in Game.instance.players:
		if player.id != multiplayer.get_unique_id():
			var lobby_player_inst: LobbyPlayer = LOBBY_PLAYER_SCENE.instantiate()
			lobby_player_inst.set_player(player)
			player_list.add_child(lobby_player_inst)
	_update_ready_button()
	if multiplayer.is_server():
		Game.instance.reset_votes()
		Game.instance.request_set_map(Game.instance.selected_map_index)


func _handle_back_pressed() -> void:
	if multiplayer.is_server():
		Lobby.instance.go_to_host()
	else:
		Lobby.instance.go_to_join()


func _handle_role_pressed() -> void:
	role_container.visible = not role_container.visible
	if map_container:
		map_container.hide()


func _fill_role_container() -> void:
	# Skip Role.NONE
	for i: int in Statics.Role.size() - 1:
		var button: Button = Button.new()
		button.text = Statics.get_role_name(i + 1)
		button.pressed.connect(func() -> void: _update_role(i + 1))
		role_list.add_child(button)


func _update_role(role: Statics.Role) -> void:
	Game.instance.set_current_player_role(role)
	role_button.text = Statics.get_role_name(role)
	role_container.hide()


func _handle_vote_updated() -> void:
	_update_player()
	if multiplayer and multiplayer.is_server():
		var all_voted: bool = true
		for player: Statics.PlayerData in Game.instance.players:
			all_voted = all_voted and player.vote
		if all_voted and _can_start_game():
			_start_timer.rpc()
		elif not start_timer.is_stopped():
			_stop_timer.rpc()

@rpc("reliable", "call_local")
func _start_timer() -> void:
	start_timer.start()
	game_start_container.show()
	role_button.disabled = true
	if map_button:
		map_button.disabled = true
	if map_container:
		map_container.hide()


@rpc("reliable", "call_local")
func _stop_timer() -> void:
	start_timer.stop()
	game_start_container.hide()
	role_button.disabled = false
	if map_button:
		map_button.disabled = not multiplayer.is_server()


@rpc("reliable", "call_local")
func _start_game() -> void:
	Game.instance.set_current_player_vote(false)
	get_tree().change_scene_to_packed(Game.instance.get_selected_map_scene())


func _can_start_game() -> bool:
	var quantity: bool = Game.instance.players.size() >= Game.instance.min_players
	var completion: bool = not Game.instance.use_roles or not Game.instance.all_roles or _are_all_roles_selected()
	var uniqueness: bool = not Game.instance.use_roles or not Game.instance.unique_roles or _are_all_roles_unique()
	var fullness: bool = not Game.instance.use_roles or _all_players_selected_role()
	return quantity and completion and uniqueness and fullness


func _update_ready_button() -> void:
	ready_button.disabled = not _can_start_game()


func _are_all_roles_selected() -> bool:
	var roles: Array = Statics.Role.values()
	# remove NONE
	roles.pop_front()
	for player: Statics.PlayerData in Game.instance.players:
		roles.erase(player.role)
	return roles.is_empty()


func _are_all_roles_unique() -> bool:
	var roles: Array = Statics.Role.values()
	# remove NONE
	roles.pop_front()
	for player: Statics.PlayerData in Game.instance.players:
		if roles.has(player.role):
			roles.erase(player.role)
		else:
			return false
	return true

func _all_players_selected_role() -> bool:
	for player: Statics.PlayerData in Game.instance.players:
		if player.role == Statics.Role.NONE:
			return false
	return true
