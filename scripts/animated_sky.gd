extends CanvasLayer

## Animated Sky Background
## Manages a pool of clouds and birds to create a continuous, looping background.

@export var sky_color: Color = Color(0.45, 0.7, 0.95, 1.0)
@export var cloud_texture: Texture2D
@export var character_texture: Texture2D

# Screen boundaries
const SCREEN_WIDTH = 640
const SCREEN_HEIGHT = 360
const SPAWN_BUFFER = 100

class CloudInstance:
	var sprite: Sprite2D
	var speed: float

class BirdInstance:
	var sprite: Sprite2D
	var speed: float
	var flap_timer: float
	var flap_interval: float
	var frame_idx: int = 0

var _clouds: Array[CloudInstance] = []
var _birds: Array[BirdInstance] = []

func _ready() -> void:
	layer = -1 # Keep behind gameplay
	
	_setup_sky_base()
	if cloud_texture:
		_setup_clouds()
	if character_texture:
		_setup_birds()

func _setup_sky_base() -> void:
	var rect = ColorRect.new()
	rect.color = sky_color
	# Make it large enough to cover any camera shakes or slight offsets
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(rect)

func _setup_clouds() -> void:
	var cloud_container = Node2D.new()
	cloud_container.name = "Clouds"
	add_child(cloud_container)
	
	# Create ~10 clouds
	for i in 10:
		var c = CloudInstance.new()
		c.sprite = Sprite2D.new()
		c.sprite.texture = cloud_texture
		c.sprite.region_enabled = true
		
		# Single variation for cloud: 32x16
		c.sprite.region_rect = Rect2(0, 0, 32, 16) 

		
		# Randomize depth/scale to simulate Far, Mid, Near
		var depth_category = randi() % 3
		var scale_val = 1.0
		var alpha = 1.0
		if depth_category == 0:
			# Far
			scale_val = 1.0
			c.speed = randf_range(10.0, 15.0)
			alpha = 0.5
		elif depth_category == 1:
			# Mid
			scale_val = 1.5
			c.speed = randf_range(20.0, 30.0)
			alpha = 0.75
		else:
			# Near
			scale_val = 2.0
			c.speed = randf_range(35.0, 45.0)
			alpha = 0.9
			
		c.sprite.scale = Vector2(scale_val, scale_val)
		c.sprite.modulate = Color(1.0, 1.0, 1.0, alpha)
		
		# Initial random position
		c.sprite.position = Vector2(
			randf_range(-SPAWN_BUFFER, SCREEN_WIDTH + SPAWN_BUFFER),
			randf_range(20, 150)
		)
		
		cloud_container.add_child(c.sprite)
		_clouds.append(c)


func _setup_birds() -> void:
	var bird_container = Node2D.new()
	bird_container.name = "Birds"
	add_child(bird_container)
	
	# Create 3-4 birds
	for i in range(randi_range(3, 4)):
		var b = BirdInstance.new()
		b.sprite = Sprite2D.new()
		b.sprite.texture = character_texture
		b.sprite.region_enabled = true
		
		# Our custom bird asset is 32x16 (2 frames, 16x16 each)
		# Frame 0 is at x=0
		b.sprite.region_rect = Rect2(0, 0, 16, 16)

		
		# Birds should be small
		b.sprite.scale = Vector2(0.8, 0.8)
		b.sprite.modulate = Color(1.0, 1.0, 1.0, 0.7) # Slightly faded for distance
		
		b.speed = randf_range(25.0, 50.0)
		b.flap_interval = randf_range(0.25, 0.4)
		b.flap_timer = 0.0
		
		# Birds fly LEFT to RIGHT, so facing right (flip_h if original sprite faces left)
		# Kenney's usually face right by default, but we'll leave flip_h false unless it looks backwards.
		
		b.sprite.position = Vector2(
			randf_range(-SPAWN_BUFFER, SCREEN_WIDTH + SPAWN_BUFFER),
			randf_range(30, 120)
		)
		
		bird_container.add_child(b.sprite)
		_birds.append(b)


func _process(delta: float) -> void:
	# Move Clouds (RIGHT -> LEFT)
	for c in _clouds:
		c.sprite.position.x -= c.speed * delta
		
		# Loop to right side
		if c.sprite.position.x < -SPAWN_BUFFER:
			c.sprite.position.x = SCREEN_WIDTH + SPAWN_BUFFER
			c.sprite.position.y = randf_range(20, 150)
			
	# Move Birds (LEFT -> RIGHT)
	for b in _birds:
		b.sprite.position.x += b.speed * delta
		
		# Loop to left side
		if b.sprite.position.x > SCREEN_WIDTH + SPAWN_BUFFER:
			b.sprite.position.x = -SPAWN_BUFFER
			b.sprite.position.y = randf_range(30, 120)
			
		# Flap animation
		b.flap_timer += delta
		if b.flap_timer >= b.flap_interval:
			b.flap_timer = 0.0
			b.frame_idx = 1 - b.frame_idx # Toggle between 0 and 1
			# Our frames are 16x16, starting at x=0
			b.sprite.region_rect.position.x = b.frame_idx * 16
