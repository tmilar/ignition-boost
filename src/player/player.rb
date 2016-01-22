# require_relative '../ship/ship'

class Player < Ship

  include KeyboardMovement

  def initialize(config = {})
    super(config)
  end

  # @Override Movement init_position
  def init_position
    @position = Point.new(Graphics.width / 2, Graphics.height - self.height)
  end

  # Scene update, one per frame
  def update
    super
    ## TODO pendiente  updatear el cell sprite de la nave, segun la direccion...
  end


end