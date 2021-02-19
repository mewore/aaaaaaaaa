extends PlayerState

func physics_process(delta: float) -> void:
    player.move(delta)

func unhandled_input(event: InputEvent) -> void:
    player.handle_jump_control(event)

func _on_Player_reached_win_area() -> void:
    self.next_state = WINNING
