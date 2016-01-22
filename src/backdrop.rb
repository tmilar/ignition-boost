
class Backdrop

  def initialize(img = 'backdrop')
    @backdrop = Plane.new(Sprite.viewport)
    @backdrop.bitmap = Cache.space(img)
    @backdrop.z = -1

    Logger.info("Created backdrop with img: #{img}")
  end

  def update
    @backdrop.oy -= 1
  end

  def dispose
    @backdrop.bitmap.dispose
    @backdrop.dispose
  end
end