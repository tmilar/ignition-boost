class Explosion
  extend Forwardable
  include Subject

  def_delegators :@sprite, :x, :y, :ox, :oy, :zoom_x, :zoom_y, :height, :width, :bitmap, :dispose, :disposed?
  def_delegators :@sprite, :position, :position=, :rectangle
  attr_accessor :sprite

  def initialize(config={})
    Logger.start("explosion", config)
    ship = config[:ship]
    explosion = config[:explosion]
    @sprite = Sprite.create({
        x: ship.x,
        y: ship.y,
        zoom_x: explosion[:zoom],
        zoom_y: explosion[:zoom],
        bitmap: explosion[:bitmap]
    })
    @sprite.ox = @sprite.bitmap.width / 2
    @sprite.oy = @sprite.bitmap.height / 2
    @timer = explosion[:time]
    Sound.se(explosion[:DSE])
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