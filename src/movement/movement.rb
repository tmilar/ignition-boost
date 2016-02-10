module Movement

  DIRECTIONS = {
      :LEFT => Point.new(-1, 0),
      :RIGHT => Point.new(+1, 0),
      :UP => Point.new(0, -1),
      :DOWN => Point.new(0, +1),
  }

  attr_accessor :limits

  def initialize(config = {})
    super(config)

    # @logged_dir = false
  end

  def update
    return Logger.debug("Returning from #{self.class} Movement, #{self} is disposed") if self.disposed?
    super
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
    dir_xy = parse_direction(direction)

    # Logger.trace("[#{self}] Trying to move sprite to direction: #{dir_xy}") if (self.is_a?(Bullet) && !@logged_dir)
    # @logged_dir = true
    speed = calculated_speed || self.speed
    self.move_xy(dir_xy * speed)
  end

  def move_xy(offset_xy)
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

