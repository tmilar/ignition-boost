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

  def player_collision(player)
    Logger.trace("collided with #{player}, coll dmg #{player.stats[:collide_damage]}, coll resist #{@stats[:collide_resistance]}")
    self.hp -= player.stats[:collide_damage] - (@stats[:collide_resistance] || 0)
  end

  def plazor_hit(plazor)
    Logger.trace("collided with #{plazor}, coll dmg #{plazor.stats[:damage]}")
    self.hp -= plazor.stats[:damage]
  end
end