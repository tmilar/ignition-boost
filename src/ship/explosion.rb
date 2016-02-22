class Explosion
  extend Forwardable
  include Subject

  def_delegators :@sprite, :x, :y, :ox, :oy, :zoom_x, :zoom_y, :height, :width, :bitmap, :dispose, :disposed?
  def_delegators :@sprite, :position, :position=, :rectangle
  attr_accessor :sprite

  def initialize(config={})
    Logger.start("explosion", config)
    @config = config.deep_clone
    super(config)
    @timer = @config[:time]
    sprite_init
    Sound.se(@config[:DSE])
  end

  def sprite_init
    self.sprite = Sprite.create({
                                    zoom_x: @config[:zoom],
                                    zoom_y: @config[:zoom],
                                    bitmap: @config[:bitmap],
                                    init_pos: position_init
                                })
  end

  def position_init
    lambda { |sprite| @config[:position] - Point.new(sprite.bitmap.width / 2, sprite.bitmap.height / 2)}
  end

  def update
    return if check_finished?
    self.sprite.update
  end

  def check_finished?
    @timer -= 1
    if @timer <= 0
      self.dispose
      return true
    end
    false
  end
end