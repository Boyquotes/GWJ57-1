extends TileMap

export var sizeOfBoardX = 14
export var sizeOfBoardY = 8
export var bombCount = 35

signal goodTileClicked
signal badTileClicked


# Called when the node enters the scene tree for the first time.
func _ready():

	setup_empty_board()

	$TopLeftCorner.visible = false
	pass # Replace with function body.

func _input(event):
	if(event.is_class("InputEventMouseButton") and event.is_pressed()):
		action_tile(world_to_map(get_global_mouse_position()))
		


func setup_empty_board():
	#setup the bvoard to match the X and Y
	for i in get_used_cells():
		set_cellv(i,-1)
	for x in range(sizeOfBoardX):
		for y in range(sizeOfBoardY):
			set_cellv(Vector2(x,y),12)
	# adjust the size of the blocker to cover the whole board post setup
	$SuperFirstClickCockBlocker.rect_position = Vector2(0,0)
	$SuperFirstClickCockBlocker.rect_size = Vector2(sizeOfBoardX*cell_size.x,sizeOfBoardY*cell_size.y)
	$SuperFirstClickCockBlocker.visible = true
	pass

func place_bombs_on_board():
	set_cellv(world_to_map(get_global_mouse_position()),10) #this prevents first click from being a bomb
	
	var bombsPlaced = 0
	while bombsPlaced < bombCount: 
		# pick a random spot on board
		var radomTile = Vector2(randi()%sizeOfBoardX,randi()%sizeOfBoardY)
		if get_cellv(radomTile) == 12:
			set_cellv(radomTile,11)
			bombsPlaced += 1
		
		# if spot is free -> place bomb and bomsPlaced++
		
	#set all dummy tiles to empties once bombs are placed
	for x in range(sizeOfBoardX):
		for y in range(sizeOfBoardY):
			if get_cellv(Vector2(x,y)) == 12:
				set_cellv(Vector2(x,y),10)
		pass
	action_tile(world_to_map(get_global_mouse_position()))
	pass


func scan_tile(tile):
	emit_signal("goodTileClicked")
	var adjesent_tiles = [tile+Vector2(1,0), tile+Vector2(0,1), tile+Vector2(1,1), tile+Vector2(-1,0), tile+Vector2(0,-1), tile+Vector2(-1,-1), tile+Vector2(-1,1), tile+Vector2(1,-1)]
	var bomb_count = 0
	for x in adjesent_tiles :
		if (get_cellv(x)==11 or get_cellv(x)==9):
			bomb_count+=1
	set_cellv(tile,bomb_count)
	if(bomb_count == 0):
		for z in adjesent_tiles :
			if (get_cellv(z) == 10):
				scan_tile(z)

	return bomb_count
	pass

func action_tile(tile):
	match(get_cellv(tile)):
		10:
			scan_tile(tile)
		11:
			set_cellv(tile,9)
			emit_signal("badTileClicked")
	pass
	


func _on_SuperFirstClickCockBlocker_gui_input(event:InputEvent):
	if event.is_pressed():
		place_bombs_on_board()
		$SuperFirstClickCockBlocker.visible = false
	pass # Replace with function body.
