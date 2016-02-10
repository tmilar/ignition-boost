class Enemy < Ship

  include ZigZagMovement

  DEFAULTS_ENEMY = {
      cells: 1,
      # limits: {
      #     x: [0.0, 1.0],
      #     y: [0.0, 1.0]
      # }
  }
  def initialize(config = {})
    config = DEFAULTS_ENEMY.deep_merge(config)
    super(config)

    init_shooting_cooldown
  end

  def init_shooting_cooldown
    difficulty_factor = @config[:stats][:shoot_freq]
    @base_cd = Math::log(0.1, 0.995-difficulty_factor.fdiv(1000)).to_i ### TODO add difficulty calculation
    @shooting_timer = @base_cd
  end

  def position_init
    self.position = Point.new( rand(Graphics.width) , 0 - self.height + 1 )
  end

  def weapon_pos
    Point.new(self.x + self.width/2, self.y + self.height)
  end

  def check_shoot
    @shooting_timer -= 1
    if @shooting_timer <= 0
      @shooting_timer = rand(@base_cd)
      return true
    end
    false
    ### Old way of deciding an enemy shooting *kept for historic purposes*
    ### --> to return 'true' if event 'probability = (5 + @diff)/1000' occurs
    # rand(1000) > (995 - @config[:stats][:shoot_freq])
  end
end