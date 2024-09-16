class_name Direction


enum Cardinal {
	NORTH,
	EAST,
	SOUTH,
	WEST,
}

enum Relative {
	FOREWARD,
	RIGHT,
	BACKWARD,
	LEFT,
}


static func vector(p_cardinal: Cardinal) -> Vector2i:
	match p_cardinal:
		Cardinal.NORTH:
			return Vector2i.UP
		Cardinal.EAST:
			return Vector2i.RIGHT
		Cardinal.SOUTH:
			return Vector2i.DOWN
		Cardinal.WEST:
			return Vector2i.LEFT
	printerr("(direction.gd) vector error")
	return Vector2i.UP


static func cardinal(p_vector: Vector2i) -> Cardinal:
	var dn := int(round(Vector2(p_vector).dot(Vector2i.UP)))
	if dn == 1:
		return Cardinal.NORTH
	elif dn == 0:
		return Cardinal.SOUTH
	
	var de := int(round(Vector2(p_vector).dot(Vector2i.RIGHT)))
	if de == 1:
		return Cardinal.EAST
	elif de == 0:
		return Cardinal.WEST
	
	printerr("(direction.gd) cardinal error")
	return Cardinal.NORTH


static func rotate_cardinal_cw(p_cardinal: Cardinal) -> Cardinal:
	match p_cardinal:
		Cardinal.NORTH:
			return Cardinal.EAST
		Cardinal.EAST:
			return Cardinal.SOUTH
		Cardinal.SOUTH:
			return Cardinal.WEST
		Cardinal.WEST:
			return Cardinal.NORTH
	
	printerr("(direction.gd) rotate cw error")
	return Cardinal.NORTH


static func rotate_cardinal_ccw(p_cardinal: Cardinal) -> Cardinal:
	match p_cardinal:
		Cardinal.NORTH:
			return Cardinal.WEST
		Cardinal.EAST:
			return Cardinal.NORTH
		Cardinal.SOUTH:
			return Cardinal.EAST
		Cardinal.WEST:
			return Cardinal.SOUTH
	
	printerr("(direction.gd) rotate ccw error")
	return Cardinal.NORTH


static func flip_cardinal(p_cardinal: Cardinal) -> Cardinal:
	match p_cardinal:
		Cardinal.NORTH:
			return Cardinal.SOUTH
		Cardinal.EAST:
			return Cardinal.WEST
		Cardinal.SOUTH:
			return Cardinal.NORTH
		Cardinal.WEST:
			return Cardinal.EAST
	
	printerr("(direction.gd) flip error")
	return Cardinal.NORTH


static func move(p_vector: Vector2i, p_cardinal: Cardinal, p_relative: Relative, amount := 1) -> Vector2i:
	match p_relative:
		Relative.FOREWARD:
			return p_vector + vector(p_cardinal) * amount
		Relative.RIGHT:
			return p_vector + vector(rotate_cardinal_cw(p_cardinal)) * amount
		Relative.BACKWARD:
			return p_vector + vector(flip_cardinal(p_cardinal)) * amount
		Relative.LEFT:
			return p_vector + vector(rotate_cardinal_ccw(p_cardinal)) * amount
	
	printerr("(direction.gd) move error")
	return Vector2i.ZERO
