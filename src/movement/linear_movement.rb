module LinearMovement
  include Movement

  def update_movement
    move_dir(self.direction)
  end
end