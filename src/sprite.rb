class Sprite

  attr_accessor :rectangle
  attr_accessor :name
  attr_accessor :cell

  @viewport = {}

  EPSILON = 0.00001

  def self.create(args = {})
    defaults = {
        x: 30,
        y: 30,
        bitmap: "NO_IMAGE",
        zoom_x: 1,
        zoom_y: 1,
        name: "DEFAULT_NAME",
        cells: 1
    }

    config = defaults.merge(args)

    new_sprite = Sprite.new(@viewport)
    new_sprite.x = config[:x]
    new_sprite.y = config[:y]
    new_sprite.bitmap = Cache.space(config[:bitmap])
    new_sprite.ox = new_sprite.width / 2
    new_sprite.oy = new_sprite.height
    new_sprite.zoom_x = config[:zoom_x]
    new_sprite.zoom_y = config[:zoom_y]
    new_sprite.name = config[:name]
    new_sprite.rectangle = Rectangle.new(new_sprite.x,
                                         new_sprite.y,
                                         new_sprite.width,
                                         new_sprite.height)

    # Logger.debug("Created new sprite: #{self}. ")
    new_sprite.init_cells(config[:cells]) if config[:cells] > 1
    new_sprite
  end

  def init_cells(cells_qty)
    Logger.trace("Starting #{cells_qty} cells on #{self}...")
    @cell = 1 ## init on middle cell (can be 0, 1, 2)
    @cells_qty = cells_qty
    @cel_width = width / @cells_qty
    self.src_rect.set(@cell * @cel_width, 0, @cel_width, height)

    self.ox = @cel_width / 2
    self.oy = height
    self.rectangle = Rectangle.new(self.x,
                                   self.y,
                                   @cel_width,
                                   self.height)
  end

  def self.setup_viewport(viewport)
    @viewport = viewport
  end

  def self.viewport
    @viewport
  end

  def position
    Point.new(self.x, self.y)
  end

  def position=(position)
    raise "ERROR New position  for sprite #{self} is nil!" if position.nil?
    self.rectangle = Rectangle.new(position.x, position.y, self.width, self.height)
    check_cells(self.x, position.x)
    self.x = position.x
    self.y = position.y

  end

  def check_cells(old_x, new_x)
    return if @cell.nil?
    @cell = 0 if new_x.to_f - old_x.to_f < -EPSILON
    @cell = 1 if (new_x.to_f - old_x.to_f).between?(-EPSILON, EPSILON)
    @cell = 2 if new_x.to_f - old_x.to_f > EPSILON
  end

  def reset_cell
    return if @cell.nil?
    @cell = 1
  end

  def width
    @cel_width || self.bitmap.width
  end

  def height
    self.bitmap.height
  end

  alias_method :sprite_update, :update
  def update
    update_cell
    sprite_update
    reset_cell
  end

  def update_cell
    return if @cell.nil? || @cel_width.nil? || @cells_qty == 1
    sx = @cell * @cel_width
    # Logger.trace("Updating player cell #{@cell}, cel width is #{@cel_width}, result sx #{sx}")
    self.src_rect.set(sx, 0, @cel_width, height)
  end

  def to_s
    "<#{self.class}> '#{self.name}'"
  end
end