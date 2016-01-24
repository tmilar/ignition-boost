class Enemy < Ship

  include ZigZagMovement

  def initialize(config = {})
    super(config)
    @config = config
    self.limits.height += self.height
  end

  def position_init
    self.position = Point.new( rand(Graphics.width) , 0 )
  end

  def weapon_pos
    Point.new(self.x, self.y + self.height)
  end

  def check_shoot
    rand(1000) > (995 - @config[:stats][:shoot_freq])
  end
end