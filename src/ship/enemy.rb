class Enemy < Ship

  include ZigZagMovement

  def initialize(config = {})
    super(config)
    self.limits.height += self.height
  end

  def position_init
    self.position = Point.new( rand(Graphics.width) , 0 )
  end


end