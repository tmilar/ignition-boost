class Enemy < Ship

  DEFAULTS_ENEMY = {
      cells: 1,
      stats: {
          shoot_decrement_amount: 1,
          shoot_decrement_freq: 100
      },
      movement_style: "zig_zag_movement"
      # limits: {
      #     x: [0.0, 1.0],
      #     y: [0.0, 1.0]
      # }
  }
  def initialize(config = {})
    @config = DEFAULTS_ENEMY.deep_merge(config)
    init_shooting_cooldown

    super(@config)
  end

  def init_shooting_cooldown
    @elapsed_time = @config[:elapsed_time]
    @cooldown_decrement_freq = @config[:stats][:shoot_decrement_freq]
    @cooldown_decrement_amount = @config[:stats][:shoot_decrement_amount]
    @shooting_timer = calculate_shooting_cooldown
  end

  def calculate_shooting_cooldown
    difficulty_factor = @config[:stats][:shoot_freq] - cooldown_decrement
    return Float::INFINITY if difficulty_factor <= 0

    base_cd = Math::log(0.1, 0.995-([difficulty_factor, 995].min).fdiv(1000)).to_i

    rand(base_cd)
  end

  ## Decrement depends on configured elapsed_time, which can be modified for getting more or less difficulty
  def cooldown_decrement
    - (@elapsed_time / @cooldown_decrement_freq) * @cooldown_decrement_amount
  end

  def position_init
    lambda { |sprite|
      Point.new( rand(Graphics.width - sprite.width), 0 - sprite.height + 1 )
    }
  end

  def weapon_pos
    Point.new(self.x + self.width/2, self.y + self.height)
  end

  def update
    @elapsed_time += 1
    super
  end

  def check_shoot
    @shooting_timer -= 1
    if @shooting_timer <= 0
      @shooting_timer = calculate_shooting_cooldown
      return true
    end
    false
    ### Old way of deciding an enemy shooting *kept for historic purposes*
    ### --> to return 'true' if event 'probability = (5 + @diff)/1000' occurs
    # rand(1000) > (995 - @config[:stats][:shoot_freq])
  end
end