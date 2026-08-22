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
    "walk":        "res://audio/sfx/walk.wav",          # MP3 data, imported as AudioStreamMP3
    "damage":      "res://audio/sfx/warning.wav",       # AIFF unsupported; use warning.wav instead
    "death":       "res://audio/sfx/death.mp3",
    "warning":     "res://audio/sfx/warning.wav",
    "select":      "res://audio/sfx/menu-select.wav",
    "button":      "res://audio/sfx/menu-select.wav",
    "stage_clear": "res://audio/sfx/stage-clear-8-bit.wav",
    "world_clear": "res://audio/sfx/final world-clear-8-bit.wav",
}

const POOL_SIZE: int = 8

var _streams: Dictionary = {}
var _players: Array[AudioStreamPlayer] = []
var _next: int = 0


func _ready() -> void:
    # Preload streams; silently skip missing/unimported files so startup never crashes.
    for key in SOUNDS.keys():
        var path: String = SOUNDS[key]
        if ResourceLoader.exists(path):
            _streams[key] = load(path)
        else:
            push_warning("AudioManager: could not load '%s' for key '%s'" % [path, key])
    # Build playback pool.
    for i in POOL_SIZE:
        var p := AudioStreamPlayer.new()
        p.bus = &"Master"
        add_child(p)
        _players.append(p)


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