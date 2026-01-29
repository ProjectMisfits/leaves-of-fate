extends Camera2D
## Custom camera that dynamically sets limits whenever a room is entered.

## Update the camera limits using the boundaries of the given room.
func update_camera_limits(room_collision: TileMapLayer) -> void:
	# The used cells in the tilemaplayer. Dimensions are in terms of cells.
	var room_tilemap: Rect2i = room_collision.get_used_rect()
	# The width and height of cells in the tilemaplayer. Dimensions are in pixels.
	var room_tilemap_cellsize: Vector2i = room_collision.tile_set.tile_size * room_collision.scale.x
	
	# Set left and right limits.
	limit_left = room_tilemap.position.x * room_tilemap_cellsize.x
	limit_right = room_tilemap.end.x * room_tilemap_cellsize.x
	
	# Set top and bottom limits.
	limit_top = room_tilemap.position.y * room_tilemap_cellsize.y
	limit_bottom = room_tilemap.end.y * room_tilemap_cellsize.y
