class Weapon

  include Subject


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
      level: 1,               # starting weapon level (optional, default 1)
      max_level: 5,
      # shooter: 'player' OR 'enemy'
      # overheat: {         ##TODO overheat/refresh mechanism
      #     bullets: 6,
      #     cooldown: 3
      # }
  }

  attr_accessors_delegate :@stats, :damage, :speed, :cooldown
  attr_readers_delegate :@config, :name, :max_level, :shooter
  attr_reader :stats
  attr_accessor :level

  def self.create(config = {})
    weapon_type = config[:type]
    Logger.debug("Creating Weapon type '#{weapon_type}'")
    case weapon_type
      when "lazor" then LazorWeapon.new(config)
      when "ball" then BallWeapon.new(config)
      else raise "Can't create Undefined weapon type '#{weapon_type}'!"
    end
  end

  def initialize(config = {})
    super(config)

    @config = DEFAULTS.deep_merge(config).deep_clone
    Logger.start("weapon#'#{@config[:name]}'", config, DEFAULTS)

    Logger.warn("Weapon MUST have a defined name, otherwise bugs will occur! Current config: #{@config}") if @config[:name] == DEFAULTS[:name]

    @next_cooldown = 0
    @direction = Point.new(@config[:direction][0], @config[:direction][1]).normalize_me
    @stats = @config[:stats].deep_clone
    @level = @config[:level]
    @max_level = @config[:max_level]
  end

  def update
    @next_cooldown -= 1
  end

  def shoot(position)
    return unless @next_cooldown <= 0
    @next_cooldown = self.cooldown

    lazors = emit_lazors({
                                      name: @config[:name],
                                      position: position,
                                      direction: @direction,
                                      stats: @stats,
                                      shooter: self.shooter,
                                      observers: self.observers
                                  })

    # notify_observers('new_lazors', {shooter: self.shooter, lazors: lazors})
    Sound.se(@config[:SE])
  end

  # MUST OVERRIDE
  # > Weapon may shoot one or more lazors...
  # > Each with one or more different movements...
  def emit_lazors(bullet_config={})
    lazor = Bullet.new(bullet_config)
    Logger.trace("#{self} New lazor shooted. Pos: #{lazor.position}, Dir: #{lazor.direction}, Stats: #{lazor.stats}. Shooter: #{lazor.shooter}")

    [lazor]
  end

  def level=(new_lvl)
    return if new_lvl == level
    return Logger.info("Weapon can't level up, it's already at its max (#{max_level})!") if new_lvl > max_level

    Logger.debug("Weapon level up! From #{level} to #{new_lvl}")
    @level = new_lvl
  end

  def type
    self.class.to_s.uncapitalize.chomp("Weapon")
  end

  def to_s
    "<#{self.class}> '#{name}'"
  end

  # def refreshing?
  #   false
  #   ## TODO OVERHEAT MECHANISM
  # end

end