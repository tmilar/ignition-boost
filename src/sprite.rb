class Sprite

  attr_accessor :rectangle, :float_x, :float_y, :collision_rect
  attr_accessor :name
  attr_reader :cell
  attr_accessor :gameobj_id

  attr_accessor :sprite_disposed

  @viewport = {}

  ZERO_EPSILON = 0.00001
  @@screen_rect = nil ## if screen ever changes, RECALCULATE this const too

  def self.create(args = {})
    defaults = {
        x: 30,
        y: 30,
        bitmap: "NO_IMAGE",
        zoom_x: 1,
        zoom_y: 1,
        name: nil,
        cells: 1,
        init_pos: nil ## lambda { |sprite| Point.new(sprite.x, sprite.y) }
    }

    config = defaults.merge(args)
    # Logger.start("sprite", args, defaults)
    new_sprite = Sprite.new(@viewport)
    new_sprite.sprite_disposed = false
    new_sprite.name = config[:name] || config[:bitmap]
    new_sprite.bitmap = Cache.space(config[:bitmap].split(':')[0])
    new_sprite.gameobj_id = config[:bitmap].split(':')[1].to_i
    new_sprite.init_cells(config[:cells]) if config[:cells] > 1

    init_pos = config[:init_pos] ? config[:init_pos].call(new_sprite) : Point.new(config[:x], config[:y])

    new_sprite.float_x = init_pos.x ##config[:x]
    new_sprite.float_y = init_pos.y ##config[:y]
    new_sprite.x = new_sprite.float_x
    new_sprite.y = new_sprite.float_y
    new_sprite.z = config[:z] if config.key?(:z)
    new_sprite.ox = 0
    new_sprite.oy = 0
    new_sprite.zoom_x = config[:zoom_x]
    new_sprite.zoom_y = config[:zoom_y]

    new_sprite.rectangle = Rectangle.new(new_sprite.x, ##init_pos.x,
                                         new_sprite.y, ## init_pos.y,
                                         new_sprite.width,
                                         new_sprite.height)

    new_sprite.init_limits(config[:limits])

    new_sprite.position = init_pos
    new_sprite.check_out_of_screen

    unless !config.key?(:collision_rect) || ( config.key?(:collision_rect) && !Rectangle.valid_limits?(config[:collision_rect]))
      new_sprite.collision_rect = new_sprite.rectangle.limit(config[:collision_rect])
      # Logger.trace("#{new_sprite} Created collision rect #{new_sprite.collision_rect} based on #{new_sprite.rectangle}")
    end

    new_sprite
  end

  def self.empty(pos=nil)
    new_sprite = Sprite.new(@viewport)
    new_sprite.x = pos.x if pos
    new_sprite.y = pos.y if pos
    new_sprite.sprite_disposed = false
    new_sprite
  end

  def init_cells(cells_qty)
    Logger.trace("Starting #{cells_qty} cells on #{self}...")
    @cell = 1 ## init on middle cell (can be 0, 1, 2)
    @cells_qty = cells_qty
    @cel_width = width / @cells_qty
    self.src_rect.set(@cell * @cel_width, 0, @cel_width, height)
  end


  #/// sprite limits ///
  # player: @@screen_rect
  # enemy: (screen + size).limit
  # items: screen + size
  def init_limits(config_limits = nil)


    if Rectangle.valid_limits?(config_limits)
      @limits = @@screen_rect.limit(config_limits)
      Logger.debug("#{self} initialized limits #{@limits} by limiting #{@@screen_rect} with #{config_limits}.")
      return
    end

    excess_limits = 20
    @limits = @@screen_rect.expand(self.rectangle).expand!(excess_limits)
    Logger.debug("#{self} initialized limits #{@limits} by expanding #{@@screen_rect} with #{self.rectangle} & excess: #{excess_limits}")

  end

  def valid_config_limits?(limits)
    !limits.nil? &&
        limits.key?(:x) &&
        limits.key?(:y) &&
        limits[:x].size.equal?(2) &&
        limits[:y].size.equal?(2)
  end

  def self.setup(viewport)
    @viewport = viewport
    @@screen_rect = Rectangle.new(0,0,Graphics.width, Graphics.height)
  end

  def self.viewport
    @viewport
  end

  def position
    Point.new(@float_x, @float_y)
  end

  def position=(position)
    raise "ERROR New position  for sprite #{self} is nil!" if position.nil?
    return Logger.debug("#{self} has been disposed, can't set new position!") if disposed?

    old_rect = self.rectangle
    new_rect = Rectangle.new(position.x, position.y, self.width, self.height)
    if out_of_limits?(new_rect)
      self.rectangle = old_rect
      # Logger.info("rect out of limits , old: #{old_rect}, new: #{new_rect}")
      return
    end


    self.rectangle = new_rect
    old_rect.dispose

    ## update collision rect
    self.collision_rect.position = position unless self.collision_rect.nil?
    # Logger.trace("#{self} coll rect #{self.collision_rect}") if self.collision_rect

    check_cells(self.x, position.x)
    @float_x = position.x
    @float_y = position.y
    self.x = @float_x
    self.y = @float_y
    # Logger.info("setted #{position} to #{self.position}, old rect is #{old_rect}, new rect is #{self.rectangle}")

  end

  def out_of_limits?(new_rect)
    !new_rect.included_in?(@limits)
  end

  def check_out_of_screen
    if self.rectangle && !self.rectangle.collide_rect?(@@screen_rect)
      Logger.debug("#{self} is out of screen! Disposing...")
      dispose(false)
    end
  end

  def check_cells(old_x, new_x)
    return if @cell.nil?
    offset_x = new_x.to_f - old_x.to_f
    return @cell = 0 if offset_x < -ZERO_EPSILON
    return @cell = 2 if offset_x > ZERO_EPSILON
    return @cell = 1 if offset_x.abs < ZERO_EPSILON
  end

  def width
    @cel_width || self.bitmap.width
  end

  def height
    self.bitmap.height
  end

  alias_method :sprite_update, :update
  def update
    return Logger.warn("#{self} has been disposed, can't be updated!") if disposed?
    update_cell
    sprite_update
    reset_cell
    check_out_of_screen
  end

  def update_cell
    return if @cell.nil? || @cel_width.nil? || @cells_qty == 1
    sx = @cell * @cel_width
    # Logger.trace("Updating player cell #{@cell}, cel width is #{@cel_width}, result sx #{sx}")
    self.src_rect.set(sx, 0, @cel_width, height)
  end

  def reset_cell
    return if @cell.nil?
    @cell = 1
  end

  alias_method :sprite_disposed?, :disposed?
  def disposed?
    @sprite_disposed || sprite_disposed?
  end

  ## In-app internal logic, don't force dispose; Do actual dispose only in a controlled, centraliced place
  alias_method :sprite_dispose, :dispose
  def dispose(force = true)
    return if sprite_disposed? ## internal Sprite actually disposed?
    @sprite_disposed = true
    self.visible = false
    Logger.debug("#{self} has been disposed! #{"Forced actual dispose!" if force}")
    sprite_dispose if force
  end


  def to_s
    "<#{self.class}> '#{self.name}'"
  end
end