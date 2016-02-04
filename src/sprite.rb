class Sprite

  attr_accessor :rectangle
  attr_accessor :name

  @viewport = {}

  def self.create(args = {})
    defaults = {
        x: 30,
        y: 30,
        bitmap: "NO_IMAGE",
        zoom_x: 1,
        zoom_y: 1,
        name: "DEFAULT_NAME"
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

    # Logger.debug("Created new sprite: #{new_sprite.bitmap}. ")
    new_sprite
  end

  def self.setup_viewport(viewport)
    @viewport = viewport
  end

  def self.viewport
    @viewport
  end

  def position(position=false)
    if position
      self.rectangle = Rectangle.new(position.x, position.y, self.width, self.height)
      self.x = position.x
      self.y = position.y
    end
    Point.new(self.x, self.y)
  end

  def position=(position)
    self.rectangle = Rectangle.new(position.x, position.y, self.width, self.height)
    self.x = position.x if position
    self.y = position.y if position
  end

  def width
    self.bitmap.width
  end

  def height
    self.bitmap.height
  end

  #### TODO think of sprite cells...
  # init:
  # @sprite.cell = 1
  # @sprite.cw = self.bitmap.width / 3
  # @sprite.src_rect.set(@sprite.cell * @sprite.cw, 0, @sprite.cw, self.height)
  #
  # update:
  # @sprite.cell = 1 if @sprite.cell > 3
  # sx = @sprite.cell * @sprite.cw
  # @sprite.src_rect.set(sx, 0, @sprite.cw, self.height)
end