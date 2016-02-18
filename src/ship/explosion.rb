class Explosion
  extend Forwardable
  include Subject

  def_delegators :@sprite, :x, :y, :ox, :oy, :zoom_x, :zoom_y, :height, :width, :bitmap, :dispose, :disposed?
  def_delegators :@sprite, :position, :position=, :rectangle
  attr_accessor :sprite

  def initialize(config={})
    Logger.start("explosion", config)

    expl_pos = config[:position]
    @sprite = Sprite.create({
                                x: expl_pos.x,
                                y: expl_pos.y,
                                zoom_x: config[:zoom],
                                zoom_y: config[:zoom],
                                bitmap: config[:bitmap]
                            })

    @sprite.position -= Point.new(@sprite.bitmap.width / 2, @sprite.bitmap.height / 2)

    @timer = config[:time]
    Sound.se(config[:DSE])
  end

  def update
    # Logger.trace("Updating explosion #{self}. Finished? #{self.finished?}")
    return if finished?
    @sprite.update
    @timer -= 1
  end

  def finished?
    if @timer <= 0
      self.dispose
      return true
    end
    false
  end
end