
class Bullet
  extend Forwardable
  include Subject

  def_delegators :@sprite, :x, :y, :ox, :oy, :zoom_x, :zoom_y, :height, :width, :bitmap, :name
  def_delegators :@sprite, :position, :position=, :rectangle
  attr_accessor :sprite

  include LinearMovement

  attr_accessor :direction
  attr_reader :stats

  # :name
  # :position
  # :direction
  # :stats
  def initialize(config ={})
    super(config)
    @sprite = Sprite.create({ name: config[:name],
                              bitmap: config[:name]})
    config[:position].x -= self.width / 2
    self.position = config[:position]

    @direction = config[:direction]
    @stats = config[:stats]
    Logger.trace("#{self} launched, conf: #{config}")
  end

  def speed
    @stats[:speed]
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

  def to_s
    "<#{self.class}> '#{self.name}'"
  end
end