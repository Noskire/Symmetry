extends Area2D

# Grid info
export var grid_width = 3
export var grid_height = 3
export var cell_size = 256

# Piece info
export var size_x = 1
export var size_y = 2
var original_position

# Aux var
var pos
var rest
var offset
var snap_to_next

var on_grid = false
var selected = false
var snapped = true

func _ready():
	original_position = position
	#12.5 instead of 12.8 to give some space between areas
	get_node("Collision").scale.x = 12.5 * size_x
	get_node("Collision").scale.y = 12.5 * size_y

func _process(_delta):
	if selected:
		position = get_global_mouse_position()
	elif not snapped:
		snapped = true
		on_grid = true
		
		# Has offset if size is odd
		if size_x % 2 == 1:
			offset = 128
		else:
			offset = 0
		
		# Snap position to grid
		pos = int(position.x) - offset
		rest = pos % cell_size
		position.x = pos - rest + offset
		
		# If mouse after half cell size, snap to slot in the right
		snap_to_next = (rest > cell_size / 2)
		if snap_to_next:
			position.x += cell_size
		
		# Check if piece is inside grid
		if (position.x - offset) < 0 or (position.x - offset) > (cell_size * (grid_width - 1)):
			on_grid = false
		
		# Repeat to y
		if size_y % 2 == 1:
			offset = 128
		else:
			offset = 0
		pos = int(position.y) - offset
		rest = pos % cell_size
		position.y = pos - rest + offset
		snap_to_next = (rest > cell_size / 2)
		if snap_to_next:
			position.y += cell_size
		if (position.y - offset) < 0 or (position.y - offset) > (cell_size * (grid_height - 1)):
			on_grid = false
		
		# If touching another area or outside of grid, back to original position
		if not get_overlapping_areas().empty() or not on_grid:
			position = original_position
		else:
			# Chack if all pieces are on grid
			var pieces = get_tree().get_nodes_in_group("Pieces")
			var win = true
			for p in pieces:
				if p.on_grid == false:
					win = false
					break
			if win:
				print("All objects are on grid. WIN!")

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			selected = true
			snapped = false
		else:
			selected = false
