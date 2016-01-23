# require_relative '../ship/ship'

class Player < Ship

  include KeyboardMovement

  attr_accessor :score

  def initialize(config = {})
    super(config)
    @score  = 0
  end

  # @Override Ship init_position
  def position_init
    self.position = Point.new(Graphics.width / 2, Graphics.height - self.height)
  end

  # Scene update, one per frame
  def update
    super
    ## TODO pendiente  updatear el cell sprite de la nave, segun la direccion...
  end



  def destroyed?
    false
    # @hp <= 0
  end

end