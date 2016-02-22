
class Bullet
  extend Forwardable
  include Subject

  def_delegators :@sprite, :x, :y, :ox, :oy, :zoom_x, :zoom_y, :height, :width, :bitmap, :name, :dispose, :disposed?
  def_delegators :@sprite, :position, :position=, :rectangle, :collision_rect
  attr_accessor :sprite

  include LinearMovement

  attr_accessor :direction
  attr_reader :stats

  attr_readers_delegate :@config, :name, :direction, :stats, :shooter, :observers
  attr_readers_delegate :@stats, :speed

  # :observers
  # :name
  # :position
  # :direction
  # :stats
  # :shooter
  # :observers
  def initialize(config ={})
    @stats = config[:stats].deep_clone
    @config = config.deep_clone
    super(@config)
    notify_observers("new_#{type}", self)  ## new_elazor || new_plazor
    Logger.trace("#{self} launched, conf: #{@config}")
  end

  def sprite_init
    Sprite.create({
                      name: @config[:name],
                      bitmap: @config[:name],
                      init_pos: self.position_init
                  })
  end

  def position_init
    lambda { |sprite| @config[:position] + Point.new(- sprite.width / 2, 0) }
  end

  def update
    update_movement
    @sprite.update
  end

  # #{type}_hit = player_hit || enemy_hit
  def collide_with(ship)
    notify_observers("#{ship.type}_hit", self)
    self.dispose unless self.disposed?
  end

  def type
    case shooter
      when 'enemy' then 'elazor'
      when 'player' then 'plazor'
      else raise "Invalid Bullet type, shooter #{shooter} not supported!"
    end
  end

  def to_s
    "<#{self.class}:#{type}> '#{name}'"
  end
end