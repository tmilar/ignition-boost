module Movement
  MOVEMENTS = {
      :LEFT => lambda { |sprite| sprite.move_x(-1)},
      :RIGHT => lambda { |sprite| sprite.move_x(+1) },
      :UP => lambda { |sprite| sprite.move_y(-1) },
      :DOWN => lambda { |sprite| sprite.move_y(+1) }
  }

  def initialize(config = {})
    super(config)
    init_position
    init_limits(config[:position_limits])
  end

  def init_position
    @position = Point.new(0,0)
  end

  def init_limits(limits)
    if limits.kind_of?(Rectangle)
      @limits = limits
    elsif valid_config_limits?(limits)
      @limits = Rectangle.new(Graphics.width * limits[:x][0],
                              Graphics.height * limits[:y][0],
                              Graphics.width * limits[:x][1],
                              Graphics.height * limits[:y][1])
    end

    @limits = Rectangle.new(0, 0, Graphics.width, Graphics.height)

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

  # Method to be included in movible game objects
  def move(direction = :DOWN)
    MOVEMENTS[direction].call(self)
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
    self.position = new_pos if @limits.contains_point(new_pos)
  end

end

