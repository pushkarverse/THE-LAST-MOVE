extends Node
## Global sound-effects player (registered as the autoload "AudioManager").
##
## Usage from anywhere:
##     AudioManager.play("warning")
##     AudioManager.play("stage_clear", -3.0, 1.2)
##
## Pool of 8 AudioStreamPlayers so overlapping one-shots don't cut each other off.
##
## NOTE on audio file formats:
##   walk.wav    - is actually MP3 data (wrong extension); imported as mp3.
##   damage.wav  - is AIFF format, not supported by Godot natively; remapped to warning.wav.
##   death.mp3   - real MP3, imported correctly.

const SOUNDS := {
    "walk":        "res://audio/sfx/walk.wav",
    "damage":      "res://audio/sfx/warning.wav",       # AIFF unsupported; use warning.wav instead
    "death":       "res://audio/sfx/death.mp3",
    "warning":     "res://audio/sfx/warning.wav",
    "select":      "res://audio/sfx/menu-select.wav",
    "button":      "res://audio/sfx/menu-select.wav",
    "stage_clear": "res://audio/sfx/stage-clear-8-bit.wav",
    "world_clear": "res://audio/sfx/final world-clear-8-bit.wav",
    "unlock":      "res://audio/sfx/unlock.wav",
    "door_open":   "res://audio/sfx/door_open.wav",
}

const POOL_SIZE: int = 8

var _streams: Dictionary = {}
var _players: Array[AudioStreamPlayer] = []
var _next: int = 0
var _music_player: AudioStreamPlayer
var _music_tween: Tween


func _ready() -> void:
    # Preload streams; silently skip missing/unimported files so startup never crashes.
    for key in SOUNDS.keys():
        var path: String = SOUNDS[key]
        if key == "walk" and path.ends_with(".wav"):
            # Manually load the MP3 data because the file has a .wav extension
            if FileAccess.file_exists(path):
                var f = FileAccess.open(path, FileAccess.READ)
                var stream = AudioStreamMP3.new()
                stream.data = f.get_buffer(f.get_length())
                _streams[key] = stream
            else:
                push_warning("AudioManager: could not find '%s' for key '%s'" % [path, key])
        elif ResourceLoader.exists(path):
            _streams[key] = load(path)
        else:
            push_warning("AudioManager: could not load '%s' for key '%s'" % [path, key])
    # Build playback pool.
    for i in POOL_SIZE:
        var p := AudioStreamPlayer.new()
        p.bus = &"Master"
        add_child(p)
        _players.append(p)

    # Initialize dedicated music player
    _music_player = AudioStreamPlayer.new()
    _music_player.bus = &"Master"
    add_child(_music_player)


## Play a one-shot sound by logical name. Unknown names are silently ignored.
func play(sound_name: String, volume_db: float = 0.0, pitch: float = 1.0) -> void:
    if not _streams.has(sound_name):
        return
    var p := _players[_next]
    _next = (_next + 1) % _players.size()
    p.stream = _streams[sound_name]
    p.volume_db = volume_db
    p.pitch_scale = pitch
    p.play()


func stop_all() -> void:
    for p in _players:
        p.stop()


## Play background music, optionally fading it in.
func play_music(music_path: String, fade_in_duration: float = 1.0) -> void:
    var stream = load(music_path) if ResourceLoader.exists(music_path) else null
    if not stream:
        push_warning("AudioManager: could not load music '%s'" % music_path)
        return
    
    # Don't restart if already playing the same track
    if _music_player.playing and _music_player.stream == stream:
        return
        
    if _music_tween and _music_tween.is_running():
        _music_tween.kill()

    _music_player.stream = stream
    _music_player.volume_db = -80.0
    _music_player.play()
    
    _music_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    _music_tween.tween_property(_music_player, "volume_db", 0.0, fade_in_duration)


## Stop background music, optionally fading it out smoothly.
func stop_music(fade_out_duration: float = 1.0) -> void:
    if not _music_player.playing:
        return
        
    if _music_tween and _music_tween.is_running():
        _music_tween.kill()
        
    if fade_out_duration > 0:
        _music_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
        _music_tween.tween_property(_music_player, "volume_db", -80.0, fade_out_duration)
        _music_tween.tween_callback(_music_player.stop)
    else:
        _music_player.stop()