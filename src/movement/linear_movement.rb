module LinearMovement
  include Movement

  def update_movement
    move(self.direction)
  end
end