class Sprite

  attr_accessor :rectangle
  attr_accessor :name

  @viewport = {}

  def self.create(args = {})
    defaults = {
        ox: 30,
        oy: 30,
        x: 30,
        y: 30,
        bitmap: "NO_IMAGE",
        zoom_x: 1,
        zoom_y: 1,
        name: "DEFAULT_NAME"
    }

    config = defaults.merge(args)

    Logger.info("Creating new sprite. ")
    Logger.start("sprite", args, defaults)
    new_sprite = Sprite.new(@viewport)
    new_sprite.ox = config[:ox]
    new_sprite.oy = config[:oy]
    new_sprite.x = config[:x]
    new_sprite.y = config[:y]
    new_sprite.bitmap = Cache.space(config[:bitmap])
    new_sprite.zoom_x = config[:zoom_x]
    new_sprite.zoom_y = config[:zoom_y]
    new_sprite.name = config[:name]

    new_sprite
  end

  def self.setup_viewport(viewport)
    @viewport = viewport
  end

  def self.viewport
    @viewport
  end

  def position(position=false)
    self.x = position.x if position
    self.y = position.y if position
    Point.new(self.x, self.y)
  end

  def position=(position)
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