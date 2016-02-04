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
    init_limits(config[:position_limits])
  end

  def init_limits(defined_limits = nil)

    if valid_config_limits?(defined_limits)
      @limits = Rectangle.new(Graphics.width * limits[:x][0],
                              Graphics.height * limits[:y][0],
                              Graphics.width * limits[:x][1],
                              Graphics.height * limits[:y][1])
    else
      @limits = Rectangle.new(0, 0, Graphics.width, Graphics.height)
    end

    Logger.debug("initialized limits! -> #{@limits}")
  end

  def valid_config_limits?(limits)
    !limits.nil? &&
        !limits.empty? &&
        limits.key?(:x) &&
        limits.key?(:y) &&
        limits[:x].size.equal?(2) &&
        limits[:y].size.equal?(2)
  end

  def update
    super
    update_movement
  end

  ## must be defined in child implementations
  def update_movement
    raise 'Not implemented!'
  end

  # Method to be included in movible game objects.
  # direction can be a Symbol (:LEFT, :UP, :DOWN, :RIGHT ) or a Point vector object
  def move(direction = Point.new(1, 0), calculated_speed = false)
    dir_xy = parse_direction(direction)
    # Logger.trace("[#{self}] Trying to move sprite to direction: #{dir_xy}, stats are: #{self.stats}")
    speed = calculated_speed || self.speed
    self.move_x(dir_xy.x * speed)
    self.move_y(dir_xy.y * speed)
  end

  def move_x(offset_x)
    new_pos = self.position + Point.new(offset_x, 0)
    try_move(new_pos)
  end

  def move_y(offset_y)
    new_pos = self.position + Point.new(0, offset_y)
    try_move(new_pos)
  end

  def try_move(new_pos)
    self.position = new_pos if @limits.contains_point(new_pos, true)
  end

  def parse_direction(dir)
    case dir
      when Symbol then DIRECTIONS[dir]
      when Point  then dir
      else raise "Invalid direction '#{dir}', type inputted: '#{dir.class}'"
    end
  end

end

