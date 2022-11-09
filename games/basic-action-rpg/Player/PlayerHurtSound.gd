# not using the audio player in the player scene for this sound
# because if the player gets hit and dies, it gets removed so the sound
# would be immediately cut
extends AudioStreamPlayer

func _ready():
	connect("finished", self, "queue_free")
