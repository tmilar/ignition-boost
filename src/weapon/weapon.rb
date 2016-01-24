class Weapon

  include Subject

  attr_reader :stats

  DEFAULTS = {
      name: "DEFAULT_GUN_NAME",
      stats: {
          damage: 1,              # bullet damage
          speed: 5,               # bullet speed
      },
      direction: [0, 1],
      type: "lazor",          # weapon name (also lazor image '.png' name)
      cooldown: 5,            # time to wait before shooting again
      SE: ["Attack2",80,150], # sound when shooting
      level: 1               # starting weapon level (optional, default 1)
      # overheat: {         ##TODO overheat/refresh mechanism
      #     bullets: 6,
      #     cooldown: 3
      # }
  }

  def initialize(config = {})
    super(config)

    Logger.trace("initializin weapon with config: #{config}")

    @config = config.deep_clone
    @config[:weapon][:ship] = config[:name]
    Logger.start("ship #{@config[:weapon][:ship]}-> weapon#'#{@config[:weapon][:type]}'", @config[:weapon], DEFAULTS)
    @weapon_config = DEFAULTS.merge(@config[:weapon])

    @cooldown = 0
    @direction = Point.new(@weapon_config[:direction][0], @weapon_config[:direction][1]).normalize_me
    @stats = @weapon_config[:stats].deep_clone
  end

  def update
    @cooldown -= 1
  end

  # MUST OVERRIDE
  # > Weapon may shoot one or more lazors...
  # > Each with one or more different movements...
  def shoot(position)
    return unless @cooldown <= 0
    @cooldown = @weapon_config[:cooldown]
    @position = position

    lazor = Bullet.new({
                           name: @weapon_config[:name],
                           position: @position,
                           direction: @direction,
                           stats: @stats
                       })

    Logger.trace("New lazor shooted. Pos: #{@position}, Dir: #{lazor.direction}, Stats: #{lazor.stats}. Parents... #{lazor.class.ancestors}")
    notify_observers('new_lazors', {data: @weapon_config, lazors: [lazor]})
    Sound.se(@weapon_config[:SE])
  end


  # def refreshing?
  #   false
  #   ## TODO OVERHEAT MECHANISM
  # end

end