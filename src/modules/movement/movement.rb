class Movement
  include Subject
  extend Forwardable

  DIRECTIONS = {
      :LEFT => Point.new(-1, 0),
      :RIGHT => Point.new(+1, 0),
      :UP => Point.new(0, -1),
      :DOWN => Point.new(0, +1),
  }

  def_delegators :@sprite, :x, :y, :position, :position=, :rectangle, :rectangle=, :collision_rect, :disposed?, :width, :height, :ox, :oy
  def_delegators :@game_entity, :speed, :type, :direction
  attr_accessor :sprite, :game_entity

  # Receive a {movement type}, return a newly created Movement instance
  def self.create(type, config)
    case type.to_sym
      when :linear_movement             then LinearMovement.new(config)
      when :keyboard_movement           then KeyboardMovement.new(config)
      when :zig_zag_movement            then ZigZagMovement.new(config)
      when :none, :no_movement, :freeze then NoMovement.new(config)
      else raise "Can't create invalid movement type #{type}! Please use a valid one"
    end
  end

  def initialize(config = {})
    Logger.start("Movement#'#{self.class}'", config)
    @game_entity = config[:game_entity]
    raise "Can' initialize movement without a defined sprite!" unless @game_entity.sprite
    @sprite = @game_entity.sprite ##config[:sprite]
    @observers = @game_entity.observers ##config[:observers] if config.key?(:observers) && config[:observers]
    # @speed = (config[:speed] if config.key?(:speed) && config[:speed]) || (config[:stats][:speed] if config.key?(:stats)) || 0.5
    # @type = config[:type]
  end

  def update
    return Logger.debug("Returning from #{self.class} Movement, #{self} is disposed") if disposed?
    update_movement
  end

  ## must be defined in child implementations
  def update_movement
    raise 'Not implemented!'
  end

  # Method to be included in movible game objects.
  # direction can be a Symbol (:LEFT, :UP, :DOWN, :RIGHT ) or a Point object
  def move(direction = Point.new(1, 0), calculated_speed = false)
    return Logger.debug("#{self} can't move, is disposed!") if disposed?

    speed = calculated_speed || self.speed
    return if speed.abs < 0.0001

    dir_xy = parse_direction(direction)

    # Logger.trace("[#{self}] Trying to move sprite to direction: #{dir_xy}") if (self.is_a?(Bullet) && !@logged_dir)
    # @logged_dir = true
    self.move_xy(dir_xy * speed)
  end

  def move_xy(offset_xy)
    notify_observers("#{type}_moved", @game_entity)
    self.position += offset_xy
  end

  def parse_direction(dir)
    case dir
      when Symbol then DIRECTIONS[dir]
      when Point  then dir
      else raise "Invalid direction '#{dir}', type inputted: '#{dir.class}'"
    end
  end

end

