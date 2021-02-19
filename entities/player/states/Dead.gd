extends PlayerState

func enter() -> void:
    self.player

func exit() -> void:
    self.player.invulnerable = false
    self.player.SPRITE.visible = true
