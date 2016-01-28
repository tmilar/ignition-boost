class Weapon

  include Subject

  attr_reader :stats

  DEFAULTS = {
      name: "DEFAULT_GUN_NAME",
      stats: {
          damage: 1,              # bullet damage
          speed: 5,               # bullet speed
          cooldown: 0,            # time to wait before shooting again
      },
      direction: [0, 1],
      type: "lazor",          # weapon name (also lazor image '.png' name)
      SE: ["Attack2",80,150], # sound when shooting
      level: 1               # starting weapon level (optional, default 1)
      # overheat: {         ##TODO overheat/refresh mechanism
      #     bullets: 6,
      #     cooldown: 3
      # }
  }

  MAX_LEVEL = 5 ### TODO define phases and levels for weapons...

  attr_accessors_delegate :@stats, :damage, :speed, :cooldown

  def initialize(config = {})
    super(config)

    Logger.trace("initializin weapon with config: #{config}")
    @config = DEFAULTS.deep_merge(config).deep_clone
    Logger.start("weapon#'#{@config[:name]}'", config, DEFAULTS)

    Logger.warn("Weapon MUST have a defined name, otherwise bugs will occur! Current config: #{@config}") if @config[:name] == DEFAULTS[:name]

    @next_cooldown = 0
    @direction = Point.new(@config[:direction][0], @config[:direction][1]).normalize_me
    @stats = @config[:stats].deep_clone
    @level = @config[:level]
  end

  def update
    @next_cooldown -= 1
  end

  # MUST OVERRIDE
  # > Weapon may shoot one or more lazors...
  # > Each with one or more different movements...
  def shoot(position)
    return unless @next_cooldown <= 0
    @next_cooldown = self.cooldown


    lazor = Bullet.new({
                           name: @config[:name],
                           position: @position,
                           direction: @direction,
                           stats: @stats
                       })

    Logger.trace("New lazor shooted. Pos: #{@position}, Dir: #{lazor.direction}, Stats: #{lazor.stats}. Parents... #{lazor.class.ancestors}")
    notify_observers('new_lazors', {data: @config, lazors: [lazor]})
    Sound.se(@config[:SE])
  end

  def level
    @level
  end

  def max_level
    MAX_LEVEL
  end

  def level=(new_lvl)
    return if new_lvl == @level
    return Logger.info("Weapon can't level up, it's already at its max (#{max_level})!") if new_lvl > max_level

    Logger.debug("Weapon level up! From #{@level} to #{new_lvl}")
    @level = new_lvl
    ### TODO Weapon phases and levels...
  end

  # def refreshing?
  #   false
  #   ## TODO OVERHEAT MECHANISM
  # end

end