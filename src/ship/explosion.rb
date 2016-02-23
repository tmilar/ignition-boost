class Explosion < GameEntity

  def initialize(config={})
    Logger.start("explosion", config)
    @config = config.deep_clone
    super(config)
    @timer = @config[:time]
    Sound.se(@config[:DSE])
  end

  def sprite_init
    Sprite.create({
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
    super
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