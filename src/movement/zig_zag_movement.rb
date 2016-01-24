module ZigZagMovement
  include Movement

  def initialize(config = {})
    super(config)
    @ticker = 0
    @dir_x = [:RIGHT, :LEFT].sample
  end

  def update_movement
    move(@dir_x, @ticker * 0.06)
    move(:DOWN)

    @ticker -= 1
    if @ticker <= 0
      @dir_x = self.x < Graphics.width / 2 ? :RIGHT : :LEFT
      @ticker = rand(90)
    end
  end

end