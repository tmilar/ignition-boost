# require_relative '../ship/ship'

class Player < Ship

  include KeyboardMovement

  attr_accessor :score

  def initialize(config = {})
    super(config)
    @score  = 0
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


  def sprite_init
    @sprite = Sprite.create({bitmap: @config[:name]})

    @sprite.ox = width / 2 ## @cw / 2
    @sprite.oy = height
    @sprite.x = Graphics.width / 2
    @sprite.y = Graphics.height - height / 4
  end

  def destroyed?
    false
    # @hp <= 0
  end

end