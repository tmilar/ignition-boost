class KeyboardMovement < Movement
  def update_movement
    move(:LEFT)  if Input.press?(:LEFT) && !Input.press?(:RIGHT)
    move(:RIGHT) if Input.press?(:RIGHT) && !Input.press?(:LEFT)
    move(:UP)    if Input.press?(:UP)
    move(:DOWN)  if Input.press?(:DOWN)
  end
end