class_name EventDelegateLandOnPosition
extends EventDelegate


@export var board: Board
@export var grid_position := Vector2i.ZERO
@export_subgroup("filter_type_")
@export var filter_type_enabled := false
@export var filter_type_type := Piece.Type.PAWN
@export_subgroup("filter_team_")
@export var filter_team_enabled := false
@export var filter_team_team := Piece.Team.WHITE


func _ready() -> void:
	board.piece_set.connect(_handle)


func _handle(grid_position_: Vector2i, type: Piece.Type, team: Piece.Team) -> void:
	if grid_position != grid_position_:
		return
	
	if filter_type_enabled and type != filter_type_type:
		return
	
	if filter_team_enabled and team != filter_team_team:
		return
	
	permission = true
