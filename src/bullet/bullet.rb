
class Bullet
  extend Forwardable
  include Subject

  def_delegators :@sprite, :x, :y, :ox, :oy, :zoom_x, :zoom_y, :height, :width
  def_delegators :@sprite, :position, :position=, :rectangle
  attr_accessor :sprite

  include LinearMovement

  attr_accessor :direction
  attr_reader :stats

  def initialize(config ={})
    super(config)
    @sprite = Sprite.create({ name: config[:name],
                              bitmap: config[:name]})
    self.position = config[:position]
    self.limits.height += self.height

    @direction = config[:direction]
    @stats = config[:stats]
  end

  def update
    update_movement
    @sprite.update
  end

  def dispose
    @sprite.dispose
  end

  def disposed?
    @sprite.disposed?
  end

  def player_hit
    notify_observers("player_hit", self)
  end

  def enemy_hit
    notify_observers("enemy_hit", self)
  end
end