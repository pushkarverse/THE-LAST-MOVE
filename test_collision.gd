extends SceneTree

func _init():
    var player = load("res://scenes/player.tscn").instantiate()
    var spike = load("res://scenes/hazards/spike.tscn").instantiate()
    var mp = load("res://scenes/hazards/moving_platform.tscn").instantiate()
    
    print("Player layer: ", player.collision_layer, " mask: ", player.collision_mask)
    print("Spike layer: ", spike.collision_layer, " mask: ", spike.collision_mask)
    print("MP layer: ", mp.collision_layer, " mask: ", mp.collision_mask)
    print("Player has die: ", player.has_method("die"))
    
    quit()