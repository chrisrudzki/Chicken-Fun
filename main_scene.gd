extends Node2D



var mynode = preload("res://boid.tscn")
var boid_num = 0

var astar_grid

func _ready():
	
	
	
	astar_grid = AStarGrid2D.new()
	#astar_grid.region = Rect2i(0,0, 74, 70)
	#astar_grid.cell_size = Vector2(16, 16)
	#
	astar_grid.region = Rect2i(0, 0, 565, 421)
	astar_grid.cell_size = Vector2(16, 16)
	astar_grid.update()
	
	#print("here")
	print(astar_grid.get_id_path(Vector2i(0, 0), Vector2i(3, 4))) # prints (0, 0), (1, 1), (2, 2), (3, 3), (3, 4)
	print(astar_grid.get_point_path(Vector2i(0, 0), Vector2i(3, 4))) # prints (0, 0), (16, 16), (32, 32), (48, 48), (48, 64)
	
	
	#print(size.x, size.y)
func get_path_arr(boid_postion, player_position):
	#print("hh")
	#print("aa", astar_grid.get_point_path(boid_postion, player_position))
	
	#var astar_grid = AStarGrid2D.new()
	#boid_postion.x = int(boid_postion.x)
	#boid_postion.y = int(boid_postion.y)
	#
	#player_position.x = int(player_position.x)
	#player_position.y = int(player_position.y)
	#
	
	#print(astar_grid.get_id_path(boid_postion, player_position))
	
	#print(boid_postion)
	#print(player_position)
	
	return astar_grid.get_id_path(boid_postion, player_position)
	
	
	
func _physics_process(delta: float) -> void:
	
	if Input.is_action_just_pressed("click"):
		var click_position = get_global_mouse_position()
		inst(click_position)
	

func inst(pos):
	var ins = mynode.instantiate()
	
	
	ins.boid_num = boid_num + 1
	boid_num = boid_num + 1
	ins.position = pos
	
	add_child(ins)
	
