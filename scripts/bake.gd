extends SceneTree

func _init():
    print("Starting baker...")
    var scene = load("res://levels/room_01.tscn")
    var room = scene.instantiate()
    
    # Run building manually instead of _ready
    room._build_background()
    room._build_visual_tiles()
    room._build_collision()
    room._build_hazards()
    
    # Add PlayerSpawn marker
    var spawn = Marker2D.new()
    spawn.name = "PlayerSpawn"
    spawn.position = Vector2(2 * 18 + 9, 13 * 18)
    room.add_child(spawn)
    
    # Recursively set owners to the room root so they save in the .tscn
    _set_owner(room, room)
    
    var packed = PackedScene.new()
    packed.pack(room)
    var err = ResourceSaver.save(packed, "res://levels/room_01_baked.tscn")
    
    var f = FileAccess.open("res://bake_result.txt", FileAccess.WRITE)
    if err == OK:
        f.store_string("Bake successful!")
    else:
        f.store_string("Bake failed with error code: " + str(err))
    f.close()
    
    quit()

func _set_owner(node: Node, root: Node) -> void:
    if node != root:
        node.owner = root
    
    if node.scene_file_path != "" and node != root:
        # Stop assigning owners for children of instanced scenes
        return
        
    for child in node.get_children():
        _set_owner(child, root)
