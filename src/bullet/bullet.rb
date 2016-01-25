
class Bullet
  extend Forwardable
  include Subject

  def_delegators :@sprite, :x, :y, :ox, :oy, :zoom_x, :zoom_y, :height, :width, :bitmap
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

  def ship_hit(ship)
    # #{ship_type}_hit = player_hit || enemy_hit
    notify_observers("#{ship.ship_type}_hit", self)
    self.dispose
  end
end