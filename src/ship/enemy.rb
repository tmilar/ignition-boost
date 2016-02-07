class Enemy < Ship

  include ZigZagMovement

  DEFAULTS_ENEMY = {
      cells: 1,
      # limits: {
      #     x: [0.0, 1.0],
      #     y: [0.0, 1.0]
      # }
  }
  def initialize(config = {})
    config = DEFAULTS_ENEMY.deep_merge(config)
    super(config)
  end

  def position_init
    self.position = Point.new( rand(Graphics.width) , 0 - self.height + 1 )
  end

  def weapon_pos
    Point.new(self.x + self.width/2, self.y + self.height)
  end

  def check_shoot
    rand(1000) > (995 - @config[:stats][:shoot_freq])
  end
end