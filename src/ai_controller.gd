class_name AIController
extends Controller


const _TIME_COMPREHENSION := 1.0

var _world: World


func _ready() -> void:
	if get_parent() is World:
		_world = get_parent()


func _turn_begun() -> void:
	for board in _world.get_boards():
		var pieces = get_tree().get_nodes_in_group(&"pieces").filter(func(p): return p.board == board)
		
		if pieces.is_empty():
			continue
		
		var my_pieces = pieces.filter(func(p): return p.team == get_team())
		var enemy_pieces = pieces.filter(func(p): return Piece.can_team_strike_team(get_team(), p.team))
		
		if enemy_pieces.is_empty():
			continue
		
		for my_piece: Piece in my_pieces:
			# If can strike, do so
			if not my_piece.get_strikeable_positions().is_empty():
				var strike_pos = my_piece.get_strikeable_positions().pick_random()
				var enemy_piece = enemy_pieces.filter(func(p): return p.grid_position == strike_pos)[0]
				enemy_piece.kill()
				my_piece.move(strike_pos)
				enemy_pieces.erase(enemy_piece)
				await get_tree().create_timer(_TIME_COMPREHENSION).timeout
				continue
			
			# If can move, do os
			if not my_piece.get_movable_positions().is_empty():
				var closest_enemy: Piece
				var closest_dist := INF
				for enemy_piece in enemy_pieces:
					var comp_dist: float = enemy_piece.grid_position.distance_squared_to(my_piece.grid_position)
					if comp_dist < closest_dist:
						closest_enemy = enemy_piece
						closest_dist = comp_dist
				
				if closest_enemy == null:
					my_piece.move(my_piece.get_movable_positions().pick_random())
					await get_tree().create_timer(_TIME_COMPREHENSION).timeout
					continue
				
				var closest_achievable_position: Vector2i
				closest_dist = INF
				for pos in my_piece.get_movable_positions():
					var comp_dist: float = closest_enemy.grid_position.distance_squared_to(pos)
					if comp_dist < closest_dist:
						closest_achievable_position = pos
						closest_dist = comp_dist
				
				my_piece.move(closest_achievable_position)
				await get_tree().create_timer(_TIME_COMPREHENSION).timeout
	
	turn_passed.emit()


func _get_team() -> Piece.Team:
	return Piece.Team.WHITE
