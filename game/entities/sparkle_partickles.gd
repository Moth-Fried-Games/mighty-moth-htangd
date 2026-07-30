extends GPUParticles2D


func _ready() -> void:
	emitting = true
	GameGlobals.audio_manager.create_audio("sound_explosion")
	finished.connect(queue_free)
