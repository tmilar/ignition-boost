
class Bullet
  extend Forwardable
  include Subject

  def_delegators :@sprite, :x, :y, :ox, :oy, :zoom_x, :zoom_y, :height, :width, :bitmap, :name, :dispose, :disposed?
  def_delegators :@sprite, :position, :position=, :rectangle, :collision_rect
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
    config[:init_pos] = lambda { |sprite| config[:position] + Point.new(- sprite.width / 2, 0) }

    @sprite = Sprite.create({ name: config[:name],
                              bitmap: config[:name],
                              init_pos: config[:init_pos]
                            })

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

  def ship_hit(ship)
    # #{type}_hit = player_hit || enemy_hit
    notify_observers("#{ship.type}_hit", self)
    self.dispose
  end

  def type
    self.class.to_s.uncapitalize
  end

  def to_s
    "<#{self.class}> '#{self.name}'"
  end
end