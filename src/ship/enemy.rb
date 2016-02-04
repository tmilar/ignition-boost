class Enemy < Ship

  include ZigZagMovement

  DEFAULTS_ENEMY = {
      cells: 1,
  }
  def initialize(config = {})
    config = DEFAULTS_ENEMY.merge(config)
    super(config)
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