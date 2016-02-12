class PowerUpSpawner < Spawner


  REPAIR_PUP = {
      name: "powerup0",     # PowerUp name, also must match image name
      target: "player",     # Target : "player", o "enemies" . DEFAULT: "player"
      stats: {              # stats that will change
          hp: +100
      },
      frequency: 20         # [Optional] frequency pup will appear. Default: upper spawner frequency
  }
  WEAPON_UP = {
      name: "powerup1",
      target: "player",
      weapon: {
          level: +1
      }
  }

  DEFAULTS_POWERUP_SPAWNER = {
      frequency: 0,
      spawn_cooldown: 100,
      spawn_decrement_amount: -0,     # DEFAULT 0, cantidad en que se reduce el cooldown base
      spawn_decrement_freq: 100,      # DEFAULT 100, tiempo que tarda en reducirse el cd
      phases: {
          # 1 => {
          #     powerups: [REPAIR_PUP, WEAPON_UP],
          # }
      },
      destructible?: false         # Can pups can be destroyed by bullets?
  }

  def initialize(config={})
    Logger.start("@#{self.class.to_s.uncapitalize}", config, DEFAULTS_POWERUP_SPAWNER)
    @config = DEFAULTS_POWERUP_SPAWNER.merge(config).deep_clone
    super(@config)
  end

  def cooldown_init
    difficulty_factor = @config[:frequency]
    @base_cd = Math::log(0.1, 1.0-difficulty_factor.fdiv(1000)).to_i
    @spawn_timer = @base_cd
  end

  def calculate_cooldown
    return Float::INFINITY if @config[:frequency] == 0
    rand(@base_cd)
  end

  # OVERRIDE spawns
  def spawns(phase)
    phase[:powerups]
  end

  def emit_spawnee(pup_config)
    Logger.trace("pup config is #{pup_config}, self is #{@config}")
    pup_config[:destructible?] ||= @config[:destructible?]
    spawned_pup = PowerUp.new(pup_config)
    notify_observers('new_powerup', spawned_pup)
  end

  def type
    "powerups"
  end
end